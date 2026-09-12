import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/utils/pending_deep_link.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/get_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final GetUserUseCase getUserUseCase;
  final GetVersionUseCase getVersionUseCase;
  final GetLanguageUseCase getLanguageUseCase;

  SplashController({
    required this.getUserUseCase,
    required this.getVersionUseCase,
    required this.getLanguageUseCase,
  });

  late final AnimationController animationController;
  final _animationCompleter = Completer<void>();
  late Future<Either<CricketResponse<User>, CricketFailure>> _apiResponseFuture;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _markEntranceComplete();
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  /// The share code from a `/spectate/<code>` cold launch, or null for an
  /// ordinary launch. Resolved once, in [onReady], before [_apiResponseFuture]
  /// is even assigned — a spectator link must not fire `get-current-user` at
  /// all, not merely skip acting on its result.
  String? _spectatorCode;

  @override
  void onReady() {
    super.onReady();
    unawaited(_resolveAndNavigate());
  }

  Future<void> _resolveAndNavigate() async {
    _spectatorCode = await PendingDeepLink.readSpectatorCode();
    if (_spectatorCode == null) {
      _apiResponseFuture = getUserUseCase();
    }
    unawaited(_navigate());
  }

  /// Drives the one-shot brand entrance for [duration] and resolves once it
  /// completes — that completion is also this screen's minimum display
  /// floor, so a fast network response never flashes the splash.
  void startEntrance(Duration duration) {
    animationController
      ..duration = duration
      ..forward();
  }

  /// Jumps straight to the entrance's end state for reduced-motion — the
  /// brand moment should not move at all, not just move briefly.
  void skipEntrance() {
    animationController.value = 1;
  }

  void _markEntranceComplete() {
    if (!_animationCompleter.isCompleted) {
      _animationCompleter.complete();
    }
  }

  Future<void> _navigate() async {
    // Runs alongside the animation and (when applicable) getUserUseCase()
    // below rather than blocking ahead of them — it hits its own public,
    // unauthenticated endpoints and neither reads nor is read by either,
    // so serializing it before them only added dead time to every launch.
    final translationsFuture = Get.find<LanguageService>().fetchTranslationKeys(
      getVersionUseCase: getVersionUseCase,
      getLanguageUseCase: getLanguageUseCase,
    );

    final code = _spectatorCode;
    if (code != null) {
      // No user check, no onboarding check, no profile check — a spectator
      // link bypasses every branch below and every branch is auth-shaped.
      await Future.wait([_animationCompleter.future, translationsFuture]);
      unawaited(
        Get.offAllNamed(AppRoutes.spectatorPath(code)),
      );
      return;
    }

    final results = await Future.wait([
      _animationCompleter.future,
      _apiResponseFuture,
      translationsFuture,
    ]);

    final Either<CricketResponse<User>, CricketFailure> response =
        results[1] as Either<CricketResponse<User>, CricketFailure>;

    if (response.isResult) {
      try {
        bool? onboardingCompleted =
            await SharedPreferenceService.sharedPrefService.get(
                  SharedPrefKey.onboardingCompleted,
                )
                as bool?;
        if (onboardingCompleted == null || !onboardingCompleted) {
          unawaited(
            Get.offAllNamed(
              AppRoutes.onBoarding,
              arguments:
                  {
                        'profileCompleted':
                            response.result.data?.profileCompleted ?? false,
                      }
                      as Map<String, dynamic>,
            ),
          );
        } else if (!(response.result.data?.profileCompleted ?? false)) {
          unawaited(Get.offAllNamed(AppRoutes.updateProfile));
        } else {
          unawaited(Get.offAllNamed(AppRoutes.home));
        }
      } catch (e) {
        CricketSnackbar.showErrorMessage(
          TranslationKeys.somethingWentWrong,
        );
      }
    } else {
      // AuthInterceptor's _forceLogout() (auth_interceptor.dart) already
      // navigates to /login for exactly this failure — it runs inside the
      // same failed request's error handling, which completes strictly
      // before getUserUseCase()'s future resolves back here. Navigating
      // again unconditionally raced a second Get.offAllNamed against the
      // first LoginScreen's still-in-flight pop transition, which could
      // tear down (or double-mount) the first screen's LoginController
      // while it was still on screen. Same guard the interceptor itself
      // already uses before it decides whether it needs to act.
      if (Get.currentRoute != AppRoutes.login) {
        unawaited(Get.offAllNamed(AppRoutes.login));
      }
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
