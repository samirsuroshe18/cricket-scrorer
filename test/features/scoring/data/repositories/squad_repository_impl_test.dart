import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/models/request/save_playing_xi_req.dart';
import 'package:cricket_scorer/features/scoring/data/repositories/squad_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMatchApiService implements MatchApiService {
  Either<ApiResponseModel, CricketFailure>? response;
  final calls = <String, Map<String, Object?>>{};

  @override
  Future<Either<ApiResponseModel, CricketFailure>> getMatchSquad({
    required String matchId,
  }) async {
    calls['getMatchSquad'] = {'matchId': matchId};
    return response!;
  }

  @override
  Future<Either<ApiResponseModel, CricketFailure>> savePlayingXi({
    required String matchId,
    required SavePlayingXiReq params,
  }) async {
    calls['savePlayingXi'] = {'matchId': matchId, 'body': params.toJson()};
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

Either<ApiResponseModel, CricketFailure> _ok(Object? data) => Either.result(
  ApiResponseModel(statusCode: 200, data: data, message: 'ok', success: true),
);

void main() {
  late _FakeMatchApiService api;
  late SquadRepositoryImpl repository;

  setUp(() {
    api = _FakeMatchApiService();
    repository = SquadRepositoryImpl(matchApiService: api);
  });

  test(
    'getMatchSquad parses MatchSquadRes and forwards the match id',
    () async {
      api.response = _ok({
        'matchId': 'm1',
        'inningsStarted': false,
        'teamA': {
          'teamId': 'ta',
          'players': <Object>[],
          'playingXI': null,
          'savedAt': null,
        },
        'teamB': {
          'teamId': 'tb',
          'players': <Object>[],
          'playingXI': null,
          'savedAt': null,
        },
      });

      final result = await repository.getMatchSquad(matchId: 'm1');

      expect(result.result.data?.teamB.teamId, 'tb');
      expect(result.result.message, 'ok');
      expect(api.calls['getMatchSquad'], {'matchId': 'm1'});
    },
  );

  test('savePlayingXi sends the ids and parses the side', () async {
    api.response = _ok({
      'side': 'teamA',
      'teamId': 'ta',
      'players': <Object>[],
      'playingXI': ['p1'],
      'savedAt': null,
    });

    final result = await repository.savePlayingXi(
      matchId: 'm1',
      params: SavePlayingXiReq(side: 'teamA', playingXI: ['p1']),
    );

    expect(result.result.data?.playingXI, ['p1']);
    expect(api.calls['savePlayingXi'], {
      'matchId': 'm1',
      'body': {
        'playingXI': ['p1'],
      },
    });
  });

  test('a failure is passed through untouched', () async {
    api.response = Either.fallback(CricketFailure(message: 'nope'));

    final result = await repository.getMatchSquad(matchId: 'm1');

    expect(result.isResult, isFalse);
    expect(result.fallback.message, 'nope');
  });
}
