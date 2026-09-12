import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
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

/// The letters each flip tile clicks through before landing on its real
/// (last) letter — together they spell SCORER.
const _tileLetters = [
  ['B', 'K', 'S'],
  ['Q', 'J', 'C'],
  ['G', 'U', 'O'],
  ['N', 'Y', 'R'],
  ['A', 'L', 'E'],
  ['M', 'F', 'R'],
];

/// Progress through the [start, end] window of the overall entrance,
/// clamped to [0, 1] — the building block every staggered piece below is
/// timed from.
double _windowed(double t, double start, double end) {
  return ((t - start) / (end - start)).clamp(0.0, 1.0);
}

/// A one-shot brand entrance: the ball mark fades in, a row of scoreboard
/// flip-tiles clicks through to spell SCORER, then the wordmark, tagline
/// and a live-scoring pill settle in. The duration is fixed and known up
/// front — unlike a loaded asset (Lottie, video) there's nothing async to
/// wait on — so [SplashController] is told it once in [initState] and
/// resolves its own gate from the animation's completion.
class _SplashBody extends StatefulWidget {
  const _SplashBody({required this.controller});

  final SplashController controller;

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody> {
  static const _entranceDuration = Duration(milliseconds: 1100);

  bool _entranceStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entranceStarted) return;
    _entranceStarted = true;
    if (MediaQuery.of(context).disableAnimations) {
      widget.controller.skipEntrance();
    } else {
      widget.controller.startEntrance(_entranceDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entrance = widget.controller.animationController;
    final scheme = context.colorScheme;

    return ColoredBox(
      color: scheme.surfaceContainerLowest,
      child: Center(
        child: AnimatedBuilder(
          animation: entrance,
          builder: (context, _) {
            final t = entrance.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Ball(t: t),
                const SizedBox(height: 22),
                _TileBoard(t: t, scheme: scheme),
                const SizedBox(height: 20),
                _FadeUp(
                  t: t,
                  start: 0.62,
                  end: 0.80,
                  child: Column(
                    children: [
                      Text(
                        'CRICKET',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track every ball, every run',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _LivePill(t: t, scheme: scheme, live: context.colors.statusSuccess),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Ball extends StatelessWidget {
  const _Ball({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final local = _windowed(t, 0.0, 0.32);
    final bounce = Curves.easeOutBack.transform(local);
    return Opacity(
      opacity: local,
      child: Transform.scale(
        scale: 0.7 + (0.3 * bounce),
        child: Image.asset(AssetsUtil.ballMark, width: 68, height: 55),
      ),
    );
  }
}

class _TileBoard extends StatelessWidget {
  const _TileBoard({required this.t, required this.scheme});

  final double t;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: List.generate(
        _tileLetters.length,
        (i) => _Tile(t: t, index: i, letters: _tileLetters[i], scheme: scheme),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.t,
    required this.index,
    required this.letters,
    required this.scheme,
  });

  final double t;
  final int index;
  final List<String> letters;
  final ColorScheme scheme;

  static const _staggerStart = 0.16;
  static const _staggerStep = 0.075;
  static const _tileWindow = 0.22;

  // Frame-invariant, so it's built once rather than reallocated every tick.
  static const _glintGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x8CFFFFFF), Color(0x00FFFFFF)],
    stops: [0.0, 0.65],
  );

  @override
  Widget build(BuildContext context) {
    final start = _staggerStart + (index * _staggerStep);
    final end = start + _tileWindow;
    final local = _windowed(t, start, end);
    final containerOpacity = _windowed(t, start, start + 0.04);
    final letter = letters[local < 0.4 ? 0 : (local < 0.75 ? 1 : 2)];

    // A brief highlight right after the tile lands on its real letter — a
    // triangular pulse built from the same _windowed primitive as everything
    // else: ramps up over [0.78, 0.86], then back down over [0.86, 0.98].
    final glintRise = _windowed(local, 0.78, 0.86);
    final glintFall = 1 - _windowed(local, 0.86, 0.98);
    final glintOpacity = glintRise < glintFall ? glintRise : glintFall;

    return Opacity(
      opacity: containerOpacity,
      child: Container(
        width: 42,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: 6.radius,
          border: Border.all(color: scheme.outline),
        ),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 1,
                color: scheme.outline.withValues(alpha: 0.4),
              ),
            ),
            IgnorePointer(
              child: Opacity(
                opacity: glintOpacity,
                child: const DecoratedBox(
                  decoration: BoxDecoration(gradient: _glintGradient),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeUp extends StatelessWidget {
  const _FadeUp({
    required this.t,
    required this.start,
    required this.end,
    required this.child,
  });

  final double t;
  final double start;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final local = _windowed(t, start, end);
    return Opacity(
      opacity: local,
      child: Transform.translate(
        offset: Offset(0, (1 - local) * 6),
        child: child,
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill({required this.t, required this.scheme, required this.live});

  final double t;
  final ColorScheme scheme;
  final Color live;

  @override
  Widget build(BuildContext context) {
    final local = _windowed(t, 0.80, 0.95);
    final ping = _windowed(t, 0.85, 1.0);

    return Opacity(
      opacity: local,
      child: Container(
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
                  Opacity(
                    opacity: 1 - ping,
                    child: Container(
                      width: 8 + (10 * ping),
                      height: 8 + (10 * ping),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: live.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: live),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'LIVE SCORING',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: live,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
