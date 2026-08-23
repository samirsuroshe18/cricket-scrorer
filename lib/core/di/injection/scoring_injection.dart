import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/socket_client_service.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_socket_service/match_socket_service.dart';
import 'package:cricket_scorer/features/scoring/data/match_endpoint.dart';
import 'package:cricket_scorer/features/scoring/data/repositories/match_repository_impl.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/score_ball.dart';
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

    Get.lazyPut<ScoreBallUseCase>(
      () => ScoreBallUseCase(matchRepository: Get.find<MatchRepository>()),
      fenix: true,
    );
  }
}
