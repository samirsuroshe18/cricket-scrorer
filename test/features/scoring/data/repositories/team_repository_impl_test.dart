import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/add_team_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/set_team_leadership_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/update_player_req.dart';
import 'package:cricket_scorer/features/scoring/data/repositories/team_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMatchApiService implements MatchApiService {
  Either<ApiResponseModel, CricketFailure>? updateTeamResponse;
  Either<ApiResponseModel, CricketFailure>? deleteTeamResponse;
  String? lastUpdateTeamId;
  CreateTeamReq? lastUpdateParams;
  String? lastDeleteTeamId;

  @override
  Future<Either<ApiResponseModel, CricketFailure>> updateTeam({
    required String teamId,
    required CreateTeamReq params,
  }) async {
    lastUpdateTeamId = teamId;
    lastUpdateParams = params;
    return updateTeamResponse!;
  }

  @override
  Future<Either<ApiResponseModel, CricketFailure>> deleteTeam({
    required String teamId,
  }) async {
    lastDeleteTeamId = teamId;
    return deleteTeamResponse!;
  }

  Either<ApiResponseModel, CricketFailure>? rosterResponse;
  String? lastRosterTeamId;
  String? lastRosterPlayerId;
  Object? lastRosterParams;

  @override
  Future<Either<ApiResponseModel, CricketFailure>> addTeamPlayer({
    required String teamId,
    required AddTeamPlayerReq params,
  }) async {
    lastRosterTeamId = teamId;
    lastRosterParams = params;
    return rosterResponse!;
  }

  @override
  Future<Either<ApiResponseModel, CricketFailure>> updateTeamPlayer({
    required String teamId,
    required String playerId,
    required UpdatePlayerReq params,
  }) async {
    lastRosterTeamId = teamId;
    lastRosterPlayerId = playerId;
    lastRosterParams = params;
    return rosterResponse!;
  }

  @override
  Future<Either<ApiResponseModel, CricketFailure>> setTeamLeadership({
    required String teamId,
    required SetTeamLeadershipReq params,
  }) async {
    lastRosterTeamId = teamId;
    lastRosterParams = params;
    return rosterResponse!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeMatchApiService apiService;
  late TeamRepositoryImpl repository;

  setUp(() {
    apiService = _FakeMatchApiService();
    repository = TeamRepositoryImpl(matchApiService: apiService);
  });

  test('updateTeam parses the response into CreatedTeamRes', () async {
    apiService.updateTeamResponse = Either.result(
      ApiResponseModel(
        statusCode: 200,
        data: {'id': 'team-1', 'name': 'Renamed', 'shortName': 'RN'},
        message: 'Team updated',
        success: true,
      ),
    );

    final result = await repository.updateTeam(
      teamId: 'team-1',
      params: CreateTeamReq(name: 'Renamed', shortName: 'RN'),
    );

    expect(result.isResult, isTrue);
    expect(result.result.data?.name, 'Renamed');
    expect(apiService.lastUpdateTeamId, 'team-1');
    expect(apiService.lastUpdateParams?.name, 'Renamed');
  });

  test('updateTeam passes through a failure', () async {
    apiService.updateTeamResponse = Either.fallback(
      CricketForbiddenErrorFailure(statusCode: 403, message: "Can't manage"),
    );

    final result = await repository.updateTeam(
      teamId: 'team-1',
      params: CreateTeamReq(name: 'Renamed'),
    );

    expect(result.isResult, isFalse);
    expect(result.fallback.message, "Can't manage");
  });

  test('deleteTeam returns a null-data success on 200', () async {
    apiService.deleteTeamResponse = Either.result(
      ApiResponseModel(
        statusCode: 200,
        data: {'id': 'team-1'},
        message: 'Team deleted',
        success: true,
      ),
    );

    final result = await repository.deleteTeam(teamId: 'team-1');

    expect(result.isResult, isTrue);
    expect(apiService.lastDeleteTeamId, 'team-1');
  });

  test('deleteTeam passes through a failure', () async {
    apiService.deleteTeamResponse = Either.fallback(
      CricketConflictFailure(
        statusCode: 409,
        message: 'That team is in an upcoming or live match',
      ),
    );

    final result = await repository.deleteTeam(teamId: 'team-1');

    expect(result.isResult, isFalse);
    expect(
      result.fallback.message,
      'That team is in an upcoming or live match',
    );
  });

  final rosterRow = {
    'playerId': 'p1',
    'playerName': 'Rohit',
    'jerseyNumber': 45,
    'role': 'batsman',
    'isCaptain': false,
    'isViceCaptain': false,
  };

  test('addPlayer parses the roster row and forwards the request', () async {
    apiService.rosterResponse = Either.result(
      ApiResponseModel(statusCode: 201, data: rosterRow, message: 'ok', success: true),
    );
    final req = AddTeamPlayerReq(name: 'Rohit', role: 'batsman');

    final result = await repository.addPlayer(teamId: 'team-1', params: req);

    expect(result.result.data?.playerName, 'Rohit');
    expect(result.result.data?.jerseyNumber, 45);
    expect(apiService.lastRosterTeamId, 'team-1');
    expect(apiService.lastRosterParams, same(req));
  });

  test('updatePlayer parses the roster row and forwards ids', () async {
    apiService.rosterResponse = Either.result(
      ApiResponseModel(statusCode: 200, data: rosterRow, message: 'ok', success: true),
    );

    final result = await repository.updatePlayer(
      teamId: 'team-1',
      playerId: 'p1',
      params: UpdatePlayerReq(role: 'bowler'),
    );

    expect(result.result.data?.playerId, 'p1');
    expect(apiService.lastRosterPlayerId, 'p1');
  });

  test('setLeadership parses CreatedTeamRes', () async {
    apiService.rosterResponse = Either.result(
      ApiResponseModel(
        statusCode: 200,
        data: {'id': 'team-1', 'name': 'MI', 'shortName': null},
        message: 'ok',
        success: true,
      ),
    );

    final result = await repository.setLeadership(
      teamId: 'team-1',
      params: SetTeamLeadershipReq(name: 'MI', captainId: 'p1'),
    );

    expect(result.result.data?.name, 'MI');
  });

  test('addPlayer passes through a failure', () async {
    apiService.rosterResponse = Either.fallback(
      CricketForbiddenErrorFailure(statusCode: 403, message: "Can't manage"),
    );

    final result = await repository.addPlayer(
      teamId: 'team-1',
      params: AddTeamPlayerReq(name: 'Rohit'),
    );

    expect(result.isResult, isFalse);
    expect(result.fallback.message, "Can't manage");
  });
}
