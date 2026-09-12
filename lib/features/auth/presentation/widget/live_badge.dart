import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The pill-shaped "live" indicator shared by the splash entrance and the
/// login screen — a dot plus a label, themed via [context.colors.statusSuccess].
///
/// [pulsing] drives a persistent radiating ring on the dot, for chrome
/// that's always on screen (the login header). Leave it off (the default)
/// for splash, which instead wraps this in its own one-shot entrance ping.
class LiveBadge extends StatefulWidget {
  const LiveBadge({super.key, this.pulsing = false});

  final bool pulsing;

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || !widget.pulsing) return;
    _started = true;
    // A perpetually-repeating pulse is exactly the motion WCAG 2.3.3 asks
    // to gate — skip starting the ticker at all when the user has reduced
    // motion on, rather than starting it and hoping nothing checks later.
    if (MediaQuery.of(context).disableAnimations) return;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      // Bounded, not infinite: draws the eye a few times then settles to a
      // steady dot, rather than animating for as long as the screen is
      // mounted — kinder to battery/motion-sensitive users, and avoids the
      // whole class of test/tooling problems an unbounded ticker invites.
    )..repeat(count: 3);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final live = context.colors.statusSuccess;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: 999.radius,
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_controller != null)
                  AnimatedBuilder(
                    animation: _controller!,
                    builder: (context, _) {
                      final t = _controller!.value;
                      return Opacity(
                        opacity: (1 - t).clamp(0.0, 1.0),
                        child: Container(
                          width: 8 + (10 * t),
                          height: 8 + (10 * t),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: live.withValues(alpha: 0.35),
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: live,
                  ),
                ),
              ],
            ),
          ),
          5.w,
          Text(
            TranslationKeys.liveScoring.tr.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: live,
            ),
          ),
        ],
      ),
    );
  }
}
