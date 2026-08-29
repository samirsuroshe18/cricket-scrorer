import 'dart:async';
import 'dart:convert';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_dao.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_database.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/start_innings_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/sync_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/start_innings_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/sync_res.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/ball_outcome_preview.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/start_innings.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/sync_match.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart' hide Value;

enum SyncPhase {
  /// Nothing pending, or a clean attempt just finished.
  idle,

  /// A `/sync` call is in flight.
  syncing,

  /// A per-event rule failure stopped the batch partway (`failedAt`/
  /// `failedCode`) — the applied prefix is gone from the queue, the rest is
  /// on hold. Will not retry itself; it would fail identically.
  blockedOnRule,

  /// `409 SYNC_CONFLICT` — the server holds deliveries this client never
  /// queued. The local queue is left untouched; resolution is an explicit,
  /// scorer-confirmed [OfflineSyncService.discardQueueAndReload].
  conflict,
}

/// Owns the local offline queue and everything that tries to flush it. Never
/// gates whether `score_ball_controller.dart` attempts the network first —
/// see that file's own comment on why. This only decides WHEN to retry a
/// non-empty queue on its own: on app resume, on connectivity regained, or
/// on [retryNow].
///
/// Registered in `ScoringInjection`, not `CoreInjection` — see this repo's
/// CLAUDE.md ("Don't register feature dependencies in CoreInjection").
class OfflineSyncService extends GetxService {
  OfflineSyncService({
    required this.dao,
    required this.syncMatchUseCase,
    required this.startInningsUseCase,
  });

  final ScoringQueueDao dao;
  final SyncMatchUseCase syncMatchUseCase;

  /// The real `start-innings` call the reconnect chain makes once a
  /// [PendingStartInnings] marker exists and the previous innings' queue has
  /// flushed clean — see [_attemptSync]'s transition branch.
  final StartInningsUseCase startInningsUseCase;

  final RxInt pendingCount = 0.obs;

  /// How many `ball`-type rows the queue holds — narrower than
  /// [pendingCount] on purpose. A pending `undo` row represents a
  /// correction already made, waiting to reach the server; it is not
  /// something further to undo, so `ScoreBallController.canUndo` needs this
  /// count, not the blanket one, alongside [historyCount].
  final RxInt queuedBallCount = 0.obs;

  /// How many balls the local [BallHistory] ledger holds for the watched
  /// innings — `ScoreBallController.canUndo`'s other half, alongside
  /// [queuedBallCount]. DB-backed rather than an in-memory stack (the
  /// ledger's whole point), so undo survives a cold app relaunch too.
  final RxInt historyCount = 0.obs;
  final Rx<SyncPhase> phase = SyncPhase.idle.obs;
  final Rxn<String> lastError = Rxn<String>();

  /// The `state` snapshot from the most recent successful `/sync` response —
  /// exactly the same complete-state shape `undo-ball` returns. The
  /// controller listens for this to reconcile its provisional display back
  /// to real server truth once a flush actually lands, without needing a
  /// separate re-fetch: the sync response already carries everything.
  final Rxn<SyncState> lastAppliedState = Rxn<SyncState>();

  /// Fires once the reconnect chain's real `start-innings` call — made on
  /// behalf of a [PendingStartInnings] marker — actually succeeds. Purely
  /// informational: the console already rendered this innings correctly the
  /// moment it opened it offline (see `ScoreBallController._startInningsOffline`),
  /// so nothing needs to re-apply this to visible state — doing so
  /// unconditionally would wrongly zero out any further balls the scorer
  /// has since queued for it.
  final Rxn<StartInningsRes> lastAppliedStartInnings = Rxn<StartInningsRes>();

  AppLifecycleListener? _lifecycleListener;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<List<QueuedSyncEvent>>? _queueSub;
  StreamSubscription<List<BallHistoryEntry>>? _historySub;

  String? _watchedMatchId;
  int? _watchedInningsNumber;

