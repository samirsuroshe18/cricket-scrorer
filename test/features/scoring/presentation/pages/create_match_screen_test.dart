import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_match.dart';
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
