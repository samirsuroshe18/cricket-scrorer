import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/add_team_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/set_team_leadership_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/update_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/add_team_player.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/set_team_leadership.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_player.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingTeamRepository implements TeamRepository {
  String? teamId;
  String? playerId;
  Object? req;

  static final _row = TeamRosterPlayer(
    playerId: 'p1',
    playerName: 'Rohit',
    role: 'batsman',
  );

  @override
  Future<Either<CricketResponse<TeamRosterPlayer>, CricketFailure>> addPlayer({
    required String teamId,
    required AddTeamPlayerReq params,
  }) async {
    this.teamId = teamId;
    req = params;
    return Either.result(CricketResponse(data: _row, message: 'ok'));
  }

  @override
  Future<Either<CricketResponse<TeamRosterPlayer>, CricketFailure>>
  updatePlayer({
    required String teamId,
    required String playerId,
    required UpdatePlayerReq params,
  }) async {
    this.teamId = teamId;
    this.playerId = playerId;
    req = params;
    return Either.result(CricketResponse(data: _row, message: 'ok'));
  }

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>>
  setLeadership({
    required String teamId,
    required SetTeamLeadershipReq params,
  }) async {
    this.teamId = teamId;
    req = params;
    return Either.result(
      CricketResponse(
        data: CreatedTeamRes(id: teamId, name: 'MI'),
        message: 'ok',
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  test('AddTeamPlayerUseCase forwards teamId and request', () async {
    final repo = _RecordingTeamRepository();
    final req = AddTeamPlayerReq(name: 'Rohit');

    final result = await AddTeamPlayerUseCase(teamRepository: repo)(
      params: AddTeamPlayerParams(teamId: 't1', req: req),
    );

    expect(result.isResult, isTrue);
    expect(repo.teamId, 't1');
    expect(repo.req, same(req));
  });

  test(
    'UpdateTeamPlayerUseCase forwards teamId, playerId and request',
    () async {
      final repo = _RecordingTeamRepository();
      final req = UpdatePlayerReq(role: 'bowler');

      await UpdateTeamPlayerUseCase(teamRepository: repo)(
        params: UpdateTeamPlayerParams(teamId: 't1', playerId: 'p1', req: req),
      );

      expect(repo.teamId, 't1');
      expect(repo.playerId, 'p1');
      expect(repo.req, same(req));
    },
  );

  test('SetTeamLeadershipUseCase forwards teamId and request', () async {
    final repo = _RecordingTeamRepository();
    final req = SetTeamLeadershipReq(name: 'MI', captainId: 'p1');

    await SetTeamLeadershipUseCase(teamRepository: repo)(
      params: SetTeamLeadershipParams(teamId: 't1', req: req),
    );

    expect(repo.teamId, 't1');
    expect(repo.req, same(req));
  });
}
