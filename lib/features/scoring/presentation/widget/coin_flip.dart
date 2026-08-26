import 'dart:async';
import 'dart:math';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// An animated coin the scorer taps to decide the toss, for a match with no
/// physical coin at hand. One face is [TranslationKeys.teamA], the other
/// [TranslationKeys.teamB] — the outcome is decided *before* the animation
/// starts (a fair 50/50 pick), and the spin is purely a reveal, never a
/// suspense mechanic the result could contradict.
///
/// Entirely self-contained: owns its own [AnimationController] and idle/
/// flipping/landed state. The only thing that leaves this widget is
/// [onResult] once a flip settles — everything about *how* it settles is
/// private to this file.
class CoinFlip extends StatefulWidget {
  const CoinFlip({super.key, required this.onResult});

  /// Called once per completed flip with `'teamA'` or `'teamB'`.
  final ValueChanged<String> onResult;

  @override
  State<CoinFlip> createState() => _CoinFlipState();
}

class _CoinFlipState extends State<CoinFlip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _random = Random();

  /// Null before the first flip.
  String? _target;

  /// Total half-turns for the *current* flip, decided fresh each time so
  /// consecutive flips don't look identical. Always chosen so its parity
  /// matches [_target] — see [_flip].
  int _halfTurns = 6;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  Future<void> _flip() async {
    if (_controller.isAnimating) return;

    final landsOnA = _random.nextBool();
    _target = landsOnA ? 'teamA' : 'teamB';

    // At least 6 half-turns for a visible spin; nudged up by one when that
    // count's parity would land on the wrong face. The exact count only
    // controls how many times it visibly rotates — parity is what decides
    // which face is up when it stops.
    final base = 6 + _random.nextInt(4);
    _halfTurns = (base.isEven == landsOnA) ? base : base + 1;

    _controller.value = 0;
    await _controller.forward();

    // Guarantees one rebuild reflecting the settled, non-animating state
    // even if the controller's own final tick and `isAnimating` flipping to
    // false don't land in the same frame.
    if (mounted) setState(() {});

    widget.onResult(_target!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _controller.isAnimating ? null : () => unawaited(_flip()),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.isAnimating || _controller.isCompleted
                  ? Curves.easeOutCubic.transform(_controller.value) *
                        _halfTurns *
                        pi
                  : 0.0;
              final normalized = angle % (2 * pi);
              final showingA = normalized <= pi / 2 || normalized >= 3 * pi / 2;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: _CoinFace(
                  label: showingA
                      ? TranslationKeys.teamA.tr
                      : TranslationKeys.teamB.tr,
                  // The rotation above mirrors whichever face is on the far
                  // side — without counter-flipping it here, Team B's label
                  // would render backwards for half of every spin.
                  mirrored: !showingA,
                  color: showingA
                      ? context.colorScheme.primaryContainer
                      : context.colorScheme.secondaryContainer,
                ),
              );
            },
          ),
        ),
        12.h,
        CricketText(
          text: _controller.isAnimating || _target == null
              ? TranslationKeys.tapToFlip.tr
              : TranslationKeys.tapToReflip.tr,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CoinFace extends StatelessWidget {
  const _CoinFace({
    required this.label,
    required this.mirrored,
    required this.color,
  });

  final String label;
  final bool mirrored;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final face = Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: context.colorScheme.outline, width: 2),
      ),
      child: CricketText(
        text: label,
        style: context.textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );

    if (!mirrored) return face;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: face,
    );
  }
}
