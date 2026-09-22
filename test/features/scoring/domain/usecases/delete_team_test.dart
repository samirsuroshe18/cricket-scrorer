import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/team_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_team.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTeamRepository implements TeamRepository {
  Either<CricketResponse<void>, CricketFailure>? response;
  String? lastTeamId;

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> deleteTeam({
    required String teamId,
  }) async {
    lastTeamId = teamId;
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  test('calls TeamRepository.deleteTeam with the given teamId', () async {
    final repository = _FakeTeamRepository()
      ..response = Either.result(
        const CricketResponse(message: 'ok', data: null),
      );
    final useCase = DeleteTeamUseCase(teamRepository: repository);

    final result = await useCase(params: DeleteTeamParams(teamId: 'team-1'));

    expect(result.isResult, isTrue);
    expect(repository.lastTeamId, 'team-1');
  });
}
