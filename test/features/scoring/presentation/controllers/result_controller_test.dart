import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_dao.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_database.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/offline_sync_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/public_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/scorecard_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorecard.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/start_innings.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/sync_match.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/result_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Answers `getScorecard` from a queue of controllable responses — the first
/// call's response only resolves once the test explicitly completes it, so a
/// second call fired while the first is still "in flight" is deterministic
/// rather than a timing guess. Every other `MatchRepository` method is
/// unused here — same `noSuchMethod` pattern `offline_sync_service_test.dart`
/// already uses for the same reason.
class _ControllableScorecardRepository implements MatchRepository {
  int callCount = 0;
  final _pendingCompleters = <Completer<Either<CricketResponse<ScorecardRes>, CricketFailure>>>[];

  @override
  Future<Either<CricketResponse<ScorecardRes>, CricketFailure>> getScorecard({
    required String matchId,
  }) {
    callCount += 1;
    final completer = Completer<Either<CricketResponse<ScorecardRes>, CricketFailure>>();
    _pendingCompleters.add(completer);
    return completer.future;
  }

  /// Resolves the Nth (0-indexed) call to `getScorecard` with a scorecard
  /// carrying [matchIdEcho] so the test can tell which response actually
  /// ended up applied.
  void resolve(int callIndex, String matchIdEcho) {
    _pendingCompleters[callIndex].complete(
      Either.result(
        CricketResponse(
          message: 'ok',
          data: ScorecardRes(
            matchId: matchIdEcho,
            teamA: PublicTeamRef(name: 'Team A'),
            teamB: PublicTeamRef(name: 'Team B'),
            result: null,
            innings: const [],
          ),
        ),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  // _phaseWorker's `ever<SyncPhase>` listener, the manual retry() button, and
  // onInit's own unawaited(_load()) can all fire _load() independently —
  // exactly the shape home_controller.dart's loadHistory() was fixed for.
  // Without a guard, two overlapping calls race independently and whichever
  // RESOLVES last — not whichever was triggered last — is what the screen
  // ends up showing.
  test(
    'a second _load() triggered while the first is still in flight is a '
    'no-op, not a second overlapping request',
    () async {
      final repo = _ControllableScorecardRepository();
      final db = ScoringQueueDatabase.forTesting(NativeDatabase.memory());
      final dao = ScoringQueueDao(db);
      final syncService = OfflineSyncService(
        dao: dao,
        syncMatchUseCase: SyncMatchUseCase(matchRepository: repo),
        startInningsUseCase: StartInningsUseCase(matchRepository: repo),
      );
      final controller = ResultController(
        getScorecardUseCase: GetScorecardUseCase(matchRepository: repo),
        offlineSyncService: syncService,
      );

      Get.testMode = true;
      Get.parameters = {'matchId': 'match-1'};

      // onInit fires the first _load() (unawaited) and leaves it in flight —
      // the fake repository never resolves until told to.
      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      expect(repo.callCount, 1);

      // The retry button (or the phase-worker's auto-retry) firing while
      // that first call is still unresolved.
      final retryFuture = controller.retry();

      expect(
        repo.callCount,
        1,
        reason:
            'a load already in flight must not let a second one start '
            'a competing request',
      );

      // Only now let the one real request resolve.
      repo.resolve(0, 'match-1');
      await retryFuture;
      await Future<void>.delayed(Duration.zero);

      expect(controller.scorecard.value?.matchId, 'match-1');
      expect(controller.isLoading.value, isFalse);

      await db.close();
    },
  );
}
