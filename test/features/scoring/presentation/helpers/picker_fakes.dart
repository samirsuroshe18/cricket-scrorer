import 'dart:async';

import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_players_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invite_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/add_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_players.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/set_team_leadership.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_logo.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_player.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/invite_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/lookup_user_by_email.dart';

/// Configurable stand-ins for the add-player picker's three use cases. A test
/// that never opens the picker just constructs them and leaves `response`
/// unset; calling one without a response fails loudly.
class FakeGetMyPlayersUseCase implements GetMyPlayersUseCase {
  Either<CricketResponse<MyPlayersRes>, CricketFailure>? response;
  final calls = <GetMyPlayersParams>[];

  @override
  Future<Either<CricketResponse<MyPlayersRes>, CricketFailure>> call({
    GetMyPlayersParams? params,
  }) async {
    calls.add(params!);
    return response ?? (throw UnimplementedError('No response set.'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// A [FakeGetMyPlayersUseCase] that answers with no players, for tests that
/// open the picker but are about something else.
FakeGetMyPlayersUseCase emptyMyPlayers() =>
    FakeGetMyPlayersUseCase()
      ..response = Either.result(
        CricketResponse(
          message: 'ok',
          data: MyPlayersRes(players: const [], page: 1, limit: 20, total: 0),
        ),
      );

class FakeLookupUserByEmailUseCase implements LookupUserByEmailUseCase {
  Either<CricketResponse<LookedUpUserRes>, CricketFailure>? response;
  final calls = <LookupUserParams>[];

  /// When set, a call waits for it to complete before answering, so a test can
  /// hold a lookup in flight.
  Completer<void>? gate;

  @override
  Future<Either<CricketResponse<LookedUpUserRes>, CricketFailure>> call({
    LookupUserParams? params,
  }) async {
    calls.add(params!);
    await gate?.future;
    return response ?? (throw UnimplementedError('No response set.'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class FakeInviteTeamPlayerUseCase implements InviteTeamPlayerUseCase {
  Either<CricketResponse<TeamInviteRes>, CricketFailure>? response;
  final calls = <InviteTeamPlayerParams>[];

  @override
  Future<Either<CricketResponse<TeamInviteRes>, CricketFailure>> call({
    InviteTeamPlayerParams? params,
  }) async {
    calls.add(params!);
    return response ?? (throw UnimplementedError('No response set.'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class FakeAddTeamPlayerUseCase implements AddTeamPlayerUseCase {
  Either<CricketResponse<TeamRosterPlayer>, CricketFailure>? response;
  final calls = <AddTeamPlayerParams>[];

  @override
  Future<Either<CricketResponse<TeamRosterPlayer>, CricketFailure>> call({
    AddTeamPlayerParams? params,
  }) async {
    calls.add(params!);
    return response ??
        Either.result(
          CricketResponse(
            message: 'ok',
            data: TeamRosterPlayer(
              playerId: params.req.playerId ?? 'new',
              playerName: params.req.name ?? 'Existing',
              role: 'unknown',
            ),
          ),
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedGetTeamProfile implements GetTeamProfileUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedGetTeamMatches implements GetTeamMatchesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedGetScorerCandidates implements GetScorerCandidatesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedAssignScorer implements AssignScorerUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedUpdateTeamLogo implements UpdateTeamLogoUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedUpdateTeam implements UpdateTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedDeleteTeam implements DeleteTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedUpdateTeamPlayer implements UpdateTeamPlayerUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedSetTeamLeadership implements SetTeamLeadershipUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// A real [TeamProfileController] wired to fakes for the picker's use cases and
/// an inert stand-in for everything else. `getTeamProfileUseCase` throws when
/// called, which `loadProfile` already catches, so a successful roster write
/// still returns no error.
TeamProfileController buildPickerTestController({
  required FakeGetMyPlayersUseCase myPlayers,
  required FakeLookupUserByEmailUseCase lookup,
  required FakeInviteTeamPlayerUseCase invite,
  required FakeAddTeamPlayerUseCase add,
}) {
  return TeamProfileController(
    teamId: 'team-1',
    getTeamProfileUseCase: _UnusedGetTeamProfile(),
    getTeamMatchesUseCase: _UnusedGetTeamMatches(),
    getScorerCandidatesUseCase: _UnusedGetScorerCandidates(),
    assignScorerUseCase: _UnusedAssignScorer(),
    updateTeamLogoUseCase: _UnusedUpdateTeamLogo(),
    updateTeamUseCase: _UnusedUpdateTeam(),
    deleteTeamUseCase: _UnusedDeleteTeam(),
    addTeamPlayerUseCase: add,
    updateTeamPlayerUseCase: _UnusedUpdateTeamPlayer(),
    setTeamLeadershipUseCase: _UnusedSetTeamLeadership(),
    getMyPlayersUseCase: myPlayers,
    lookupUserByEmailUseCase: lookup,
    inviteTeamPlayerUseCase: invite,
  );
}
