import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:flutter/material.dart';

enum HomeStripTone { warning, danger, neutral }

/// A single line above the hero for something that needs attention but isn't
/// the screen's subject: unsynced balls, a sync conflict, a failed refresh.
/// One at a time — the dashboard picks the most serious.
class HomeStatusStrip extends StatelessWidget {
  const HomeStatusStrip({
    required this.tone,
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onTap,
    super.key,
  });

  final HomeStripTone tone;
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = context.colorScheme;
    final ink = switch (tone) {
      HomeStripTone.warning => colors.statusWarning,
      HomeStripTone.danger => colors.statusDanger,
      HomeStripTone.neutral => scheme.onSurfaceVariant,
    };

    return Semantics(
      button: true,
      label: '$message. $actionLabel',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: ink.withValues(alpha: 0.14),
            borderRadius: 12.radius,
            border: Border.all(color: ink.withValues(alpha: 0.4)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: 12.radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: ink),
                    8.w,
                    Expanded(
                      child: CricketText(
                        text: message,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                        style: context.homeText(13, color: ink),
                      ),
                    ),
                    8.w,
                    CricketText(
                      text: actionLabel,
                      style: context
                          .homeText(13, color: ink)
                          .copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: ink,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
