import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/repositories/team_player_view_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApi implements MatchApiService {
  Either<ApiResponseModel, CricketFailure>? response;
  final calls = <String, Map<String, Object?>>{};

  Future<Either<ApiResponseModel, CricketFailure>> _record(
    String name,
    Map<String, Object?> args,
  ) async {
    calls[name] = args;
    return response!;
  }

  @override
  Future<Either<ApiResponseModel, CricketFailure>> getPlayingForTeams({
    required int page,
    required int limit,
  }) => _record('getPlayingForTeams', {'page': page, 'limit': limit});

  @override
  Future<Either<ApiResponseModel, CricketFailure>> getTeamPlayerView({
    required String teamId,
  }) => _record('getTeamPlayerView', {'teamId': teamId});

  @override
  Future<Either<ApiResponseModel, CricketFailure>> getTeamPlayerMatches({
    required String teamId,
    required int page,
    required int limit,
    String status = 'all',
  }) => _record('getTeamPlayerMatches', {
    'teamId': teamId,
    'page': page,
    'limit': limit,
    'status': status,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

Either<ApiResponseModel, CricketFailure> _ok(Map<String, dynamic> data) =>
    Either.result(
      ApiResponseModel(
        statusCode: 200,
        data: data,
        message: 'ok',
        success: true,
      ),
    );

void main() {
  late _FakeApi api;
  late TeamPlayerViewRepositoryImpl repository;

  setUp(() {
    api = _FakeApi();
    repository = TeamPlayerViewRepositoryImpl(matchApiService: api);
  });

  test('getPlayingForTeams parses the page', () async {
    api.response = _ok({
      'teams': [
        {'id': 't1', 'name': 'MI', 'myPlayerName': 'Mohit'},
      ],
      'page': 1,
      'limit': 20,
      'total': 1,
    });

    final result = await repository.getPlayingForTeams(page: 1, limit: 20);

    expect(result.result.data?.teams.single.myPlayerName, 'Mohit');
    expect(api.calls['getPlayingForTeams'], {'page': 1, 'limit': 20});
  });

  test('getTeamPlayerView parses the profile', () async {
    api.response = _ok({
      'teamId': 't1',
      'name': 'MI',
      'roster': <Map<String, dynamic>>[],
    });

    final result = await repository.getTeamPlayerView(teamId: 't1');

    expect(result.result.data?.name, 'MI');
    expect(api.calls['getTeamPlayerView'], {'teamId': 't1'});
  });

  test('getTeamPlayerMatches passes the filter and parses matches', () async {
    api.response = _ok({
      'matches': <Map<String, dynamic>>[],
      'page': 1,
      'limit': 20,
      'total': 0,
    });

    final result = await repository.getTeamPlayerMatches(
      teamId: 't1',
      page: 1,
      limit: 20,
      status: 'live',
    );

    expect(result.result.data?.total, 0);
    expect(api.calls['getTeamPlayerMatches'], {
      'teamId': 't1',
      'page': 1,
      'limit': 20,
      'status': 'live',
    });
  });

  test('passes a failure through', () async {
    api.response = Either.fallback(CricketServerErrorFailure(message: 'boom'));

    final result = await repository.getTeamPlayerView(teamId: 't1');

    expect(result.isResult, isFalse);
    expect(result.fallback.message, 'boom');
  });
}
