import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/create_match_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/create_match_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Never actually invoked — this test only exercises the form's input
/// fields, never taps submit.
class _UnusedCreateMatchUseCase implements CreateMatchUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// Returns an empty team list — this test only exercises the form's text
/// fields, never the chip picker.
class _EmptyGetMyTeamsUseCase implements GetMyTeamsUseCase {
  @override
  Future<Either<CricketResponse<MyTeamsRes>, CricketFailure>> call({
    void params,
  }) async =>
      Either.result(CricketResponse(message: 'ok', data: MyTeamsRes(teams: const [])));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

// The backend's Team.name schema caps at 50 characters (maxlength: 50);
// player/bowler name fields already cap client-side at the same limit via
// `maxLength: 50`, but the team-name fields never did, so a name over 50
// characters passed this form cleanly and only failed on the backend's own
// validation -- the "clean client success, confusing backend 400" class of
// bug the password-length mismatch was.
void main() {
  testWidgets(
    'team name fields cap input at 50 characters, matching Team.name\'s '
    'backend maxlength',
    (WidgetTester tester) async {
      Get.put<CreateMatchController>(
        CreateMatchController(
          createMatchUseCase: _UnusedCreateMatchUseCase(),
          getMyTeamsUseCase: _EmptyGetMyTeamsUseCase(),
        ),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const CreateMatchScreen(),
        ),
      );

      final tooLongName = 'A' * 60;
      final teamAField = find.byType(TextFormField).first;

      await tester.enterText(teamAField, tooLongName);
      await tester.pump();

      expect(
        Get.find<CreateMatchController>().teamAController.text.length,
        lessThanOrEqualTo(50),
      );

      Get.reset();
    },
  );
}
