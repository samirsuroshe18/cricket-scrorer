import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Current/required run rate and the not-out pair's partnership. Shared
/// between the scorer's console and the spectator screen — see
/// `run_rate.dart` for why the numbers themselves can never disagree between
/// the two.
class RateStatsLine extends StatelessWidget {
  const RateStatsLine({
    super.key,
    required this.currentRunRate,
    required this.requiredRunRate,
    required this.partnershipRuns,
    required this.partnershipBalls,
    this.highContrast = false,
  });

  final double currentRunRate;

  /// Null in innings 1, or once no legal deliveries remain — hides the RRR
  /// half entirely rather than showing a meaningless number.
  final double? requiredRunRate;

  final int partnershipRuns;
  final int partnershipBalls;

  /// Opts into `onSurface` at a heavier weight instead of the default muted
  /// `onSurfaceVariant` — for the scorer's console, read outdoors under
  /// pressure, not the dimmer-screen spectator view this widget also serves.
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final style = highContrast
        ? context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          )
        : context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CricketText(
              text:
                  '${TranslationKeys.currentRunRateShort.tr}: '
                  '${currentRunRate.toStringAsFixed(2)}',
              style: style,
            ),
            if (requiredRunRate != null) ...[
              16.w,
              CricketText(
                text:
                    '${TranslationKeys.requiredRunRateShort.tr}: '
                    '${requiredRunRate!.toStringAsFixed(2)}',
                style: style,
              ),
            ],
          ],
        ),
        4.h,
        CricketText(
          text:
              '${TranslationKeys.partnership.tr}: '
              '$partnershipRuns ($partnershipBalls)',
          style: style,
        ),
      ],
    );
  }
}
