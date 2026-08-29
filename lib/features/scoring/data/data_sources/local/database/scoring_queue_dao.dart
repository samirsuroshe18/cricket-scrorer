import 'dart:convert';

import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_database.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/select_bowler_req.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:drift/drift.dart';

part 'scoring_queue_dao.g.dart';

@DriftAccessor(tables: [QueuedSyncEvents, SyncBaseline])
class ScoringQueueDao extends DatabaseAccessor<ScoringQueueDatabase>
    with _$ScoringQueueDaoMixin {
  ScoringQueueDao(super.db);

  /// Refuses (returns null) if an undo row is already pending for this
  /// innings — a batch is either all-undo or contains no undo at all (the
  /// server rejects a mixed batch outright with `SYNC_MIXED_BATCH`), and
  /// [enqueueUndo]'s own refusal only ever enforced this one-directionally.
  /// A ball queued after an undo — e.g. undo a synced ball offline, then
  /// keep scoring before the undo has flushed — hit that gap for real: the
  /// mixed batch it produced synced-looped forever with no error surfaced.
  Future<int?> enqueueBall({
    required String matchId,
    required int inningsNumber,
    required ScoreBallReq req,
    required PreEventState pre,
  }) async {
    if (await _hasPendingUndo(matchId: matchId, inningsNumber: inningsNumber)) {
      return null;
    }
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

  /// See [enqueueBall]'s doc comment — same refusal, same reason.
  Future<int?> enqueueBowler({
    required String matchId,
    required int inningsNumber,
    required SelectBowlerReq req,
    required PreEventState pre,
  }) async {
    if (await _hasPendingUndo(matchId: matchId, inningsNumber: inningsNumber)) {
      return null;
    }
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

  /// Refuses (returns null) if any non-undo row is still pending for this
  /// innings — a batch is either all-undo or contains no undo at all, and
  /// this is where that invariant is enforced, at the source, rather than
  /// ad hoc wherever a batch happens to be built.
  Future<int?> enqueueUndo({
    required String matchId,
    required int inningsNumber,
    required String ballEventId,
  }) async {
    final hasNonUndo =
        await (select(queuedSyncEvents)..where(
              (row) =>
                  row.matchId.equals(matchId) &
                  row.inningsNumber.equals(inningsNumber) &
                  (row.eventType.equalsValue(SyncEventType.ball) |
                      row.eventType.equalsValue(SyncEventType.bowler)),
            ))
            .get();

    if (hasNonUndo.isNotEmpty) return null;

    return into(queuedSyncEvents).insert(
      QueuedSyncEventsCompanion.insert(
        matchId: matchId,
        inningsNumber: inningsNumber,
        eventType: SyncEventType.undo,
        ballEventId: Value(ballEventId),
      ),
    );
  }

  Future<bool> _hasPendingUndo({
    required String matchId,
    required int inningsNumber,
  }) async {
    final rows =
        await (select(queuedSyncEvents)..where(
              (row) =>
                  row.matchId.equals(matchId) &
                  row.inningsNumber.equals(inningsNumber) &
                  row.eventType.equalsValue(SyncEventType.undo),
            ))
            .get();
    return rows.isNotEmpty;
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

    final rows = await (select(queuedSyncEvents)
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
}
