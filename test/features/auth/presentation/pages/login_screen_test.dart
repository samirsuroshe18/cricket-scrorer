import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_model.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_version.dart';
import 'package:cricket_scorer/core/global/domain/repositories/language_repository.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/global/domain/usecases/update_language.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/services/theme_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/login.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/login_controller.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Never actually invoked — these tests only exercise client-side
/// validation and the password-visibility toggle, never a real submit.
class _UnusedLoginUseCase implements LoginUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// LoginScreen's app bar renders ThemePickerButton/LanguagePickerButton,
/// which resolve LanguageService (and, through it, these two usecases)
/// directly via Get.find — see this repo's CLAUDE.md "Testing" section on
/// stubbing the services a screen resolves rather than the whole app.
/// Neither usecase is ever invoked in these tests.
class _NoopLanguageRepository implements LanguageRepository {
  @override
  Future<Either<CricketResponse<TranslationVersion>, CricketFailure>>
  getVersion() async =>
      Either.fallback(CricketNoInternetFailure(statusCode: 0));

  @override
  Future<Either<CricketResponse<List<TranslationModel>>, CricketFailure>>
  getLanguage() async =>
      Either.fallback(CricketNoInternetFailure(statusCode: 0));

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

Future<void> _pumpLoginScreen(WidgetTester tester) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await Get.put(SharedPreferenceService()).init();
  Get.put(ThemeService());
  Get.put(LanguageService());

  final languageRepository = _NoopLanguageRepository();

  // LanguagePickerButton (rendered in LoginScreen's app bar) resolves these
  // two directly via Get.find, independent of LoginController, so they need
  // their own registration too.
  final getVersionUseCase = Get.put(
    GetVersionUseCase(languageRepository: languageRepository),
  );
  final getLanguageUseCase = Get.put(
    GetLanguageUseCase(languageRepository: languageRepository),
  );

  Get.put<LoginController>(
    LoginController(
      loginUseCase: _UnusedLoginUseCase(),
      getVersionUseCase: getVersionUseCase,
      getLanguageUseCase: getLanguageUseCase,
      updateLanguageUseCase: UpdateLanguageUseCase(
        languageRepository: languageRepository,
      ),
    ),
  );

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    ),
  );
}

/// Same DI setup as [_pumpLoginScreen], but routed through real `getPages`
/// instead of a bare `home:` — needed by the navigation tests below, which
/// assert `onForgotPassword`/`goToRegister` actually land on the named
/// route rather than just calling `Get.toNamed` with the right argument.
Future<void> _pumpLoginScreenWithRouting(WidgetTester tester) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await Get.put(SharedPreferenceService()).init();
  Get.put(ThemeService());
  Get.put(LanguageService());

  final languageRepository = _NoopLanguageRepository();

  final getVersionUseCase = Get.put(
    GetVersionUseCase(languageRepository: languageRepository),
  );
  final getLanguageUseCase = Get.put(
    GetLanguageUseCase(languageRepository: languageRepository),
  );

  Get.put<LoginController>(
    LoginController(
      loginUseCase: _UnusedLoginUseCase(),
      getVersionUseCase: getVersionUseCase,
      getLanguageUseCase: getLanguageUseCase,
      updateLanguageUseCase: UpdateLanguageUseCase(
        languageRepository: languageRepository,
      ),
    ),
  );

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      getPages: [
        GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
        GetPage(
          name: AppRoutes.register,
          page: () => const Scaffold(body: Text('Register Page')),
        ),
        GetPage(
          name: AppRoutes.forgotPassword,
          page: () => const Scaffold(body: Text('Forgot Password Page')),
        ),
      ],
    ),
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'shows validation errors and never reaches the login usecase when '
    'submitting with empty email and password',
    (tester) async {
      await _pumpLoginScreen(tester);

      await tester.tap(find.text(TranslationKeys.login.tr));
      await tester.pump();

      expect(find.text(TranslationKeys.emailRequired.tr), findsOneWidget);
      expect(find.text(TranslationKeys.passwordRequired.tr), findsOneWidget);
    },
  );

  testWidgets(
    'toggles the password field between obscured and visible when the '
    'visibility icon is tapped',
    (tester) async {
      await _pumpLoginScreen(tester);

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
      expect(Get.find<LoginController>().isPasswordVisible.value, isFalse);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
      expect(Get.find<LoginController>().isPasswordVisible.value, isTrue);
    },
  );

  testWidgets(
    'shows only the email validation error when the email is malformed '
    'but the password is valid',
    (tester) async {
      await _pumpLoginScreen(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'not-an-email');
      await tester.enterText(fields.at(1), 'a-valid-password');
      await tester.pump();

      // Form now uses AutovalidateMode.onUserInteraction, so each field
      // already validated live from the enterText calls above — this
      // submit is just confirming it stays consistent, not the only
      // trigger. The extra content below Login (the "or" divider and the
      // watch-live-match button) pushes it below the default test
      // viewport, hence the scroll-into-view first.
      await tester.ensureVisible(find.text(TranslationKeys.login.tr));
      await tester.pump();
      await tester.tap(find.text(TranslationKeys.login.tr));
      await tester.pump();

      expect(find.text(TranslationKeys.enterValidEmail.tr), findsOneWidget);
      expect(find.text(TranslationKeys.emailRequired.tr), findsNothing);
      expect(find.text(TranslationKeys.passwordRequired.tr), findsNothing);
      expect(find.text(TranslationKeys.passwordTooShort.tr), findsNothing);
    },
  );

  testWidgets(
    'tapping "Forgot password?" clears the form and navigates to the '
    'forgot-password route',
    (tester) async {
      await _pumpLoginScreenWithRouting(tester);

      final controller = Get.find<LoginController>();
      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.pump();

      await tester.tap(find.text(TranslationKeys.forgotPassword.tr));
      expect(controller.emailController.text, isEmpty);

      await tester.pumpAndSettle();
      expect(find.text('Forgot Password Page'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping "Register" clears the form and navigates to the register '
    'route',
    (tester) async {
      await _pumpLoginScreenWithRouting(tester);

      final controller = Get.find<LoginController>();
      await tester.enterText(
        find.byType(TextFormField).first,
        'user@example.com',
      );
      await tester.pump();

      // The Register row sits below the default test viewport now that
      // the Forgot-password/Register buttons use the theme's full touch
      // target instead of a shrink-wrapped one — scroll it into view first.
      await tester.ensureVisible(find.text(TranslationKeys.register.tr));
      await tester.pump();

      await tester.tap(find.text(TranslationKeys.register.tr));
      expect(controller.emailController.text, isEmpty);

      await tester.pumpAndSettle();
      expect(find.text('Register Page'), findsOneWidget);
    },
  );
}
