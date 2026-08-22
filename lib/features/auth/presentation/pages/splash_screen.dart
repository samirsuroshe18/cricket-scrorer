import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          AssetsUtil.splashLoader,
          controller: controller.animationController,
          onLoaded: (composition) {
            controller.onLottieLoaded(composition.duration);
          },
        ),
      ),
    );
  }
}
