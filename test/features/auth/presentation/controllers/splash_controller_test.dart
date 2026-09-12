import 'dart:async';

import 'package:cricket_scorer/config/app_config.dart';
import 'package:cricket_scorer/config/flavors.dart';
import 'package:cricket_scorer/config/routes/app_routes.dart';
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
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/get_user.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/login.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reproduces a real crash captured from a device run: on a stale/expired
/// session, `AuthInterceptor.onError`'s `_forceLogout()` navigates to
/// `/login` (see auth_interceptor.dart) for the SAME failed
/// `get-current-user` request that `SplashController._navigate()` is also
/// awaiting. Only after that does the awaited `getUserUseCase()` call
/// resolve back here with `Either.fallback(...)`, so unconditionally
/// navigating to `/login` again fires a *second* `Get.offAllNamed` while
/// the first LoginScreen (and its LoginController's TextEditingControllers)
/// is still mid pop-transition animation. GetX disposes the first
/// LoginController while that first screen is still rebuilding, and its
/// still-live TextFormField throws "A TextEditingController was used after
/// being disposed" trying to re-attach a listener to the now-disposed
/// controller.
///
/// This fake plays the interceptor's role directly — it calls
/// `Get.offAllNamed(AppRoutes.login)` itself, synchronously, before
/// returning the failure — so the test reproduces the exact ordering
/// without needing a real Dio/AuthInterceptor stack.
class _ForceLogoutRacingAuthRepository implements AuthRepository {
  @override
  Future<Either<CricketResponse<User>, CricketFailure>> getUser() async {
    unawaited(Get.offAllNamed<dynamic>(AppRoutes.login));
    return Either.fallback(CricketUnauthorizedErrorFailure(statusCode: 401));
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

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

void main() {
  setUpAll(() {
    AppFlavor.setAppFlavor(Flavor.dev);
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets(
    'does not re-navigate to login when the auth interceptor already forced '
    'logout there for the same failed request',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await Get.put(SharedPreferenceService()).init();
      Get.put(ThemeService());
      Get.put(LanguageService());

      final authRepository = _ForceLogoutRacingAuthRepository();
      final languageRepository = _NoopLanguageRepository();
      Get.put(GetUserUseCase(authRepository: authRepository));
      Get.put(GetVersionUseCase(languageRepository: languageRepository));
      Get.put(GetLanguageUseCase(languageRepository: languageRepository));
      Get.put(LoginUseCase(authRepository: authRepository));
      Get.put(UpdateLanguageUseCase(languageRepository: languageRepository));

      var loginCreations = 0;
      final originalLog = Get.log;
      Get.log = (String message, {bool isError = false}) {
        if (message.contains('Instance "LoginController" has been created')) {
          loginCreations++;
        }
        originalLog(message, isError: isError);
      };
      addTearDown(() => Get.log = originalLog);

      await tester.pumpWidget(const CricketScorerApp());
      // Long enough for PendingDeepLink's 3s hard-timeout timer, the splash
      // animation, and both navigation attempts to settle — same window
      // widget_test.dart's own smoke test already relies on.
      await tester.pump(const Duration(seconds: 4));

      expect(loginCreations, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
