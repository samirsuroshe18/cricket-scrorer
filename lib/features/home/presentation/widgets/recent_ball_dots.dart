import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/features/home/presentation/utils/home_match_view.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/material.dart';

/// The last few deliveries as small coloured dots, oldest on the left — the
/// order an over reads in. Boundaries read green, wickets red, extras amber,
/// everything else neutral, so a scorer can take in "how's it going" from the
/// colours alone.
class RecentBallDots extends StatelessWidget {
  const RecentBallDots({required this.balls, super.key});

  final List<RecentBall> balls;

  @override
  Widget build(BuildContext context) {
    final labels = balls.map(recentBallLabel).join(', ');

    return Semantics(
      label: labels,
      excludeSemantics: true,
      child: Row(
        children: [
          for (final ball in balls)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 5),
              child: _Dot(ball: ball),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.ball});

  final RecentBall ball;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final colors = context.colors;
    final label = recentBallLabel(ball);

    final (Color fill, Color ink) = switch (recentBallKind(ball)) {
      RecentBallKind.wicket => (scheme.primary, Colors.white),
      RecentBallKind.boundary => (colors.successCard, colors.statusSuccess),
      RecentBallKind.extra => (colors.warningCard, colors.statusWarning),
      RecentBallKind.plain => (scheme.outline, scheme.onSurface),
    };

    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
      child: CricketText(
        text: label,
        maxLines: 1,
        style: context.homeText(
          label.length > 2 ? 9 : 11,
          weight: FontWeight.w600,
          color: ink,
        ),
      ),
    );
  }
}
