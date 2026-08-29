import 'dart:async';
import 'dart:convert';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_dao.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_database.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/sync_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/undo_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/sync_res.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/ball_outcome_preview.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
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
  OfflineSyncService({required this.dao, required this.syncMatchUseCase});

  final ScoringQueueDao dao;
  final SyncMatchUseCase syncMatchUseCase;

  final RxInt pendingCount = 0.obs;
  final Rx<SyncPhase> phase = SyncPhase.idle.obs;
  final Rxn<String> lastError = Rxn<String>();

  /// The `state` snapshot from the most recent successful `/sync` response —
  /// exactly the same complete-state shape `undo-ball` returns. The
  /// controller listens for this to reconcile its provisional display back
  /// to real server truth once a flush actually lands, without needing a
  /// separate re-fetch: the sync response already carries everything.
  final Rxn<SyncState> lastAppliedState = Rxn<SyncState>();

  AppLifecycleListener? _lifecycleListener;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<List<QueuedSyncEvent>>? _queueSub;

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
    _queueSub =
        dao
            .watchQueue(matchId: matchId, inningsNumber: inningsNumber)
            .listen((rows) => pendingCount.value = rows.length);
  }

  /// Stops watching a match's queue — does NOT stop background flush
  /// attempts already in flight, and a later [watch] for the same innings
  /// picks the queue up exactly where it was.
  void unwatch() {
    unawaited(_queueSub?.cancel());
    _queueSub = null;
    _watchedMatchId = null;
    _watchedInningsNumber = null;
    phase.value = SyncPhase.idle;
    lastError.value = null;
  }

  /// False means a still-pending undo refused this — see
  /// [ScoringQueueDao.enqueueBall]'s own doc comment for why the queue can
  /// never hold both.
  Future<bool> enqueueBall({
    required String matchId,
    required int inningsNumber,
    required ScoreBallReq req,
    required PreEventState pre,
  }) async {
    final id = await dao.enqueueBall(
      matchId: matchId,
      inningsNumber: inningsNumber,
      req: req,
      pre: pre,
    );
    return id != null;
  }

  /// See [enqueueBall]'s doc comment — same refusal, same reason.
  Future<bool> enqueueBowler({
    required String matchId,
    required int inningsNumber,
    required SelectBowlerReq req,
    required PreEventState pre,
  }) async {
    final id = await dao.enqueueBowler(
      matchId: matchId,
      inningsNumber: inningsNumber,
      req: req,
      pre: pre,
    );
    return id != null;
  }

  /// False means the queue holds a still-unsynced ball/bowler event and the
  /// all-undo-or-no-undo invariant refused this one — the caller should
  /// flush what's queued before an undo of an already-synced ball can be
  /// queued too.
  Future<bool> enqueueUndo({
    required String matchId,
    required int inningsNumber,
    required String ballEventId,
  }) async {
    final id = await dao.enqueueUndo(
      matchId: matchId,
      inningsNumber: inningsNumber,
      ballEventId: ballEventId,
    );
    return id != null;
  }

  Future<void> deleteQueuedEvent(int id) => dao.deleteEvent(id);

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
  Future<void> discardQueueAndReload({
    required String matchId,
    required int inningsNumber,
  }) async {
    await dao.clearQueue(matchId: matchId, inningsNumber: inningsNumber);
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
      // Loops so a >120-event stretch (chunked by the server's own cap)
      // flushes in one trigger rather than needing N separate wakeups.
      while (true) {
        final events = await dao.pendingEvents(
          matchId: matchId,
          inningsNumber: inningsNumber,
        );
        if (events.isEmpty) {
          phase.value = SyncPhase.idle;
          return;
        }

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
              events: events.map(_toWireEvent).toList(),
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

        await dao.upsertBaseline(
          SyncBaselineCompanion.insert(
            matchId: matchId,
            inningsNumber: inningsNumber,
            baseAbsoluteBallSeq: data.absoluteBallSeq,
            lastBallEventId: Value(
              data.lastBallEventId ?? baseline?.lastBallEventId,
            ),
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
    } finally {
      _syncing = false;
    }
  }
}
