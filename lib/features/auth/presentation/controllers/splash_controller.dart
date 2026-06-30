import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/error_string_constants.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
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
    animationController = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  @override
  void onReady() {
    super.onReady();
    _apiResponseFuture = getUserUseCase();
    _navigate();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  /// Called from the view once Lottie composition loads
  void onLottieLoaded(Duration compositionDuration) {
    animationController
      ..duration = compositionDuration
      ..forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _markAnimationComplete();
      }
    });
  }

  void _markAnimationComplete() {
    if (!_animationCompleter.isCompleted) {
      _animationCompleter.complete();
    }
  }

  Future<void> _navigate() async {
    await Get.find<LanguageService>().fetchTranslationKeys(
      getVersionUseCase: getVersionUseCase,
      getLanguageUseCase: getLanguageUseCase,
    );

    final results = await Future.wait([
      _animationCompleter.future,
      _apiResponseFuture,
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
          ErrorStringConstants.somethingWentWrong,
        );
      }
    } else {
      unawaited(Get.offAllNamed(AppRoutes.login));
    }
  }
}
