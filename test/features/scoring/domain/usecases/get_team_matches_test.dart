// test/features/scoring/domain/usecases/get_team_matches_test.dart
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/match_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingMatchRepository implements MatchRepository {
  String? lastTeamId;
  int? lastPage;
  int? lastLimit;

  @override
  Future<Either<CricketResponse<MatchHistoryRes>, CricketFailure>>
  getTeamMatches({
    required String teamId,
    required int page,
    required int limit,
  }) async {
    lastTeamId = teamId;
    lastPage = page;
    lastLimit = limit;
    return Either.result(
      CricketResponse(
        message: 'ok',
        data: MatchHistoryRes(matches: const [], page: page, limit: limit, total: 0),
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  test('forwards teamId/page/limit unchanged to the repository', () async {
    final repo = _RecordingMatchRepository();
    final useCase = GetTeamMatchesUseCase(matchRepository: repo);

    await useCase(
      params: GetTeamMatchesParams(teamId: 'team-1', page: 2, limit: 10),
    );

    expect(repo.lastTeamId, 'team-1');
    expect(repo.lastPage, 2);
    expect(repo.lastLimit, 10);
  });

  test('defaults to page 1, limit 20 when not specified', () async {
    final repo = _RecordingMatchRepository();
    final useCase = GetTeamMatchesUseCase(matchRepository: repo);

    await useCase(params: GetTeamMatchesParams(teamId: 'team-1'));

    expect(repo.lastPage, 1);
    expect(repo.lastLimit, 20);
  });
}
