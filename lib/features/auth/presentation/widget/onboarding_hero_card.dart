import 'package:cricket_scorer/config/theme/palettes/app_custom_colors_palette.dart';
import 'package:cricket_scorer/config/theme/palettes/custom_color_scheme.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// The card always previews the app's live-scoring surface, which is dark
// navy regardless of the device's light/dark setting — so it reads from the
// dark palette directly rather than from the ambient (possibly light) theme.
const _kScheme = CustomColorScheme.darkColorScheme;
const _kCustom = AppCustomColorsPalette.dark;

// A floor, not a cap: all three pages' cards read as one consistent shape
// while swiping under normal conditions, tall enough for the Live Scoring
// card, the tallest of the three (measured ~263 at the onboarding column's
// content width). At a large text-scale factor content is allowed to grow
// past this instead of clipping — matching height everywhere would mean
// clipped text for anyone using larger accessibility text sizes.
const _kHeroCardMinHeight = 268.0;

/// A per-page "product preview" hero shown on the onboarding screen: a small
/// still of the live-scoring UI, styled in the app's own dark scoreboard
/// surface rather than a stock illustration.
class OnboardingHeroCard extends StatelessWidget {
  const OnboardingHeroCard({super.key, required this.pageIndex});

  /// Index into [OnboardingController.onboardingPages] (0, 1 or 2).
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return switch (pageIndex) {
      0 => const _LiveScoringHero(),
      1 => const _MatchStatsHero(),
      2 => const _ShareVictoryHero(),
      _ => const SizedBox.shrink(),
    };
  }
}

class _HeroCardShell extends StatelessWidget {
  const _HeroCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _kHeroCardMinHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _kScheme.surface,
            borderRadius: 20.radius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            // Stretch + center: shorter pages (stats grid, share victory)
            // sit vertically centered against the shared minimum height
            // instead of clinging to the top, while still filling the
            // card's full width so each hero's own cross-axis alignment
            // (start, in most of them) reads against the whole card, not a
            // shrunk column.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [child],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveScoringHero extends StatelessWidget {
  const _LiveScoringHero();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return _HeroCardShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _kCustom.statusDanger,
                  shape: BoxShape.circle,
                ),
              ),
              8.w,
              CricketText(
                text: TranslationKeys.statusLive.tr.toUpperCase(),
                style: textTheme.labelLarge?.copyWith(
                  color: _kCustom.statusDanger,
                ),
              ),
            ],
          ),
          20.h,
          CricketText(
            text: '148/4',
            style: textTheme.displayLarge?.copyWith(color: _kScheme.onSurface),
          ),
          4.h,
          CricketText(
            text: '20.0 ${TranslationKeys.overs.tr}',
            style: textTheme.labelSmall?.copyWith(
              color: _kScheme.onSurfaceVariant,
            ),
          ),
          20.h,
          Container(height: 1, color: _kScheme.outline),
          20.h,
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: TranslationKeys.onboardingRunRateLabel.tr,
                  value: '7.40',
                ),
              ),
              16.w,
              Expanded(
                child: _MiniStat(
                  label: TranslationKeys.onboardingThisOverLabel.tr,
                  value: '1 · 4 · W · 2 · 6 · 1',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CricketText(
          text: label,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
          style: textTheme.labelSmall?.copyWith(
            color: _kScheme.onSurfaceVariant,
          ),
        ),
        2.h,
        CricketText(
          text: value,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(color: _kScheme.onSurface),
        ),
      ],
    );
  }
}

class _MatchStatsHero extends StatelessWidget {
  const _MatchStatsHero();

  @override
  Widget build(BuildContext context) {
    return _HeroCardShell(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: _StatTile(
              label: TranslationKeys.onboardingHighestOverLabel.tr,
              value: '14',
              range: TranslationKeys.onboardingOverRange.trParams({
                'range': '9-14',
              }),
            ),
          ),
          10.w,
          Expanded(
            child: _StatTile(
              label: TranslationKeys.onboardingPowerplayLabel.tr,
              value: '45',
              range: TranslationKeys.onboardingOverRange.trParams({
                'range': '1-6',
              }),
            ),
          ),
          10.w,
          Expanded(
            child: _StatTile(
              label: TranslationKeys.onboardingDeathOversLabel.tr,
              value: '25',
              range: TranslationKeys.onboardingOverRange.trParams({
                'range': '17-20',
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.range,
  });

  final String label;
  final String value;
  final String range;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _kCustom.chipBackground,
        borderRadius: 12.radius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 20, height: 2, color: _kCustom.statusInfo),
            8.h,
            CricketText(
              text: label,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: _kScheme.onSurfaceVariant,
              ),
            ),
            4.h,
            CricketText(
              text: value,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(color: _kScheme.onSurface),
            ),
            2.h,
            CricketText(
              text: range,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: _kScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareVictoryHero extends StatelessWidget {
  const _ShareVictoryHero();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return _HeroCardShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 48,
            color: _kCustom.statusSuccess,
          ),
          16.h,
          CricketText(
            text: TranslationKeys.onboardingSampleResult.tr,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(color: _kScheme.onSurface),
          ),
          4.h,
          CricketText(
            text: TranslationKeys.onboardingSampleContext.tr,
            style: textTheme.labelSmall?.copyWith(
              color: _kScheme.onSurfaceVariant,
            ),
          ),
          16.h,
          DecoratedBox(
            decoration: BoxDecoration(
              color: _kScheme.tertiary,
              borderRadius: 20.radius,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The card's own dark-navy surface, not onTertiary (white)
                  // — white-on-this-green is ~1.8:1, well under WCAG AA;
                  // the dark navy reaches ~8:1.
                  Icon(
                    Icons.ios_share_rounded,
                    size: 14,
                    color: _kScheme.surface,
                  ),
                  8.w,
                  Flexible(
                    child: CricketText(
                      text: TranslationKeys.onboardingShareScorecard.tr,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: _kScheme.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
