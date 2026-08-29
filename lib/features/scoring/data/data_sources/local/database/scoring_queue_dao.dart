import 'dart:convert';

import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_database.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:drift/drift.dart';

part 'scoring_queue_dao.g.dart';

@DriftAccessor(
  tables: [
    QueuedSyncEvents,
    SyncBaseline,
    BallHistory,
    PendingStartInningsTable,
    InningsSummaries,
    ProvisionalMatchResults,
  ],
)
class ScoringQueueDao extends DatabaseAccessor<ScoringQueueDatabase>
    with _$ScoringQueueDaoMixin {
  ScoringQueueDao(super.db);

  /// A mixed batch (`SYNC_MIXED_BATCH`) is now avoided at flush time instead
  /// of here — see `OfflineSyncService._attemptSync`'s homogeneous-run
  /// grouping — so this no longer refuses when an undo is pending. What used
  /// to block further scoring after an offline undo of an already-synced
  /// ball is exactly what [BallHistory] now makes safe to allow.
  Future<int?> enqueueBall({
    required String matchId,
    required int inningsNumber,
    required ScoreBallReq req,
    required PreEventState pre,
  }) {
    return into(queuedSyncEvents).insert(
      QueuedSyncEventsCompanion.insert(
        matchId: matchId,
        inningsNumber: inningsNumber,
        eventType: SyncEventType.ball,
        idempotencyKey: Value(req.idempotencyKey),
        payloadJson: Value(jsonEncode(req.toJson())),
        preEventStateJson: Value(jsonEncode(pre.toJson())),
      ),
    );
  }

  /// See [enqueueBall]'s doc comment.
  Future<int?> enqueueBowler({
    required String matchId,
    required int inningsNumber,
    required SelectBowlerReq req,
    required PreEventState pre,
  }) {
    return into(queuedSyncEvents).insert(
      QueuedSyncEventsCompanion.insert(
        matchId: matchId,
        inningsNumber: inningsNumber,
        eventType: SyncEventType.bowler,
        payloadJson: Value(jsonEncode(req.toJson())),
        preEventStateJson: Value(jsonEncode(pre.toJson())),
      ),
    );
  }

  /// See [enqueueBall]'s doc comment.
  Future<int?> enqueueUndo({
    required String matchId,
    required int inningsNumber,
    required String ballEventId,
  }) {
    return into(queuedSyncEvents).insert(
      QueuedSyncEventsCompanion.insert(
        matchId: matchId,
        inningsNumber: inningsNumber,
        eventType: SyncEventType.undo,
        ballEventId: Value(ballEventId),
      ),
    );
  }

  Stream<List<QueuedSyncEvent>> watchQueue({
    required String matchId,
    required int inningsNumber,
  }) {
    return (select(queuedSyncEvents)
          ..where(
            (row) =>
                row.matchId.equals(matchId) &
                row.inningsNumber.equals(inningsNumber),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.id)]))
        .watch();
  }

  Future<List<QueuedSyncEvent>> pendingEvents({
    required String matchId,
    required int inningsNumber,
    int limit = 120,
  }) {
    return (select(queuedSyncEvents)
          ..where(
            (row) =>
                row.matchId.equals(matchId) &
                row.inningsNumber.equals(inningsNumber),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.id)])
          ..limit(limit))
        .get();
  }

  /// The most recently queued (never-synced) ball for this innings — the
  /// local-tail-undo target, checked before falling back to an `undo` sync
  /// event against an already-synced ball.
  Future<QueuedSyncEvent?> lastQueuedBall({
    required String matchId,
    required int inningsNumber,
  }) {
    return (select(queuedSyncEvents)
          ..where(
            (row) =>
                row.matchId.equals(matchId) &
                row.inningsNumber.equals(inningsNumber) &
                row.eventType.equalsValue(SyncEventType.ball),
          )
          ..orderBy([(row) => OrderingTerm.desc(row.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> deleteEvent(int id) {
    return (delete(queuedSyncEvents)..where((row) => row.id.equals(id))).go();
  }

  /// After a clean or partial sync: `appliedCount + skippedCount` events,
  /// from the front, are done with — either committed or already known to
  /// the server. Whatever is left (only on a partial apply) stays queued.
  Future<void> deleteAppliedPrefix({
    required String matchId,
    required int inningsNumber,
    required int count,
  }) async {
    if (count <= 0) return;

    final rows =
        await (select(queuedSyncEvents)
              ..where(
                (row) =>
                    row.matchId.equals(matchId) &
                    row.inningsNumber.equals(inningsNumber),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.id)])
              ..limit(count))
            .get();

    if (rows.isEmpty) return;

    await (delete(
      queuedSyncEvents,
    )..where((row) => row.id.isIn(rows.map((r) => r.id)))).go();
  }

  /// Conflict resolution: discard everything still queued for this innings.
  /// Only ever called after the scorer explicitly confirms — see
  /// `OfflineSyncService.discardQueueAndReload`.
  Future<void> clearQueue({
    required String matchId,
    required int inningsNumber,
  }) {
    return (delete(queuedSyncEvents)..where(
          (row) =>
              row.matchId.equals(matchId) &
              row.inningsNumber.equals(inningsNumber),
        ))
        .go();
  }

  Future<int> pendingCount({
    required String matchId,
    required int inningsNumber,
  }) async {
    final query = selectOnly(queuedSyncEvents)
      ..addColumns([queuedSyncEvents.id.count()])
      ..where(
        queuedSyncEvents.matchId.equals(matchId) &
            queuedSyncEvents.inningsNumber.equals(inningsNumber),
      );
    final row = await query.getSingle();
    return row.read(queuedSyncEvents.id.count()) ?? 0;
  }

  Future<void> upsertBaseline(SyncBaselineCompanion data) {
    return into(syncBaseline).insertOnConflictUpdate(data);
  }

  Future<SyncBaselineData?> baselineFor({
    required String matchId,
    required int inningsNumber,
  }) {
    return (select(syncBaseline)..where(
          (row) =>
              row.matchId.equals(matchId) &
              row.inningsNumber.equals(inningsNumber),
        ))
        .getSingleOrNull();
  }

  // ---------------------------------------------------------------------
  // BallHistory — the per-innings pre-state ledger behind chained offline
  // undo. See the table's own doc comment in scoring_queue_database.dart.
  // ---------------------------------------------------------------------

  /// Records one ball's pre-state. [ballEventId] is null for a ball that
  /// hasn't synced yet — see [oldestUnresolvedHistoryEntry] for how it gets
  /// backfilled, and `ScoreBallController._resolveUndoTargetId` for how undo
  /// still targets it if it's ever needed before that happens.
  Future<int> insertHistoryEntry({
    required String matchId,
    required int inningsNumber,
    required PreEventState pre,
    String? ballEventId,
  }) {
    return into(ballHistory).insert(
      BallHistoryCompanion.insert(
        matchId: matchId,
        inningsNumber: inningsNumber,
        preEventStateJson: jsonEncode(pre.toJson()),
        ballEventId: Value(ballEventId),
      ),
    );
  }

  /// Reactive count, for `ScoreBallController.canUndo` — mirrors
  /// [watchQueue]'s role for [pendingCount].
  Stream<List<BallHistoryEntry>> watchHistory({
    required String matchId,
    required int inningsNumber,
  }) {
    return (select(ballHistory)..where(
          (row) =>
              row.matchId.equals(matchId) &
              row.inningsNumber.equals(inningsNumber),
        ))
        .watch();
  }

  /// The most recent ball in this innings' local history — undo's target
  /// once nothing is left queued. Its own `preEventStateJson` is exactly the
  /// state to restore to after undoing it (the ledger stores each row's
  /// PRE-ball snapshot, same convention as `QueuedSyncEvents`).
  Future<BallHistoryEntry?> latestHistoryEntry({
    required String matchId,
    required int inningsNumber,
  }) {
    return (select(ballHistory)
          ..where(
            (row) =>
                row.matchId.equals(matchId) &
                row.inningsNumber.equals(inningsNumber),
          )
          ..orderBy([(row) => OrderingTerm.desc(row.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> deleteHistoryEntry(int id) {
    return (delete(ballHistory)..where((row) => row.id.equals(id))).go();
  }

  /// The oldest ball still waiting on a server id — always exactly the ball
  /// a ball/bowler flush just resolved, since rows are inserted in the same
  /// order their queue counterparts are, and a flush always processes the
  /// front of the queue first. See `OfflineSyncService._attemptSync`.
  Future<BallHistoryEntry?> oldestUnresolvedHistoryEntry({
    required String matchId,
    required int inningsNumber,
  }) {
    return (select(ballHistory)
          ..where(
            (row) =>
                row.matchId.equals(matchId) &
                row.inningsNumber.equals(inningsNumber) &
                row.ballEventId.isNull(),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Backfills the top-of-stack row's server id once a flush resolves one —
  /// see `OfflineSyncService._attemptSync`. Every other row is left null
  /// forever; nothing but the top of the stack is ever targeted.
  Future<void> setHistoryBallEventId({
    required int id,
    required String ballEventId,
  }) {
    return (update(ballHistory)..where((row) => row.id.equals(id))).write(
      BallHistoryCompanion(ballEventId: Value(ballEventId)),
    );
  }

  Future<int> historyCount({
    required String matchId,
    required int inningsNumber,
  }) async {
    final query = selectOnly(ballHistory)
      ..addColumns([ballHistory.id.count()])
      ..where(
        ballHistory.matchId.equals(matchId) &
            ballHistory.inningsNumber.equals(inningsNumber),
      );
    final row = await query.getSingle();
    return row.read(ballHistory.id.count()) ?? 0;
  }

  /// Innings/match boundary and conflict-discard cleanup — see the table's
  /// own doc comment on why stale history is unsafe to leave behind.
  Future<void> clearHistory({
    required String matchId,
    required int inningsNumber,
  }) {
    return (delete(ballHistory)..where(
          (row) =>
              row.matchId.equals(matchId) &
              row.inningsNumber.equals(inningsNumber),
        ))
        .go();
  }

  // ---------------------------------------------------------------------
  // PendingStartInningsTable — the local-only "open the next innings"
  // marker behind the offline innings-transition chain.
  // ---------------------------------------------------------------------

  Future<void> upsertPendingStartInnings(
    PendingStartInningsTableCompanion data,
  ) {
    return into(pendingStartInningsTable).insertOnConflictUpdate(data);
  }

  Future<PendingStartInnings?> pendingStartInningsFor({
    required String matchId,
    required int inningsNumber,
  }) {
    return (select(pendingStartInningsTable)..where(
          (row) =>
              row.matchId.equals(matchId) &
              row.inningsNumber.equals(inningsNumber),
        ))
        .getSingleOrNull();
  }

  Future<void> deletePendingStartInnings({
    required String matchId,
    required int inningsNumber,
  }) {
    return (delete(pendingStartInningsTable)..where(
          (row) =>
              row.matchId.equals(matchId) &
              row.inningsNumber.equals(inningsNumber),
        ))
        .go();
  }

  // ---------------------------------------------------------------------
  // InningsSummaries — an innings' final totals, kept past the point the
  // console resets its live fields for the next innings.
  // ---------------------------------------------------------------------

  Future<void> upsertInningsSummary(InningsSummariesCompanion data) {
    return into(inningsSummaries).insertOnConflictUpdate(data);
  }

  Future<InningsSummary?> inningsSummaryFor({
    required String matchId,
    required int inningsNumber,
  }) {
    return (select(inningsSummaries)..where(
          (row) =>
              row.matchId.equals(matchId) &
              row.inningsNumber.equals(inningsNumber),
        ))
        .getSingleOrNull();
  }

  // ---------------------------------------------------------------------
  // ProvisionalMatchResults — a locally-computed win/margin, held until the
  // real scorecard becomes fetchable.
  // ---------------------------------------------------------------------

  Future<void> upsertProvisionalResult(ProvisionalMatchResultsCompanion data) {
    return into(provisionalMatchResults).insertOnConflictUpdate(data);
  }

  Future<ProvisionalMatchResult?> provisionalResultFor(String matchId) {
    return (select(
      provisionalMatchResults,
    )..where((row) => row.matchId.equals(matchId))).getSingleOrNull();
  }

  Future<void> deleteProvisionalResult(String matchId) {
    return (delete(
      provisionalMatchResults,
    )..where((row) => row.matchId.equals(matchId))).go();
  }
}
