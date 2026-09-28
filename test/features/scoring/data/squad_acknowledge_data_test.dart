import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/api_response_model.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/remote/match_api_service/match_api_service.dart';
import 'package:cricket_scorer/features/scoring/data/match_endpoint.dart';
import 'package:cricket_scorer/features/scoring/data/repositories/squad_repository_impl.dart';
import 'package:cricket_scorer/features/scoring/domain/repositories/squad_repository.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/acknowledge_squad.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMatchApiService implements MatchApiService {
  Either<ApiResponseModel, CricketFailure>? response;
  final calls = <String>[];

  @override
  Future<Either<ApiResponseModel, CricketFailure>> acknowledgeSquad({
    required String matchId,
  }) async {
    calls.add(matchId);
    return response!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeSquadRepository implements SquadRepository {
  final calls = <String>[];

  @override
  Future<Either<CricketResponse<void>, CricketFailure>> acknowledgeSquad({
    required String matchId,
  }) async {
    calls.add(matchId);
    return Either.result(const CricketResponse(message: 'ok'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  test('the endpoint starts at /v1, never /api', () {
    const endpoint = MatchEndpoint();

    expect(endpoint.squadAcknowledge('m1'), '/v1/match/m1/squad/acknowledge');
    expect(endpoint.squadAcknowledge('m1').startsWith('/api'), isFalse);
  });

  test('the repository posts for that match and returns the message', () async {
    final api = _FakeMatchApiService()
      ..response = Either.result(
        ApiResponseModel(
          statusCode: 200,
          data: {'matchId': 'm1'},
          message: 'done',
          success: true,
        ),
      );

    final result = await SquadRepositoryImpl(
      matchApiService: api,
    ).acknowledgeSquad(matchId: 'm1');

    expect(api.calls, ['m1']);
    expect(result.isResult, isTrue);
    expect(result.result.message, 'done');
  });

  test('a failure is passed through untouched', () async {
    final api = _FakeMatchApiService()
      ..response = Either.fallback(CricketFailure(message: 'offline'));

    final result = await SquadRepositoryImpl(
      matchApiService: api,
    ).acknowledgeSquad(matchId: 'm1');

    expect(result.isResult, isFalse);
    expect(result.fallback.message, 'offline');
  });

  test('the use case forwards the match id', () async {
    final repository = _FakeSquadRepository();

    await AcknowledgeSquadUseCase(squadRepository: repository)(
      params: AcknowledgeSquadParams(matchId: 'm9'),
    );

    expect(repository.calls, ['m9']);
  });
}
