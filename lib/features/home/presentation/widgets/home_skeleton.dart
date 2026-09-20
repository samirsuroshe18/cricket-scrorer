import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_header.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The dashboard's shape in blocks, shown while the first fetch is in flight.
/// The header is the real one (it needs no network), so the screen never
/// looks blank; everything below it pulses gently.
class HomeSkeleton extends StatefulWidget {
  const HomeSkeleton({required this.user, super.key});

  final User? user;

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduce-motion users get a still placeholder rather than a pulse.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: TranslationKeys.homeLoading.tr,
      excludeSemantics: true,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          HomeHeader(user: widget.user),
          16.h,
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final opacity = 0.55 + 0.45 * _pulse.value;
              return Opacity(
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(context, height: 170, radius: 18),
                    16.h,
                    Row(
                      children: [
                        Expanded(child: _block(context, height: 44)),
                        8.w,
                        Expanded(child: _block(context, height: 44)),
                        8.w,
                        Expanded(child: _block(context, height: 44)),
                      ],
                    ),
                    18.h,
                    _block(context, height: 16, width: 110, radius: 6),
                    10.h,
                    _block(context, height: 96, radius: 14),
                    18.h,
                    _block(context, height: 16, width: 140, radius: 6),
                    10.h,
                    _block(context, height: 56, radius: 8),
                    8.h,
                    _block(context, height: 56, radius: 8),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _block(
    BuildContext context, {
    required double height,
    double? width,
    double radius = 12,
  }) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: context.isDark
            ? context.homeCard
            : context.colorScheme.outline.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
