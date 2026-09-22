import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/create_team_req.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTeamRepository implements TeamRepository {
  Either<CricketResponse<CreatedTeamRes>, CricketFailure>? response;
  String? lastTeamId;
  CreateTeamReq? lastParams;

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> updateTeam({
    required String teamId,
    required CreateTeamReq params,
  }) async {
    lastTeamId = teamId;
    lastParams = params;
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  test(
    'calls TeamRepository.updateTeam with the given teamId and body',
    () async {
      final repository = _FakeTeamRepository()
        ..response = Either.result(
          CricketResponse(
            message: 'ok',
            data: CreatedTeamRes(id: 'team-1', name: 'Renamed'),
          ),
        );
      final useCase = UpdateTeamUseCase(teamRepository: repository);

      final result = await useCase(
        params: UpdateTeamParams(
          teamId: 'team-1',
          req: CreateTeamReq(name: 'Renamed'),
        ),
      );

      expect(result.isResult, isTrue);
      expect(repository.lastTeamId, 'team-1');
      expect(repository.lastParams?.name, 'Renamed');
    },
  );
}
