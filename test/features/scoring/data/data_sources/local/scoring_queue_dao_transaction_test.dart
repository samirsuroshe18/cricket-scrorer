import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_dao.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_database.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _pre = PreEventState(
  totalRuns: 0,
  wickets: 0,
  legalBalls: 0,
  totalBalls: 0,
  oversCompleted: 0,
  overTotalRuns: 0,
  overLegalDeliveries: 0,
);

/// Simulates the second statement of a two-part write failing partway
/// through — an app kill between the two, or (here, deterministically) any
/// other error `insertHistoryEntry` can throw. Only overriding this one
/// method, so `enqueueBall` above it in `enqueueBallWithHistory` still runs
/// for real.
class _HistoryWriteFailsDao extends ScoringQueueDao {
  _HistoryWriteFailsDao(super.db);

  @override
  Future<int> insertHistoryEntry({
    required String matchId,
    required int inningsNumber,
    required PreEventState pre,
    String? ballEventId,
  }) {
    throw Exception('simulated crash between the two writes');
  }
}

// `ScoreBallController._queueBallOffline` documents an invariant: a queued
// ball's QueuedSyncEvents row and its BallHistory ledger row are always
// inserted together. Before this fix they were two separate, independently-
// committed Drift statements (`dao.enqueueBall` then `dao.insertHistoryEntry`),
// so anything that broke between them — a process kill, or any other error —
// left an orphaned queue row with no matching ledger row. `_undoQueuedBall`
// then deletes whatever `latestBallHistory()` returns assuming it's this
// ball's pair, silently deleting an unrelated ledger entry when the pairing
// was torn. `enqueueBallWithHistory` wraps both inserts in one Drift
// transaction so they can only ever land, or fail, together.
void main() {
  test(
    'enqueueBallWithHistory rolls back the queue row too when the history write fails',
    () async {
      final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
      final dao = _HistoryWriteFailsDao(db);

      await expectLater(
        () => dao.enqueueBallWithHistory(
          matchId: 'match-1',
          inningsNumber: 1,
          req: ScoreBallReq(runs: 1, idempotencyKey: 'k1'),
          pre: _pre,
        ),
        throwsException,
      );

      final pending = await dao.pendingEvents(
        matchId: 'match-1',
        inningsNumber: 1,
      );
      expect(
        pending,
        isEmpty,
        reason:
            'the queue insert must not survive a failed paired history insert',
      );

      await db.close();
    },
  );

  test(
    'enqueueBallWithHistory inserts both rows together on the happy path',
    () async {
      final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
      final dao = ScoringQueueDao(db);

      await dao.enqueueBallWithHistory(
        matchId: 'match-1',
        inningsNumber: 1,
        req: ScoreBallReq(runs: 4, idempotencyKey: 'k1'),
        pre: _pre,
      );

      final pending = await dao.pendingEvents(
        matchId: 'match-1',
        inningsNumber: 1,
      );
      final history = await dao.latestHistoryEntry(
        matchId: 'match-1',
        inningsNumber: 1,
      );

      expect(pending, hasLength(1));
      expect(history, isNotNull);

      await db.close();
    },
  );
}
