import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:flutter/material.dart';

/// One quiet, tonal pill. Never filled: the hero above owns the single red
/// call to action, and a second loud control would make Home shout twice.
class HomeActionPill extends StatelessWidget {
  const HomeActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: context.homeCardDecoration(),
        child: InkWell(
          onTap: onTap,
          borderRadius: 12.radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExcludeSemantics(
                    child: Icon(icon, size: 17, color: context.homeLiveText),
                  ),
                  6.w,
                  Flexible(
                    child: CricketText(
                      text: label,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      style: context.homeText(13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Equal-width row of [HomeActionPill]s with the design's 8px gutters.
class HomeActionRow extends StatelessWidget {
  const HomeActionRow({required this.pills, super.key});

  final List<HomeActionPill> pills;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < pills.length; i++) ...[
          if (i > 0) 8.w,
          Expanded(child: pills[i]),
        ],
      ],
    );
  }
}
