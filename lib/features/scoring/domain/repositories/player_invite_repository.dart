import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_players_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/player_invite_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invite_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';

/// The add-player picker's data (the caller's own players, finding an app user
/// by email, inviting them) and the invitee's side of a player invite. A
/// separate contract from [TeamRepository] so adding to it never touches the
/// test doubles that stand in for that one.
abstract class PlayerInviteRepository {
  /// `GET /v1/player` — the caller's own players, flagged `onTeam` for [teamId].
  Future<Either<CricketResponse<MyPlayersRes>, CricketFailure>> getMyPlayers({
    required String teamId,
    String? q,
    required int page,
    required int limit,
  });

  /// `GET /v1/user/lookup` — one account by exact email.
  Future<Either<CricketResponse<LookedUpUserRes>, CricketFailure>>
  lookupUserByEmail({required String email});

  /// `POST /v1/team/:teamId/invites`.
  Future<Either<CricketResponse<TeamInviteRes>, CricketFailure>>
  inviteTeamPlayer({required String teamId, required String userId});

  /// `GET /v1/team/:teamId/invites` — the scorer's view: one row per invitee.
  Future<Either<CricketResponse<TeamInvitesRes>, CricketFailure>>
  getTeamInvites({required String teamId});

  /// `DELETE /v1/team/:teamId/invites/:inviteId` — withdraw a pending invite.
  Future<Either<CricketResponse<void>, CricketFailure>> cancelTeamInvite({
    required String teamId,
    required String inviteId,
  });

  /// `GET /v1/player-invite/:inviteId`.
  Future<Either<CricketResponse<PlayerInviteRes>, CricketFailure>>
  getPlayerInvite({required String inviteId});

  /// `POST /v1/player-invite/:inviteId/accept` (or `/decline` when
  /// [accept] is false).
  Future<Either<CricketResponse<PlayerInviteAnswerRes>, CricketFailure>>
  respondToPlayerInvite({required String inviteId, required bool accept});
}
