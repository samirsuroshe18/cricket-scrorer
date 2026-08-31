import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_dao.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_database.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/offline_sync_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/score_ball_req.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/start_innings.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/sync_match.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Never called in these tests — `watch()`/`unwatch()` do no network I/O —
/// `noSuchMethod` is what lets this satisfy the (large) `MatchRepository`
/// interface without implementing every method by hand.
class _UnusedMatchRepository implements MatchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

const _pre = PreEventState(
  totalRuns: 0,
  wickets: 0,
  legalBalls: 0,
  totalBalls: 0,
  oversCompleted: 0,
  overTotalRuns: 0,
  overLegalDeliveries: 0,
);

void main() {
  late ScoringQueueDatabase db;
  late ScoringQueueDao dao;
  late OfflineSyncService service;

  setUp(() {
    final repo = _UnusedMatchRepository();
    db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
    dao = ScoringQueueDao(db);
    service = OfflineSyncService(
      dao: dao,
      syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
      startInningsUseCase: StartInningsUseCase(matchRepository: repo),
    );
  });

  tearDown(() async {
    await db.close();
  });

  // The bug: pendingCount/queuedBallCount/historyCount are plain fields that
  // only Drift's own (asynchronous) stream emission ever updates — nothing
  // reset them synchronously when watch() moved on to a different scope, so
  // they kept whatever the *previous* match/innings left them at for the
  // entire gap before that first emission landed.
  test(
    'watch() zeroes pendingCount/queuedBallCount/historyCount synchronously, '
    'before the new scope\'s own stream has emitted anything',
    () async {
      await dao.enqueueBall(
        matchId: 'match-1',
        inningsNumber: 1,
        req: ScoreBallReq(runs: 1, idempotencyKey: 'k1'),
        pre: _pre,
      );
      await dao.insertHistoryEntry(
        matchId: 'match-1',
        inningsNumber: 1,
        pre: _pre,
      );

      service.watch(matchId: 'match-1', inningsNumber: 1);
      await pumpEventQueue();

      expect(service.pendingCount.value, 1);
      expect(service.queuedBallCount.value, 1);
      expect(service.historyCount.value, 1);

      // Switching to a brand-new match/innings with nothing queued at all —
      // before the fix, all three fields would still read match-1's values
      // right here, synchronously, until this new watch's own Drift stream
      // eventually emitted its first (empty) snapshot.
      service.watch(matchId: 'match-2', inningsNumber: 1);

      expect(
        service.pendingCount.value,
        0,
        reason:
            'a scorer opening match-2 must never see match-1\'s queued-ball '
            'count, even for the brief window before the new stream emits',
      );
      expect(service.queuedBallCount.value, 0);
      expect(service.historyCount.value, 0);

      // The new scope's own (empty) reality still arrives correctly once the
      // stream actually emits.
      await pumpEventQueue();
      expect(service.pendingCount.value, 0);
      expect(service.queuedBallCount.value, 0);
      expect(service.historyCount.value, 0);
    },
  );

  test(
    'unwatch() zeroes the same three counters, so nothing between one '
    'match\'s unwatch() and the next match\'s watch() can read stale values',
    () async {
      await dao.enqueueBall(
        matchId: 'match-1',
        inningsNumber: 1,
        req: ScoreBallReq(runs: 1, idempotencyKey: 'k1'),
        pre: _pre,
      );
      await dao.insertHistoryEntry(
        matchId: 'match-1',
        inningsNumber: 1,
        pre: _pre,
      );

      service.watch(matchId: 'match-1', inningsNumber: 1);
      await pumpEventQueue();
      expect(service.pendingCount.value, 1);

      service.unwatch();

      expect(service.pendingCount.value, 0);
      expect(service.queuedBallCount.value, 0);
      expect(service.historyCount.value, 0);
    },
  );
}
