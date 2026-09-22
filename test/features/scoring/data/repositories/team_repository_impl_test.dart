import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
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
}
