import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Who is facing, straight from the server. Both batsmen stay on screen and the
/// striker is marked three ways at once — a filled dot, heavier type, and the
/// accent colour — because a scorer reads this at arm's length in daylight,
/// where weight alone does not carry.
class StrikeBanner extends StatelessWidget {
  const StrikeBanner({required this.strike, super.key});

  final Strike? strike;

  @override
  Widget build(BuildContext context) {
    final current = strike;

    return Container(
      width: double.infinity,
      padding: 16.p,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: 12.radius,
      ),
      child: current?.strikerName == null
          ? const _EmptyPrompt()
          : Row(
              children: [
                Expanded(
                  child: _BatsmanTile(
                    name: current!.strikerName!,
                    label: TranslationKeys.striker.tr,
                    isOnStrike: true,
                  ),
                ),
                Expanded(
                  child: _BatsmanTile(
                    name: current.nonStrikerName ?? '-',
                    label: TranslationKeys.nonStriker.tr,
                    isOnStrike: false,
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt();

  @override
  Widget build(BuildContext context) {
    return CricketText(
      text: TranslationKeys.chooseOpeners.tr,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _BatsmanTile extends StatelessWidget {
  const _BatsmanTile({
    required this.name,
    required this.label,
    required this.isOnStrike,
  });

  final String name;
  final String label;
  final bool isOnStrike;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorScheme.primary;
    final muted = context.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isOnStrike ? Icons.circle : Icons.circle_outlined,
              size: 12,
              color: isOnStrike ? accent : muted,
            ),
            6.w,
            Flexible(
              child: CricketText(
                text: label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isOnStrike ? accent : muted,
                ),
              ),
            ),
          ],
        ),
        4.h,
        CricketText(
          text: name,
          style: isOnStrike
              ? context.textTheme.titleMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                )
              : context.textTheme.bodyMedium?.copyWith(color: muted),
        ),
      ],
    );
  }
}
