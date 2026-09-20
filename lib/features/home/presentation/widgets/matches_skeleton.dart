import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The Matches list's shape in blocks, shown while the first fetch is in
/// flight — the same gentle pulse (and the same still placeholder for
/// reduce-motion users) as [HomeSkeleton], so switching tabs during a cold
/// start does not swap a skeleton for a bare spinner.
class MatchesSkeleton extends StatefulWidget {
  const MatchesSkeleton({super.key});

  @override
  State<MatchesSkeleton> createState() => _MatchesSkeletonState();
}

class _MatchesSkeletonState extends State<MatchesSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              return Opacity(
                opacity: 0.55 + 0.45 * _pulse.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _block(context, height: 16, width: 96, radius: 6),
                    10.h,
                    _block(context, height: 104, radius: 14),
                    8.h,
                    _block(context, height: 104, radius: 14),
                    18.h,
                    _block(context, height: 16, width: 120, radius: 6),
                    10.h,
                    _block(context, height: 116, radius: 14),
                    8.h,
                    _block(context, height: 116, radius: 14),
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
