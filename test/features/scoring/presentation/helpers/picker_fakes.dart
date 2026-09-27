import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_players_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invite_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_players.dart';
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

class FakeLookupUserByEmailUseCase implements LookupUserByEmailUseCase {
  Either<CricketResponse<LookedUpUserRes>, CricketFailure>? response;
  final calls = <LookupUserParams>[];

  @override
  Future<Either<CricketResponse<LookedUpUserRes>, CricketFailure>> call({
    LookupUserParams? params,
  }) async {
    calls.add(params!);
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
