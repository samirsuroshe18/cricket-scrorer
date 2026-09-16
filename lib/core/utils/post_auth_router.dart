import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:get/get.dart';

/// The single post-authentication landing decision, shared by every place
/// that resolves an authenticated user's first screen: [SplashController]
/// after a silent session restore, and [LoginController] after a fresh
/// login. Kept here — rather than duplicated in each controller — so the
/// two can't drift out of sync with each other again.
class PostAuthRouter {
  PostAuthRouter._();

  /// Navigates to onboarding, profile completion, or home, based on the
  /// locally cached onboarding flag and the freshly fetched user's
  /// [profileCompleted] state.
  ///
  /// Resolves as soon as the navigation call is issued — it deliberately
  /// does not wait on [Get.offAllNamed]'s own future, which only completes
  /// when the pushed screen is later popped. That keeps this awaitable
  /// safely from a caller's try/catch (to catch the shared-prefs read
  /// above) without hanging until the user navigates away again.
  static Future<void> route({required bool profileCompleted}) async {
    final onboardingCompleted =
        await SharedPreferenceService.sharedPrefService.get(
              SharedPrefKey.onboardingCompleted,
            )
            as bool?;

    if (onboardingCompleted == null || !onboardingCompleted) {
      unawaited(
        Get.offAllNamed(
          AppRoutes.onBoarding,
          arguments: {'profileCompleted': profileCompleted},
        ),
      );
    } else if (!profileCompleted) {
      unawaited(Get.offAllNamed(AppRoutes.updateProfile));
    } else {
      unawaited(Get.offAllNamed(AppRoutes.home));
    }
  }
}
