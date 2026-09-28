import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/cancel_team_invite.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_squad.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_invites.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_playing_xi.dart';

// Test doubles for the squad-read, playing-xi and team-invite use cases, shared
// by the Squad controller and screen tests. Each `noSuchMethod` throws so a
// test can never silently depend on something it did not stub.

class FakeGetMatchSquad implements GetMatchSquadUseCase {
  /// Null means the fetch fails, so the controller must fall back to rosters.
  MatchSquadRes? squad;
  int calls = 0;

  @override
  Future<Either<CricketResponse<MatchSquadRes>, CricketFailure>> call({
    GetMatchSquadParams? params,
  }) async {
    calls++;
    final data = squad;
    if (data == null) return Either.fallback(CricketFailure(message: 'down'));
    return Either.result(CricketResponse(message: 'ok', data: data));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class FakeSavePlayingXi implements SavePlayingXiUseCase {
  final List<SavePlayingXiParams> calls = [];
  bool fail = false;

  @override
  Future<Either<CricketResponse<SquadSideRes>, CricketFailure>> call({
    SavePlayingXiParams? params,
  }) async {
    calls.add(params!);
    if (fail) return Either.fallback(CricketFailure(message: 'xi refused'));
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: SquadSideRes(teamId: 't', playingXI: params.req.playingXI),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class FakeGetTeamInvites implements GetTeamInvitesUseCase {
  final Map<String, List<TeamInviteItemRes>> byTeam;
  final List<String> asked = [];

  FakeGetTeamInvites(this.byTeam);

  @override
  Future<Either<CricketResponse<TeamInvitesRes>, CricketFailure>> call({
    GetTeamInvitesParams? params,
  }) async {
    asked.add(params!.teamId);
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: TeamInvitesRes(invites: byTeam[params.teamId] ?? const []),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class FakeCancelTeamInvite implements CancelTeamInviteUseCase {
  final List<CancelTeamInviteParams> calls = [];
  bool fail = false;

  /// Runs on success so a test can change what the next invites fetch returns.
  void Function()? onSuccess;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> call({
    CancelTeamInviteParams? params,
  }) async {
    calls.add(params!);
    if (fail) return Either.fallback(CricketFailure(message: 'cancel refused'));
    onSuccess?.call();
    return Either.result(const CricketResponse(message: 'ok'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}