  bool _syncing = false;

  @override
  void onInit() {
    super.onInit();
    _lifecycleListener = AppLifecycleListener(onResume: _onPossibleReconnect);
    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      (_) => _onPossibleReconnect(),
    );
  }

  @override
  void onClose() {
    _lifecycleListener?.dispose();
    unawaited(_connectivitySub?.cancel());
    unawaited(_queueSub?.cancel());
    unawaited(_historySub?.cancel());
    super.onClose();
  }

  void _onPossibleReconnect() {
    final matchId = _watchedMatchId;
    final inningsNumber = _watchedInningsNumber;
    if (matchId == null || inningsNumber == null) return;
    unawaited(_attemptSync(matchId: matchId, inningsNumber: inningsNumber));
  }

  /// Subscribes [pendingCount] to one match/innings' queue and remembers it
  /// as the scope the lifecycle/connectivity triggers act on. Call once from
  /// the controller's `onInit`.
  void watch({required String matchId, required int inningsNumber}) {
    _watchedMatchId = matchId;
    _watchedInningsNumber = inningsNumber;
    unawaited(_queueSub?.cancel());
    _queueSub = dao
        .watchQueue(matchId: matchId, inningsNumber: inningsNumber)
        .listen((rows) {
          pendingCount.value = rows.length;
          queuedBallCount.value = rows
              .where((row) => row.eventType == SyncEventType.ball)
              .length;
        });
    unawaited(_historySub?.cancel());
    _historySub = dao
        .watchHistory(matchId: matchId, inningsNumber: inningsNumber)
        .listen((rows) => historyCount.value = rows.length);
  }

  /// Stops watching a match's queue — does NOT stop background flush
  /// attempts already in flight, and a later [watch] for the same innings
  /// picks the queue up exactly where it was.
  void unwatch() {
    unawaited(_queueSub?.cancel());
    _queueSub = null;
    unawaited(_historySub?.cancel());
    _historySub = null;
    _watchedMatchId = null;
    _watchedInningsNumber = null;
    phase.value = SyncPhase.idle;
    lastError.value = null;
  }

  Future<SyncBaselineData?> baselineFor({
    required String matchId,
    required int inningsNumber,
  }) {
    return dao.baselineFor(matchId: matchId, inningsNumber: inningsNumber);
  }

  /// Queues one delivery. No longer refuses when an undo is pending — a
  /// mixed batch is now avoided at flush time instead, by
  /// [_attemptSync]'s homogeneous-run grouping — so a scorer can keep
  /// entering deliveries after an offline undo of an already-synced ball.
  Future<void> enqueueBall({
    required String matchId,
    required int inningsNumber,
    required ScoreBallReq req,
    required PreEventState pre,
  }) {
    return dao.enqueueBall(
      matchId: matchId,
      inningsNumber: inningsNumber,
      req: req,
      pre: pre,
    );
  }

  /// See [enqueueBall]'s doc comment.
  Future<void> enqueueBowler({
    required String matchId,
    required int inningsNumber,
    required SelectBowlerReq req,
    required PreEventState pre,
  }) {
    return dao.enqueueBowler(
      matchId: matchId,
      inningsNumber: inningsNumber,
      req: req,
      pre: pre,
    );
  }

  /// See [enqueueBall]'s doc comment.
  Future<void> enqueueUndo({
    required String matchId,
    required int inningsNumber,
    required String ballEventId,
  }) {
    return dao.enqueueUndo(
      matchId: matchId,
      inningsNumber: inningsNumber,
      ballEventId: ballEventId,
    );
  }

  Future<void> deleteQueuedEvent(int id) => dao.deleteEvent(id);

  // ---------------------------------------------------------------------
  // BallHistory — the ledger behind chained offline undo of already-synced
  // balls. See scoring_queue_database.dart's `BallHistory` doc comment.
  // ---------------------------------------------------------------------

  Future<void> recordBallHistory({
    required String matchId,
    required int inningsNumber,
    required PreEventState pre,
    String? ballEventId,
  }) {
    return dao.insertHistoryEntry(
      matchId: matchId,
      inningsNumber: inningsNumber,
      pre: pre,
      ballEventId: ballEventId,
    );
  }

  Future<BallHistoryEntry?> latestBallHistory({
    required String matchId,
    required int inningsNumber,
  }) {
    return dao.latestHistoryEntry(
      matchId: matchId,
      inningsNumber: inningsNumber,
    );
  }

  Future<void> deleteBallHistoryEntry(int id) => dao.deleteHistoryEntry(id);

  Future<void> resolveBallHistoryId({
    required int id,
    required String ballEventId,
  }) {
    return dao.setHistoryBallEventId(id: id, ballEventId: ballEventId);
  }

  Future<int> ballHistoryCount({
    required String matchId,
    required int inningsNumber,
  }) {
    return dao.historyCount(matchId: matchId, inningsNumber: inningsNumber);
  }

  Future<void> clearBallHistory({
    required String matchId,
    required int inningsNumber,
  }) {
    return dao.clearHistory(matchId: matchId, inningsNumber: inningsNumber);
  }

  // ---------------------------------------------------------------------
  // PendingStartInnings — the local-only offline "open the next innings"
  // marker. See scoring_queue_database.dart's table doc comment.
  // ---------------------------------------------------------------------

  Future<void> savePendingStartInnings({
    required String matchId,
    required int inningsNumber,
    required String strikerName,
    required String nonStrikerName,
    required String bowlerName,
  }) {
    return dao.upsertPendingStartInnings(
      PendingStartInningsTableCompanion.insert(
        matchId: matchId,
        inningsNumber: inningsNumber,
        strikerName: strikerName,
        nonStrikerName: nonStrikerName,
        bowlerName: bowlerName,
      ),
    );
  }

  Future<PendingStartInnings?> pendingStartInningsFor({
    required String matchId,
    required int inningsNumber,
  }) {
    return dao.pendingStartInningsFor(
      matchId: matchId,
      inningsNumber: inningsNumber,
    );
  }

  Future<void> clearPendingStartInnings({
    required String matchId,
    required int inningsNumber,
  }) {
    return dao.deletePendingStartInnings(
      matchId: matchId,
      inningsNumber: inningsNumber,
    );
  }

  // ---------------------------------------------------------------------
  // InningsSummaries — an innings' final totals, kept past the point the
  // console resets its live fields for the next innings.
  // ---------------------------------------------------------------------

  Future<void> recordInningsSummary({
    required String matchId,
    required int inningsNumber,
    required String battingTeam,
    required int totalRuns,
    required int wickets,
    required String overs,
  }) {
    return dao.upsertInningsSummary(
      InningsSummariesCompanion.insert(
        matchId: matchId,
        inningsNumber: inningsNumber,
        battingTeam: battingTeam,
        totalRuns: totalRuns,
        wickets: wickets,
        overs: overs,
      ),
    );
  }

  Future<InningsSummary?> inningsSummaryFor({
    required String matchId,
    required int inningsNumber,
  }) {
    return dao.inningsSummaryFor(
      matchId: matchId,
      inningsNumber: inningsNumber,
    );
  }

  // ---------------------------------------------------------------------
  // ProvisionalMatchResults — a locally-computed win/margin, held until the
  // real scorecard becomes fetchable.
  // ---------------------------------------------------------------------

  Future<void> saveProvisionalResult({
    required String matchId,
    required String winner,
    String? marginType,
    int? margin,
  }) {
    return dao.upsertProvisionalResult(
      ProvisionalMatchResultsCompanion.insert(
        matchId: matchId,
        winner: winner,
        marginType: Value(marginType),
        margin: Value(margin),
      ),
    );
  }

  Future<ProvisionalMatchResult?> provisionalResultFor(String matchId) {
    return dao.provisionalResultFor(matchId);
  }

  Future<void> deleteProvisionalResult(String matchId) {
    return dao.deleteProvisionalResult(matchId);
  }

  Future<QueuedSyncEvent?> lastQueuedBall({
    required String matchId,
    required int inningsNumber,
  }) {
    return dao.lastQueuedBall(matchId: matchId, inningsNumber: inningsNumber);
  }

  /// Replays the queue on top of its own oldest row's snapshot — the only
  /// case this is needed is a cold app relaunch that happens while still
  /// offline, with no live socket ack available to seed from otherwise. An
  /// empty queue returns null: the caller's own live in-memory state is
  /// already correct and there is nothing to preview on top of it.
  Future<PreEventState?> currentProvisionalState({
    required String matchId,
    required int inningsNumber,
    required int totalOvers,
    int? target,
  }) async {
    final events = await dao.pendingEvents(
      matchId: matchId,
      inningsNumber: inningsNumber,
    );
    if (events.isEmpty) return null;

    final anchorJson = events.first.preEventStateJson;
    if (anchorJson == null) return null;

    var pre = PreEventState.fromJson(
      jsonDecode(anchorJson) as Map<String, dynamic>,
    );

    for (final row in events) {
      switch (row.eventType) {
        case SyncEventType.ball:
          final req = ScoreBallReq.fromJson(
            jsonDecode(row.payloadJson!) as Map<String, dynamic>,
          );
          pre = previewBall(
            pre: pre,
            req: req,
            totalOvers: totalOvers,
            inningsNumber: inningsNumber,
            target: target,
          ).nextPreEventState;
        case SyncEventType.bowler:
          final req = SelectBowlerReq.fromJson(
            jsonDecode(row.payloadJson!) as Map<String, dynamic>,
          );
          pre = PreEventState(
            totalRuns: pre.totalRuns,
            wickets: pre.wickets,
            legalBalls: pre.legalBalls,
            totalBalls: pre.totalBalls,
            oversCompleted: pre.oversCompleted,
            striker: pre.striker,
            nonStriker: pre.nonStriker,
            currentBowlerName: req.bowlerName,
            overTotalRuns: pre.overTotalRuns,
            overLegalDeliveries: pre.overLegalDeliveries,
            extrasSnapshot: pre.extrasSnapshot,
            overExtrasSnapshot: pre.overExtrasSnapshot,
          );
        case SyncEventType.undo:
          break; // never co-occurs with ball/bowler rows — enforced at enqueue
      }
    }

    return pre;
  }

  /// Pure passthrough to `previewBall` — exposed here so callers reach it
  /// through the same object that owns the queue, rather than importing the
  /// `domain/offline/` port directly.
  BallOutcomePreview previewNextBall({
    required PreEventState pre,
    required ScoreBallReq req,
    required int totalOvers,
    required int inningsNumber,
    int? target,
  }) => previewBall(
    pre: pre,
    req: req,
    totalOvers: totalOvers,
    inningsNumber: inningsNumber,
    target: target,
  );

  /// Keeps the sync protocol's own bookkeeping fresh from ANY real ack, not
  /// just a `/sync` response — an ordinary online `score-ball`/`undo-ball`
  /// ack, or a `score:update` socket payload, all carry
  /// `inningsTotals.totalBalls`, which is exactly `absoluteBallSeq` by
  /// construction (the server assigns `absoluteBallSeq: inning.totalBalls +
  /// 1` at write time). Without this, a sync attempted after a purely-online
  /// stretch would use a stale `baseAbsoluteBallSeq` and risk a spurious
  /// conflict the first time it's actually needed.
  Future<void> recordAck({
    required String matchId,
    required int inningsNumber,
    required int totalBalls,
    String? lastBallEventId,
  }) async {
    final existing = await dao.baselineFor(
      matchId: matchId,
      inningsNumber: inningsNumber,
    );
    await dao.upsertBaseline(
      SyncBaselineCompanion.insert(
        matchId: matchId,
        inningsNumber: inningsNumber,
        baseAbsoluteBallSeq: totalBalls,
        lastBallEventId: Value(lastBallEventId ?? existing?.lastBallEventId),
      ),
    );
  }

  Future<void> retryNow({
    required String matchId,
    required int inningsNumber,
  }) {
    return _attemptSync(matchId: matchId, inningsNumber: inningsNumber);
  }

  /// Conflict resolution: discard everything still queued for this innings.
  /// Deliberately never automatic — see [SyncPhase.conflict]'s doc comment.
  /// Leaves `SyncBaseline` alone; the next real ack (an online ball, or a
  /// live `score:update`) refreshes it via [recordAck] regardless.
  ///
  /// Also discards [BallHistory]: a conflict means the server holds
  /// deliveries this client never queued, so this device's view of "what
  /// happened" is no longer trustworthy from that point — a stale ledger
  /// entry would let a later undo tap restore to a snapshot the server
  /// never actually produced.
  Future<void> discardQueueAndReload({
    required String matchId,
    required int inningsNumber,
  }) async {
    await dao.clearQueue(matchId: matchId, inningsNumber: inningsNumber);
    await dao.clearHistory(matchId: matchId, inningsNumber: inningsNumber);
    phase.value = SyncPhase.idle;
    lastError.value = null;
  }

  SyncEvent _toWireEvent(QueuedSyncEvent row) {
    switch (row.eventType) {
      case SyncEventType.ball:
        return SyncBallEvent(
          ScoreBallReq.fromJson(
            jsonDecode(row.payloadJson!) as Map<String, dynamic>,
          ),
        );
      case SyncEventType.bowler:
        return SyncBowlerEvent(
          SelectBowlerReq.fromJson(
            jsonDecode(row.payloadJson!) as Map<String, dynamic>,
          ),
        );
      case SyncEventType.undo:
        return SyncUndoEvent(UndoBallReq(ballEventId: row.ballEventId!));
    }
  }

  Future<void> _attemptSync({
    required String matchId,
    required int inningsNumber,
  }) async {
    if (_syncing) return;
    _syncing = true;

    try {
      final pending = await dao.pendingStartInningsFor(
        matchId: matchId,
        inningsNumber: inningsNumber,
      );

      if (pending == null) {
        await _flushQueue(matchId: matchId, inningsNumber: inningsNumber);
        return;
      }

      // A [PendingStartInnings] marker exists: this innings has no Inning
      // document server-side yet, so nothing queued for it can be sent —
      // `/sync` requires that document to already exist (`INNINGS_NOT_STARTED`
      // otherwise). Three steps, in order, each one gating the next:
      final previousInningsNumber = inningsNumber - 1;

      // 1. Flush the PREVIOUS innings' tail. Its rows are untouched by
      // [watch] having moved on to this innings — they are still sitting in
      // the queue under their own `inningsNumber`.
      await _flushQueue(matchId: matchId, inningsNumber: previousInningsNumber);
      final stillPending = await dao.pendingCount(
        matchId: matchId,
        inningsNumber: previousInningsNumber,
      );
      if (stillPending > 0) {
        // Didn't finish clean — offline again, a conflict, or blocked on a
        // rule; `_flushQueue` already set `phase`/`lastError` to say which.
        // Nothing safe to do until the PREVIOUS innings is fully settled —
        // stop here, marker untouched, retried whole on the next reconnect.
        return;
      }

      // 2. Open this innings for real, with the names cached when it was
      // opened offline. Idempotent to repeat: `start-innings` is re-callable
      // until its first delivery, and finds-or-creates players by name, so a
      // retry after a dropped response here is exactly as safe as anywhere
      // else in this contract.
      final response = await startInningsUseCase(
        params: StartInningsParams(
          matchId: matchId,
          startInningsReq: StartInningsReq(
            strikerName: pending.strikerName,
            nonStrikerName: pending.nonStrikerName,
            bowlerName: pending.bowlerName,
          ),
        ),
      );

      if (!response.isResult) {
        // Leave the marker in place for the next reconnect to retry the
        // whole chain — surfaced through the same idle-with-error state a
        // plain sync failure already uses, no new banner state needed.
        phase.value = SyncPhase.idle;
        lastError.value = response.fallback.message;
        return;
      }

      await dao.deletePendingStartInnings(
        matchId: matchId,
        inningsNumber: inningsNumber,
      );
      lastAppliedStartInnings.value = response.result.data;

      // 3. Flush whatever was queued for this innings while it was still
      // only locally open.
      await _flushQueue(matchId: matchId, inningsNumber: inningsNumber);
    } finally {
      _syncing = false;
    }
  }

  Future<void> _flushQueue({
    required String matchId,
    required int inningsNumber,
  }) async {
    // Loops so a whole queue — however many homogeneous runs it takes to
    // drain it — flushes in one trigger rather than needing N separate
    // wakeups. Also how a >120-event stretch (chunked by the server's own
    // cap) gets flushed in one go.
    while (true) {
      final events = await dao.pendingEvents(
        matchId: matchId,
        inningsNumber: inningsNumber,
      );
      if (events.isEmpty) {
        phase.value = SyncPhase.idle;
        return;
      }

      // The DAO no longer refuses to enqueue a ball/bowler event while an
      // undo is pending (or vice versa) — see `ScoringQueueDao.enqueueBall`
      // — so the queue as a whole can be genuinely mixed. The server still
      // rejects a mixed batch outright (`SYNC_MIXED_BATCH`), so this is
      // where that invariant is enforced instead: never send more than one
      // leading, same-type run at a time.
      //
      // Undo events carry their target `ballEventId` already resolved at
      // enqueue time, so a contiguous run of them is safe to send together
      // in one call. A ball/bowler run is sent ONE EVENT AT A TIME instead
      // of batched, deliberately: `/sync`'s response only ever returns the
      // LAST ball's server id (`data.lastBallEventId`), never one per
      // event, so batching several together would leave every ball but the
      // last permanently unresolvable in `BallHistory` — exactly the ball
      // a scorer would need to keep undoing further back into. One call
      // per ball costs more round trips on a big reconnect catch-up, but
      // is what makes "undo, indefinitely, into already-synced territory"
      // actually work rather than silently dead-ending a few balls in.
      final isUndoRun = events.first.eventType == SyncEventType.undo;
      final run = isUndoRun
          ? events.takeWhile((e) => e.eventType == SyncEventType.undo).toList()
          : [events.first];

      final baseline = await dao.baselineFor(
        matchId: matchId,
        inningsNumber: inningsNumber,
      );
      final baseAbsoluteBallSeq = baseline?.baseAbsoluteBallSeq ?? 0;

      phase.value = SyncPhase.syncing;

      final response = await syncMatchUseCase(
        params: SyncMatchParams(
          matchId: matchId,
          syncReq: SyncReq(
            inningsNumber: inningsNumber,
            baseAbsoluteBallSeq: baseAbsoluteBallSeq,
            events: run.map(_toWireEvent).toList(),
          ),
        ),
      );

      if (!response.isResult) {
        final failure = response.fallback;

        if (failure is CricketConflictFailure) {
          // Nothing was written server-side — leave the queue exactly as
          // it is. Resolution is scorer-driven from here.
          phase.value = SyncPhase.conflict;
          return;
        }

        if (failure is CricketNoInternetFailure) {
          phase.value = SyncPhase.idle;
          return;
        }

        // Anything else is unexpected — don't touch the queue, don't loop,
        // let the next trigger try again. Still has to leave `phase`
        // somewhere other than `syncing`, though: that value was set
        // above for this attempt, and nothing downstream of an early
        // return here would ever move it again — the banner's spinner
        // would spin forever on a failure that isn't a conflict or a
        // dropped connection (a stray 500, a malformed response, an
        // event type the server rejects outright). `idle` with
        // `pendingCount` still non-zero is exactly the "N unsynced, tap
        // to retry" state the banner already renders for that case.
        phase.value = SyncPhase.idle;
        lastError.value = failure.message;
        return;
      }

      final data = response.result.data;
      if (data == null) return;

      final committed = data.appliedCount + data.skippedCount;
      await dao.deleteAppliedPrefix(
        matchId: matchId,
        inningsNumber: inningsNumber,
        count: committed,
      );

      // [pendingCount] normally trails the delete above — it is driven by
      // [ScoringQueueDao.watchQueue]'s reactive stream, which crosses the
      // background-isolate boundary as its own independent round trip and
      // is not guaranteed to have caught up by the time this function
      // continues. Reading it straight after the delete (via
      // [ScoringQueueDao.pendingCount], a plain one-shot query rather than
      // the stream) instead of waiting for that stream is what keeps
      // `_reconcileFromSyncedState`'s `_hasQueuedBalls` check — which runs
      // synchronously off [lastAppliedState] below — from seeing the
      // stale, pre-delete count and wrongly believing the queue is still
      // non-empty for an innings that just finished syncing clean.
      pendingCount.value = await dao.pendingCount(
        matchId: matchId,
        inningsNumber: inningsNumber,
      );

      // A ball/bowler run's response, when it did score a ball, carries
      // that ball's own id — this is exactly what backfills the
      // `BallHistory` row inserted for it back at enqueue time (`null`
      // until now), making that row targetable the moment it becomes the
      // top of the undo stack.
      if (!isUndoRun && data.lastBallEventId != null) {
        final unresolved = await dao.oldestUnresolvedHistoryEntry(
          matchId: matchId,
          inningsNumber: inningsNumber,
        );
        if (unresolved != null) {
          await dao.setHistoryBallEventId(
            id: unresolved.id,
            ballEventId: data.lastBallEventId!,
          );
        }
      }

      // An all-undo batch's response always carries a null
      // `lastBallEventId` (there is no "last ball" to report — one was
      // just removed) — falling back to the OLD baseline here, as the
      // ball/bowler branch below does, would wrongly keep pointing at the
      // ball that undo just erased. The ledger already reflects the
      // post-undo state (each undo pops its own row the moment it's
      // queued, not when it flushes), so its current top entry — if any
      // ball is left at all — is the correct new answer.
      final String? newLastBallEventId;
      if (isUndoRun) {
        final topOfLedger = await dao.latestHistoryEntry(
          matchId: matchId,
          inningsNumber: inningsNumber,
        );
        newLastBallEventId = topOfLedger?.ballEventId;
      } else {
        newLastBallEventId = data.lastBallEventId ?? baseline?.lastBallEventId;
      }

      await dao.upsertBaseline(
        SyncBaselineCompanion.insert(
          matchId: matchId,
          inningsNumber: inningsNumber,
          baseAbsoluteBallSeq: data.absoluteBallSeq,
          lastBallEventId: Value(newLastBallEventId),
        ),
      );

      // Set even on a partial apply: the events that DID commit
      // (everything before `failedAt`) really did change server state,
      // and the controller needs to reconcile up to that point rather
      // than keep showing a provisional preview that is now stale.
      lastAppliedState.value = data.state;

      if (data.failedAt != null) {
        // A genuine rule violation, not a transient failure — will fail
        // identically on retry, so this does not loop.
        phase.value = SyncPhase.blockedOnRule;
        lastError.value = data.failedCode;
        return;
      }

      phase.value = SyncPhase.idle;
      lastError.value = null;
      // Loop: more may remain if this batch hit the 120-event cap.
    }
  }
}
