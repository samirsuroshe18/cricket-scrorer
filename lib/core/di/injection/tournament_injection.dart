import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/socket_client_service.dart';
import 'package:cricket_scorer/features/tournament/data/data_sources/remote/auction_socket_service/auction_socket_service.dart';
import 'package:cricket_scorer/features/tournament/data/data_sources/remote/tournament_api_service.dart';
import 'package:cricket_scorer/features/tournament/data/tournament_endpoint.dart';
import 'package:cricket_scorer/features/tournament/data/repositories/tournament_repository_impl.dart';
import 'package:cricket_scorer/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/create_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/delete_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/enroll_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/generate_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/next_auction_lot.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/pause_auction.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resume_auction.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_auction.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_auction_history.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_auction_setup.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_auction_squad.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_fixtures.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_leaderboards.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_pool.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_standings.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/get_tournament.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/register_pool_player.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_pool_entry.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/remove_tournament_team.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/resolve_fixture.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/set_auction_setup.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/start_fixture_match.dart';
import 'package:cricket_scorer/features/tournament/domain/usecases/update_pool_entry.dart';
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

    Get.lazyPut<AuctionSocketService>(
      () => AuctionSocketService(
        socketClientService: Get.find<SocketClientService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<TournamentRepository>(
      () => TournamentRepositoryImpl(
        tournamentApiService: Get.find<TournamentApiService>(),
        auctionSocketService: Get.find<AuctionSocketService>(),
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

    Get.lazyPut<GetLeaderboardsUseCase>(
      () => GetLeaderboardsUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RegisterPoolPlayerUseCase>(
      () => RegisterPoolPlayerUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetPoolUseCase>(
      () => GetPoolUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<UpdatePoolEntryUseCase>(
      () => UpdatePoolEntryUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RemovePoolEntryUseCase>(
      () => RemovePoolEntryUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<SetAuctionSetupUseCase>(
      () => SetAuctionSetupUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetAuctionSetupUseCase>(
      () => GetAuctionSetupUseCase(
        tournamentRepository: Get.find<TournamentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<StartAuctionUseCase>(
      () => StartAuctionUseCase(tournamentRepository: Get.find<TournamentRepository>()),
      fenix: true,
    );

    Get.lazyPut<PauseAuctionUseCase>(
      () => PauseAuctionUseCase(tournamentRepository: Get.find<TournamentRepository>()),
      fenix: true,
    );

    Get.lazyPut<ResumeAuctionUseCase>(
      () => ResumeAuctionUseCase(tournamentRepository: Get.find<TournamentRepository>()),
      fenix: true,
    );

    Get.lazyPut<NextAuctionLotUseCase>(
      () => NextAuctionLotUseCase(tournamentRepository: Get.find<TournamentRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetAuctionSquadUseCase>(
      () => GetAuctionSquadUseCase(tournamentRepository: Get.find<TournamentRepository>()),
      fenix: true,
    );

    Get.lazyPut<GetAuctionHistoryUseCase>(
      () => GetAuctionHistoryUseCase(tournamentRepository: Get.find<TournamentRepository>()),
      fenix: true,
    );
  }
}
