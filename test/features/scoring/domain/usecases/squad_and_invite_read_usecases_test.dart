import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_playing_xi_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_squad_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/player_invite_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/squad_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/cancel_team_invite.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_match_squad.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_invites.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/save_playing_xi.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSquadRepository implements SquadRepository {
  final calls = <String, Object?>{};

  @override
  Future<Either<CricketResponse<MatchSquadRes>, CricketFailure>> getMatchSquad({
    required String matchId,
  }) async {
    calls['getMatchSquad'] = matchId;
    return Either.fallback(CricketFailure(message: 'x'));
  }

  @override
  Future<Either<CricketResponse<SquadSideRes>, CricketFailure>> savePlayingXi({
    required String matchId,
    required SavePlayingXiReq params,
  }) async {
    calls['savePlayingXi'] = (matchId, params);
    return Either.fallback(CricketFailure(message: 'x'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeInviteRepository implements PlayerInviteRepository {
  final calls = <String, Object?>{};

  @override
  Future<Either<CricketResponse<TeamInvitesRes>, CricketFailure>>
  getTeamInvites({required String teamId}) async {
    calls['getTeamInvites'] = teamId;
    return Either.fallback(CricketFailure(message: 'x'));
  }

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> cancelTeamInvite({
    required String teamId,
    required String inviteId,
  }) async {
    calls['cancelTeamInvite'] = (teamId, inviteId);
    return Either.fallback(CricketFailure(message: 'x'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  test('GetMatchSquadUseCase forwards the match id', () async {
    final repository = _FakeSquadRepository();

    await GetMatchSquadUseCase(squadRepository: repository)(
      params: GetMatchSquadParams(matchId: 'm1'),
    );

    expect(repository.calls['getMatchSquad'], 'm1');
  });

  test(
    'SavePlayingXiUseCase forwards the match id and the same request',
    () async {
      final repository = _FakeSquadRepository();
      final req = SavePlayingXiReq(side: 'teamB', playingXI: ['p1']);

      await SavePlayingXiUseCase(squadRepository: repository)(
        params: SavePlayingXiParams(matchId: 'm1', req: req),
      );

      final (matchId, sent) =
          repository.calls['savePlayingXi']! as (String, SavePlayingXiReq);
      expect(matchId, 'm1');
      expect(sent, same(req));
    },
  );

  test('GetTeamInvitesUseCase forwards the team id', () async {
    final repository = _FakeInviteRepository();

    await GetTeamInvitesUseCase(playerInviteRepository: repository)(
      params: GetTeamInvitesParams(teamId: 't1'),
    );

    expect(repository.calls['getTeamInvites'], 't1');
  });

  test('CancelTeamInviteUseCase forwards both ids', () async {
    final repository = _FakeInviteRepository();

    await CancelTeamInviteUseCase(playerInviteRepository: repository)(
      params: CancelTeamInviteParams(teamId: 't1', inviteId: 'i1'),
    );

    expect(repository.calls['cancelTeamInvite'], ('t1', 'i1'));
  });
}
