import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/features/tournament/data/data_sources/remote/tournament_api_service.dart';
import 'package:cricket_scorer/features/tournament/data/tournament_endpoint.dart';
import 'package:cricket_scorer/features/tournament/data/repositories/tournament_repository_impl.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_standings.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_tournament.dart';
import 'package:get/get.dart';

class TournamentInjection {
  TournamentInjection._();

  static void init() {
    const tournamentEndpoint = TournamentEndpoint();

    Get.lazyPut<TournamentApiService>(
      () => TournamentApiService(
        apiClient: Get.find<ApiClient>(),
        tournamentEndpoint: tournamentEndpoint,
      ),
      fenix: true,
    );

    Get.lazyPut<TournamentRepository>(
      () => TournamentRepositoryImpl(
        tournamentApiService: Get.find<TournamentApiService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CreateTournamentUseCase>(
      () => CreateTournamentUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetTournamentUseCase>(
      () => GetTournamentUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<UpdateTournamentUseCase>(
      () => UpdateTournamentUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DeleteTournamentUseCase>(
      () => DeleteTournamentUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<EnrollTournamentTeamUseCase>(
      () => EnrollTournamentTeamUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RemoveTournamentTeamUseCase>(
      () => RemoveTournamentTeamUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GenerateFixturesUseCase>(
      () => GenerateFixturesUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetFixturesUseCase>(
      () => GetFixturesUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<StartFixtureMatchUseCase>(
      () => StartFixtureMatchUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ResolveFixtureUseCase>(
      () => ResolveFixtureUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetStandingsUseCase>(
      () => GetStandingsUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );
  }
}
