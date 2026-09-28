import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_players_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/player_invite_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invite_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/player_invite_repository.dart';

class PlayerInviteRepositoryImpl extends PlayerInviteRepository {
  final MatchApiService matchApiService;

  PlayerInviteRepositoryImpl({required this.matchApiService});

  @override
  Future<Either<CricketResponse<MyPlayersRes>, CricketFailure>> getMyPlayers({
    required String teamId,
    String? q,
    required int page,
    required int limit,
  }) async => _parse(
    await matchApiService.getMyPlayers(
      teamId: teamId,
      q: q,
      page: page,
      limit: limit,
    ),
    MyPlayersRes.fromJson,
  );

  @override
  Future<Either<CricketResponse<LookedUpUserRes>, CricketFailure>>
  lookupUserByEmail({required String email}) async => _parse(
    await matchApiService.lookupUserByEmail(email: email),
    LookedUpUserRes.fromJson,
  );

  @override
  Future<Either<CricketResponse<TeamInviteRes>, CricketFailure>>
  inviteTeamPlayer({required String teamId, required String userId}) async =>
      _parse(
        await matchApiService.inviteTeamPlayer(teamId: teamId, userId: userId),
        TeamInviteRes.fromJson,
      );

  @override
  Future<Either<CricketResponse<TeamInvitesRes>, CricketFailure>>
  getTeamInvites({required String teamId}) async => _parse(
    await matchApiService.getTeamInvites(teamId: teamId),
    TeamInvitesRes.fromJson,
  );

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> cancelTeamInvite({
    required String teamId,
    required String inviteId,
  }) async {
    final response = await matchApiService.cancelTeamInvite(
      teamId: teamId,
      inviteId: inviteId,
    );
    if (response.isResult) {
      return Either.result(CricketResponse(message: response.result.message));
    }
    return Either.fallback(response.fallback);
  }

  @override
  Future<Either<CricketResponse<PlayerInviteRes>, CricketFailure>>
  getPlayerInvite({required String inviteId}) async => _parse(
    await matchApiService.getPlayerInvite(inviteId: inviteId),
    PlayerInviteRes.fromJson,
  );

  @override
  Future<Either<CricketResponse<PlayerInviteAnswerRes>, CricketFailure>>
  respondToPlayerInvite({
    required String inviteId,
    required bool accept,
  }) async => _parse(
    await matchApiService.respondToPlayerInvite(
      inviteId: inviteId,
      accept: accept,
    ),
    PlayerInviteAnswerRes.fromJson,
  );

  Either<CricketResponse<T>, CricketFailure> _parse<T>(
    Either<ApiResponseModel, CricketFailure> response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.isResult) {
      return Either.result(
        CricketResponse(
          data: fromJson(response.result.data as Map<String, dynamic>),
          message: response.result.message,
        ),
      );
    }
    return Either.fallback(response.fallback);
  }
}
