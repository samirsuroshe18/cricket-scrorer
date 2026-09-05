import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/socket_client_service.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_dao.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/database/scoring_queue_database.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/offline_sync_service.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_socket_service/match_socket_service.dart';
import 'package:cricket_scorer/features/scoring/data/match_endpoint.dart';
import 'package:cricket_scorer/features/scoring/data/repositories/match_repository_impl.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/score_ball.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/select_bowler.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/start_innings.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/sync_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/undo_ball.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/abandon_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_history.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_public_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorecard.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_career_stats.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:get/get.dart';

class ScoringInjection {
  ScoringInjection._();

  static void init() {
    const matchEndpoint = MatchEndpoint();

    Get.lazyPut<MatchApiService>(
      () => MatchApiService(
        apiClient: Get.find<ApiClient>(),
        matchEndpoint: matchEndpoint,
      ),
      fenix: true,
    );

    Get.lazyPut<MatchSocketService>(
      () => MatchSocketService(
        socketClientService: Get.find<SocketClientService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<MatchRepository>(
      () => MatchRepositoryImpl(
        matchApiService: Get.find<MatchApiService>(),
        matchSocketService: Get.find<MatchSocketService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CreateMatchUseCase>(
      () => CreateMatchUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<StartInningsUseCase>(
      () => StartInningsUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<SelectBowlerUseCase>(
      () => SelectBowlerUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<ScoreBallUseCase>(
      () => ScoreBallUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<UndoBallUseCase>(
      () => UndoBallUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetPublicMatchUseCase>(
      () => GetPublicMatchUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetScorecardUseCase>(
      () => GetScorecardUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetCareerStatsUseCase>(
      () => GetCareerStatsUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetMatchHistoryUseCase>(
      () =>
          GetMatchHistoryUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetMyTeamsUseCase>(
      () => GetMyTeamsUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetTeamProfileUseCase>(
      () => GetTeamProfileUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetTeamMatchesUseCase>(
      () => GetTeamMatchesUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<AbandonMatchUseCase>(
      () => AbandonMatchUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<DeleteMatchUseCase>(
      () => DeleteMatchUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<SyncMatchUseCase>(
      () => SyncMatchUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetScorerCandidatesUseCase>(
      () => GetScorerCandidatesUseCase(
        matchRepository: Get.find<MatchRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AssignScorerUseCase>(
      () => AssignScorerUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );

    // The offline queue's local database and the service that owns it —
    // feature-scoped, not core: see this file's own convention and the
    // client CLAUDE.md's "don't register feature dependencies in
    // CoreInjection". No async init needed (Drift's LazyDatabase defers the
    // real file I/O to first query on its own), so a plain lazyPut is
    // enough — the queue/lifecycle-listener/connectivity-subscription only
    // start existing once a match screen first resolves them.
    Get.lazyPut<ScoringQueueDatabase>(
      () => ScoringQueueDatabase(),
      fenix: true,
    );

    Get.lazyPut<ScoringQueueDao>(
      () => ScoringQueueDao(Get.find<ScoringQueueDatabase>()),
      fenix: true,
    );

    Get.lazyPut<OfflineSyncService>(
      () => OfflineSyncService(
        dao: Get.find<ScoringQueueDao>(),
        syncMatchUseCase: Get.find<SyncMatchUseCase>(),
        startInningsUseCase: Get.find<StartInningsUseCase>(),
      ),
      fenix: true,
    );
  }
}
