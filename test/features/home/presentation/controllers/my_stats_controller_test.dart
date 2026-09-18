import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_stats_controller.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_career_stats.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _FakeGetMyCareerStatsUseCase implements GetMyCareerStatsUseCase {
  Either<CricketResponse<MyCareerStatsRes>, CricketFailure>? response;
  int callCount = 0;

  @override
  Future<Either<CricketResponse<MyCareerStatsRes>, CricketFailure>> call({
    void params,
  }) async {
    callCount += 1;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

MyCareerStatsRes _stats({int linked = 1, int matches = 5}) => MyCareerStatsRes(
  linkedPlayerCount: linked,
  matchesPlayed: matches,
  runs: 210,
  wickets: 3,
);

void main() {
  late _FakeGetMyCareerStatsUseCase useCase;
  late MyStatsController controller;

  setUp(() {
    Get.testMode = true;
    useCase = _FakeGetMyCareerStatsUseCase();
    controller = MyStatsController(getMyCareerStatsUseCase: useCase);
  });

  tearDown(Get.reset);

  test('starts with no stats', () {
    expect(controller.stats.value, isNull);
  });

  test('load stores the stats on success', () async {
    useCase.response = Either.result(
      CricketResponse(message: 'ok', data: _stats()),
    );

    await controller.load();

    expect(controller.stats.value?.matchesPlayed, 5);
    expect(controller.stats.value?.runs, 210);
  });

  test('a failed load leaves stats null and does not throw', () async {
    useCase.response = Either.fallback(
      CricketServerErrorFailure(statusCode: 500, message: 'boom'),
    );

    await controller.load();

    expect(controller.stats.value, isNull);
  });

  test('a failed refresh keeps the previously loaded stats', () async {
    useCase.response = Either.result(
      CricketResponse(message: 'ok', data: _stats()),
    );
    await controller.load();

    useCase.response = Either.fallback(
      CricketNoInternetFailure(message: 'offline'),
    );
    await controller.load();

    expect(controller.stats.value?.matchesPlayed, 5);
  });

  test('an overlapping load is ignored', () async {
    useCase.response = Either.result(
      CricketResponse(message: 'ok', data: _stats()),
    );

    await Future.wait([controller.load(), controller.load()]);

    expect(useCase.callCount, 1);
  });
}
