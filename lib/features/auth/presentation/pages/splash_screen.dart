import 'dart:async';

import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _SplashBody(controller: controller));
  }
}

/// A short brand entrance (logo fade/scale) plus a slim progress
/// affordance that only appears if routing is still pending after
/// [_connectingDelay]. Both are purely presentational — [SplashController]
/// only ever receives the fixed [_brandMomentDuration] via its existing
/// [SplashController.onLottieLoaded] entry point, same as before.
class _SplashBody extends StatefulWidget {
  const _SplashBody({required this.controller});

  final SplashController controller;

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody> {
  static const _brandMomentDuration = Duration(milliseconds: 650);
  static const _connectingDelay = Duration(milliseconds: 2500);

  Timer? _connectingTimer;
  bool _showConnecting = false;

  @override
  void initState() {
    super.initState();
    widget.controller.onLottieLoaded(_brandMomentDuration);
    _connectingTimer = Timer(_connectingDelay, () {
      if (mounted) setState(() => _showConnecting = true);
    });
  }

  @override
  void dispose() {
    _connectingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entrance = widget.controller.animationController;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: entrance,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(parent: entrance, curve: Curves.easeOut),
              ),
              child: Image.asset(
                AssetsUtil.splashLogo,
                width: 152,
                height: 152,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _showConnecting ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: context.colorScheme.outline,
                    valueColor: AlwaysStoppedAnimation(
                      context.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
