import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/data/models/onboarding_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  bool _profileCompleted = false;
  final pageController = PageController();
  RxInt currentPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _profileCompleted = args?['profileCompleted'] as bool? ?? false;
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  void skip() {
    finishOnboarding();
  }

  Future<void> finishOnboarding() async {
    await SharedPreferenceService.sharedPrefService.set(
      SharedPrefKey.onboardingCompleted,
      true,
    );
    if (_profileCompleted) {
      unawaited(Get.offAllNamed(AppRoutes.home));
    } else {
      unawaited(Get.offAllNamed(AppRoutes.updateProfile));
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  final onboardingPages = [
    OnboardingItem(
      image: AssetsUtil.onboarding1,
      title: TranslationKeys.liveScoring.tr,
      description: TranslationKeys.liveScoringDesc.tr,
    ),
    OnboardingItem(
      image: AssetsUtil.onboarding2,
      title: TranslationKeys.deepMatchStats.tr,
      description: TranslationKeys.deepMatchStatsDesc.tr,
    ),
    OnboardingItem(
      image: AssetsUtil.onboarding3,
      title: TranslationKeys.shareTheVictory.tr,
      description: TranslationKeys.shareTheVictoryDesc.tr,
    ),
  ];
}
