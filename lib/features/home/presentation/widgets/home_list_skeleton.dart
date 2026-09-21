import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_grouped_card.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A grouped list's shape in blocks — avatar, name, one muted line — shown
/// while its first fetch is in flight. Same gentle pulse (and the same still
/// placeholder for reduce-motion users) as `MatchesSkeleton`.
class HomeListSkeleton extends StatefulWidget {
  const HomeListSkeleton({this.rows = 3, super.key});

  final int rows;

  @override
  State<HomeListSkeleton> createState() => _HomeListSkeletonState();
}

class _HomeListSkeletonState extends State<HomeListSkeleton>
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
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) =>
            Opacity(opacity: 0.55 + 0.45 * _pulse.value, child: child),
        child: CricketGroupedCard(
          children: [
            for (var i = 0; i < widget.rows; i++) const _SkeletonRow(),
          ],
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _block(context, height: 44, width: 44, radius: 22),
            12.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(context, height: 14, width: 140, radius: 6),
                  6.h,
                  _block(context, height: 11, width: 90, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _block(
    BuildContext context, {
    required double height,
    required double width,
    required double radius,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.colorScheme.outline,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
