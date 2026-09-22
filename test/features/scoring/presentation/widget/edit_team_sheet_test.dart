import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/created_team_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/assign_scorer.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/delete_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_scorer_candidates.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_matches.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_team_profile.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/update_team_logo.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/edit_team_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _UnusedGetTeamProfileUseCase implements GetTeamProfileUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedGetTeamMatchesUseCase implements GetTeamMatchesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedGetScorerCandidatesUseCase implements GetScorerCandidatesUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedAssignScorerUseCase implements AssignScorerUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedUpdateTeamLogoUseCase implements UpdateTeamLogoUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _UnusedDeleteTeamUseCase implements DeleteTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeUpdateTeamUseCase implements UpdateTeamUseCase {
  Either<CricketResponse<CreatedTeamRes>, CricketFailure>? response;
  UpdateTeamParams? lastParams;

  @override
  Future<Either<CricketResponse<CreatedTeamRes>, CricketFailure>> call({
    UpdateTeamParams? params,
  }) async {
    lastParams = params;
    final result = response;
    if (result == null) throw UnimplementedError('Not exercised in this test.');
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  Future<_FakeUpdateTeamUseCase> pumpSheet(WidgetTester tester) async {
    final updateTeamUseCase = _FakeUpdateTeamUseCase();
    final controller = TeamProfileController(
      teamId: 'team-1',
      getTeamProfileUseCase: _UnusedGetTeamProfileUseCase(),
      getTeamMatchesUseCase: _UnusedGetTeamMatchesUseCase(),
      getScorerCandidatesUseCase: _UnusedGetScorerCandidatesUseCase(),
      assignScorerUseCase: _UnusedAssignScorerUseCase(),
      updateTeamLogoUseCase: _UnusedUpdateTeamLogoUseCase(),
      updateTeamUseCase: updateTeamUseCase,
      deleteTeamUseCase: _UnusedDeleteTeamUseCase(),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showEditTeamSheet(
                  controller: controller,
                  currentName: 'Mumbai Indians',
                  currentShortName: 'MI',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    return updateTeamUseCase;
  }

  testWidgets('prefills the current name and short name', (tester) async {
    await pumpSheet(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Mumbai Indians'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'MI'), findsOneWidget);
  });

  testWidgets('shows a required-name error and does not submit when cleared', (
    tester,
  ) async {
    await pumpSheet(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Mumbai Indians'),
      '',
    );
    await tester.tap(find.text('edit_team').last);
    await tester.pump();

    expect(find.text('team_name_required'), findsOneWidget);
  });

  testWidgets('submits the edited name and short name on save', (
    tester,
  ) async {
    final updateTeamUseCase = await pumpSheet(tester);
    updateTeamUseCase.response = Either.result(
      CricketResponse(
        message: 'ok',
        data: CreatedTeamRes(id: 'team-1', name: 'Mumbai Indians XI'),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Mumbai Indians'),
      'Mumbai Indians XI',
    );
    await tester.tap(find.text('edit_team').last);
    await tester.pumpAndSettle();

    expect(updateTeamUseCase.lastParams?.teamId, 'team-1');
    expect(updateTeamUseCase.lastParams?.req.name, 'Mumbai Indians XI');
    expect(updateTeamUseCase.lastParams?.req.shortName, 'MI');
  });
}
