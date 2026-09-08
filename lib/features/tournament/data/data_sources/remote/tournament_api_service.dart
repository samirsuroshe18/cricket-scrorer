import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/create_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/enroll_tournament_team_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/register_pool_player_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/resolve_fixture_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_pool_entry_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/start_fixture_match_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_auction_setup_req.dart';
import 'package:cricket_scorer/features/tournament/data/models/request/update_tournament_req.dart';
import 'package:cricket_scorer/features/tournament/data/tournament_endpoint.dart';

class TournamentApiService {
  final ApiClient apiClient;
  final TournamentEndpoint tournamentEndpoint;

  TournamentApiService({required this.apiClient, required this.tournamentEndpoint});

  Future<Either<ApiResponseModel, CricketFailure>> createTournament({
    required String orgId,
    required CreateTournamentReq? params,
  }) async {
    return await apiClient.post(
      endpoint: tournamentEndpoint.createUnderOrg(orgId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getTournament({
    required String tournamentId,
  }) async {
    return await apiClient.get(endpoint: tournamentEndpoint.detail(tournamentId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> updateTournament({
    required String tournamentId,
    required UpdateTournamentReq params,
  }) async {
    return await apiClient.patch(
      endpoint: tournamentEndpoint.update(tournamentId),
      data: params.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> deleteTournament({
    required String tournamentId,
  }) async {
    return await apiClient.delete(endpoint: tournamentEndpoint.delete(tournamentId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> enrollTeam({
    required String tournamentId,
    required EnrollTournamentTeamReq? params,
  }) async {
    return await apiClient.post(
      endpoint: tournamentEndpoint.addTeam(tournamentId),
      data: params?.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> removeTeam({
    required String tournamentId,
    required String teamId,
  }) async {
    return await apiClient.delete(
      endpoint: tournamentEndpoint.removeTeam(tournamentId, teamId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> generateFixtures({
    required String tournamentId,
  }) async {
    return await apiClient.post(
      endpoint: tournamentEndpoint.fixtures(tournamentId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getFixtures({
    required String tournamentId,
  }) async {
    return await apiClient.get(
      endpoint: tournamentEndpoint.fixtures(tournamentId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> startFixtureMatch({
    required String tournamentId,
    required String fixtureId,
    required StartFixtureMatchReq params,
  }) async {
    return await apiClient.post(
      endpoint: tournamentEndpoint.startFixtureMatch(tournamentId, fixtureId),
      data: params.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> resolveFixture({
    required String tournamentId,
    required String fixtureId,
    required ResolveFixtureReq params,
  }) async {
    return await apiClient.patch(
      endpoint: tournamentEndpoint.resolveFixture(tournamentId, fixtureId),
      data: params.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getStandings({
    required String tournamentId,
  }) async {
    return await apiClient.get(
      endpoint: tournamentEndpoint.standings(tournamentId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getLeaderboards({
    required String tournamentId,
  }) async {
    return await apiClient.get(
      endpoint: tournamentEndpoint.leaderboards(tournamentId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> registerPoolPlayer({
    required String tournamentId,
    required RegisterPoolPlayerReq params,
  }) async {
    return await apiClient.post(
      endpoint: tournamentEndpoint.pool(tournamentId),
      data: params.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getPool({
    required String tournamentId,
  }) async {
    return await apiClient.get(endpoint: tournamentEndpoint.pool(tournamentId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> updatePoolEntry({
    required String tournamentId,
    required String playerId,
    required UpdatePoolEntryReq params,
  }) async {
    return await apiClient.patch(
      endpoint: tournamentEndpoint.poolEntry(tournamentId, playerId),
      data: params.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> removePoolEntry({
    required String tournamentId,
    required String playerId,
  }) async {
    return await apiClient.delete(
      endpoint: tournamentEndpoint.poolEntry(tournamentId, playerId),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> setAuctionSetup({
    required String tournamentId,
    required UpdateAuctionSetupReq params,
  }) async {
    return await apiClient.patch(
      endpoint: tournamentEndpoint.auctionSetup(tournamentId),
      data: params.toJson(),
    );
  }

  Future<Either<ApiResponseModel, CricketFailure>> getAuctionSetup({
    required String tournamentId,
  }) async {
    return await apiClient.get(endpoint: tournamentEndpoint.auctionSetup(tournamentId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> startAuction({
    required String tournamentId,
  }) async {
    return await apiClient.post(endpoint: tournamentEndpoint.auctionStart(tournamentId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> pauseAuction({
    required String tournamentId,
  }) async {
    return await apiClient.post(endpoint: tournamentEndpoint.auctionPause(tournamentId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> resumeAuction({
    required String tournamentId,
  }) async {
    return await apiClient.post(endpoint: tournamentEndpoint.auctionResume(tournamentId));
  }

  Future<Either<ApiResponseModel, CricketFailure>> nextAuctionLot({
    required String tournamentId,
  }) async {
    return await apiClient.post(endpoint: tournamentEndpoint.auctionNext(tournamentId));
  }
}
