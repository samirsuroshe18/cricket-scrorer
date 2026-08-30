import 'package:cricket_scorer/config/app_config.dart';
import 'package:cricket_scorer/config/flavors.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_model.dart';
import 'package:cricket_scorer/core/global/data/models/response/translation_version.dart';
import 'package:cricket_scorer/core/global/domain/repositories/language_repository.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/services/theme_service.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/get_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fails every call with [CricketNoInternetFailure] — good enough for
/// [SplashController], which treats "not logged in" and "couldn't check"
/// identically (both send the scorer to the login screen). Nothing this
/// smoke test cares about depends on which branch it actually takes.
class _NoopAuthRepository implements AuthRepository {
  @override
  Future<Either<CricketResponse<User>, CricketFailure>> getUser() async =>
      Either.fallback(CricketNoInternetFailure(statusCode: 0));

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// See [_NoopAuthRepository] — same reasoning, for the version/language
/// check [SplashController] also fires before it navigates anywhere.
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
  setUpAll(() async {
    AppFlavor.setAppFlavor(Flavor.dev); // set flavor before any test runs

    // `CricketScorerApp.build` resolves `LanguageService`/`ThemeService`
    // directly (see core/CLAUDE.md's cross-cutting-service exception), and
    // its initial route is the real splash screen, which resolves
    // `SplashController` via `SplashBinding` — so a plain `pumpWidget`
    // cannot work without at least this much of the DI graph in place. This
    // is the "stub the services it resolves" half of the two options
    // documented in this repo's CLAUDE.md ("Testing"); running the full
    // `InjectionContainer.init()` here would also need Firebase, real
    // notification/secure-storage platform channels, and a live API — none
    // of which this smoke test's one assertion (does the tree build at all)
    // has any use for.
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    await Get.put(SharedPreferenceService()).init();

    Get.put(ThemeService());
    Get.put(LanguageService());

    final authRepository = _NoopAuthRepository();
    final languageRepository = _NoopLanguageRepository();
    Get.put(GetUserUseCase(authRepository: authRepository));
    Get.put(GetVersionUseCase(languageRepository: languageRepository));
    Get.put(GetLanguageUseCase(languageRepository: languageRepository));
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CricketScorerApp());
    expect(find.byType(CricketScorerApp), findsOneWidget);

    // SplashController.onReady fires PendingDeepLink.readSpectatorCode,
    // which arms a real 3-second Timer (its hard timeout on the app_links
    // platform channel — see that method's own comment on why it can't be
    // an unbounded await). The test framework asserts no Timer is left
    // pending when a test ends, so it has to actually fire before this test
    // finishes, not just get created and ignored.
    await tester.pump(const Duration(seconds: 4));
  });
}
