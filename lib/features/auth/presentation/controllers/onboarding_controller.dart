import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
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
      image: 'assets/images/onboarding_1.png',
      title: 'Live Scoring',
      description:
          'Record every run, wicket, current over with intuitive controls.',
      color: Get.context?.colors.teamA,
    ),
    OnboardingItem(
      image: 'assets/images/onboarding_2.png',
      title: 'deep Match stats',
      description: 'Track your match progress and key stats in real-time.',
    ),
    OnboardingItem(
      image: 'assets/images/onboarding_3.png',
      title: 'Share The victory',
      description: 'Instantly share match summaries and team stats.',
    ),
  ];
}
