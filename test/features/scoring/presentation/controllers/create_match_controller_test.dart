import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/create_match_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _UnusedCreateMatchUseCase implements CreateMatchUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetMyTeamsUseCase implements GetMyTeamsUseCase {
  List<TeamSummary> teams = const [];

  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    void params,
  }) async => Either.result(
    CricketResponse(message: 'ok', data: MyTeamsRes(teams: teams)),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  late _FakeGetMyTeamsUseCase getMyTeamsUseCase;
  late CreateMatchController controller;

  setUp(() {
    Get.testMode = true;
    getMyTeamsUseCase = _FakeGetMyTeamsUseCase()
      ..teams = [
        TeamSummary(id: 'team-1', name: 'Mumbai Indians'),
        TeamSummary(id: 'team-2', name: 'Chennai Super Kings'),
      ];
    controller = CreateMatchController(
      createMatchUseCase: _UnusedCreateMatchUseCase(),
      getMyTeamsUseCase: getMyTeamsUseCase,
    );
    controller.onInit();
  });

  tearDown(() {
    controller.onClose();
    Get.reset();
  });

  test('onInit loads the caller\'s own teams', () async {
    await Future<void>.delayed(Duration.zero);
    expect(controller.myTeams.map((t) => t.id), ['team-1', 'team-2']);
  });

  test('selecting a team sets its id and fills the name field', () async {
    await Future<void>.delayed(Duration.zero);

    controller.selectTeamA(controller.myTeams.first);

    expect(controller.selectedTeamAId.value, 'team-1');
    expect(controller.teamAController.text, 'Mumbai Indians');
  });

  test('retyping the field after a selection clears the selected id', () async {
    await Future<void>.delayed(Duration.zero);

    controller.selectTeamA(controller.myTeams.first);
    controller.teamAController.text = 'Something else';

    expect(controller.selectedTeamAId.value, isNull);
  });

  test('tapping the same chip again clears the selection and the field', () async {
    await Future<void>.delayed(Duration.zero);

    final team = controller.myTeams.first;
    controller.selectTeamA(team);
    controller.selectTeamA(team);

    expect(controller.selectedTeamAId.value, isNull);
    expect(controller.teamAController.text, isEmpty);
  });
}
