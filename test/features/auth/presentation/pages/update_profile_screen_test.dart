import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/auth/data/profile_constants.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/get_user.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/update_profile.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/update_profile_controller.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/update_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Only `getUser` is ever exercised by these tests (`isEditing: true` calls
/// it from `onInit`); every other member falls through to `noSuchMethod` the
/// same way `_NoopLanguageRepository` does in `login_screen_test.dart`. It
/// resolves successfully with no data — a fallback here now surfaces an
/// error snackbar (see `update_profile_controller.dart`), which races the
/// as-yet-unmounted `GetMaterialApp` overlay during `_pumpUpdateProfileScreen`
/// and crashes; these tests only care that the load completes, not that it
/// fails.
class _NoopAuthRepository implements AuthRepository {
  @override
  Future<Either<CricketResponse<User>, CricketFailure>> getUser() async =>
      Either.result(const CricketResponse(message: 'ok'));

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

Future<UpdateProfileController> _pumpUpdateProfileScreen(
  WidgetTester tester, {
  bool isEditing = false,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // UpdateProfileController.onInit() reads Get.arguments rather than taking
  // isEditing via constructor — set it the same way real navigation would,
  // before the controller is put (onInit runs synchronously at put-time).
  Get.routing.args = {'isEditing': isEditing};

  final authRepository = _NoopAuthRepository();
  final controller = Get.put<UpdateProfileController>(
    UpdateProfileController(
      updateProfileUseCase: UpdateProfileUseCase(
        authRepository: authRepository,
      ),
      getUserUseCase: GetUserUseCase(authRepository: authRepository),
    ),
  );

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.lightTheme,
      home: const UpdateProfileScreen(),
    ),
  );
  await tester.pump();

  return controller;
}

void main() {
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  group(UpdateProfileScreen, () {
    group('avatar picker', () {
      testWidgets(
        'tapping the avatar opens the choose-photo bottom sheet',
        (tester) async {
          await _pumpUpdateProfileScreen(tester);

          expect(find.text(TranslationKeys.camera.tr), findsNothing);
          expect(find.text(TranslationKeys.gallery.tr), findsNothing);

          await tester.tap(find.byIcon(Icons.camera_alt));
          await tester.pumpAndSettle();

          expect(find.text(TranslationKeys.camera.tr), findsOneWidget);
          expect(find.text(TranslationKeys.gallery.tr), findsOneWidget);
        },
      );
    });

    group('selection chips', () {
      testWidgets(
        'selecting a role, batting-style, and bowling-style chip updates '
        'the matching controller field',
        (tester) async {
          final controller = await _pumpUpdateProfileScreen(tester);

          expect(controller.playingRole.value, isNull);
          expect(controller.battingStyle.value, isNull);
          expect(controller.bowlingStyle.value, isNull);

          // Each chip section sits further down the form than the default
          // test viewport shows — scroll each into view before tapping it,
          // same as login_screen_test.dart does for its below-the-fold rows.
          await tester.ensureVisible(find.text(TranslationKeys.roleBowler.tr));
          await tester.tap(find.text(TranslationKeys.roleBowler.tr));
          await tester.pump();
          expect(controller.playingRole.value, equals(PlayingRole.bowler));

          await tester.ensureVisible(
            find.text(TranslationKeys.leftHanded.tr),
          );
          await tester.tap(find.text(TranslationKeys.leftHanded.tr));
          await tester.pump();
          expect(
            controller.battingStyle.value,
            equals(BattingStyle.leftHanded),
          );

          await tester.ensureVisible(
            find.text(TranslationKeys.rightArmSpin.tr),
          );
          await tester.tap(find.text(TranslationKeys.rightArmSpin.tr));
          await tester.pump();
          expect(
            controller.bowlingStyle.value,
            equals(BowlingStyle.rightArmSpin),
          );
        },
      );
    });

    group('profile preview card', () {
      testWidgets(
        'reflects username, bio, and jersey number as they are typed',
        (tester) async {
          await _pumpUpdateProfileScreen(tester);

          final fields = find.byType(TextFormField);

          await tester.enterText(fields.at(0), 'DashSmith');
          await tester.pump();
          // Once in the field itself, once in the preview card echoing it.
          expect(find.text('DashSmith'), findsNWidgets(2));

          await tester.enterText(fields.at(1), 'Loves cricket');
          await tester.pump();
          expect(find.text('Loves cricket'), findsNWidgets(2));

          await tester.enterText(fields.at(2), '7');
          await tester.pump();
          // The jersey number now renders as a corner badge on the preview
          // card showing the bare digits, same as the field itself — once
          // in the field, once in the badge.
          expect(find.text('7'), findsNWidgets(2));
        },
      );
    });

    group('step indicator', () {
      testWidgets(
        'shows when the controller is not in edit mode',
        (tester) async {
          await _pumpUpdateProfileScreen(tester);

          expect(
            find.text(TranslationKeys.stepIndicatorLabel.tr),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'is hidden when the controller is in edit mode',
        (tester) async {
          await _pumpUpdateProfileScreen(tester, isEditing: true);

          expect(
            find.text(TranslationKeys.stepIndicatorLabel.tr),
            findsNothing,
          );
        },
      );
    });

    group('username field', () {
      testWidgets(
        'sits inside an AutofillGroup and hints newUsername for a '
        'password manager',
        (tester) async {
          await _pumpUpdateProfileScreen(tester);

          final usernameField = find.byType(TextFormField).first;

          expect(
            find.ancestor(
              of: usernameField,
              matching: find.byType(AutofillGroup),
            ),
            findsOneWidget,
          );

          // TextFormField doesn't expose autofillHints itself — it forwards
          // the value to the TextField it builds internally.
          final textField = tester.widget<TextField>(
            find.descendant(
              of: usernameField,
              matching: find.byType(TextField),
            ),
          );
          expect(
            textField.autofillHints,
            contains(AutofillHints.newUsername),
          );
        },
      );
    });
  });
}
