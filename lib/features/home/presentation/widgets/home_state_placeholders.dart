import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The empty/error placeholders both the Home dashboard tab and the Matches
/// tab need — pulled out of the old single-screen `HomePage` (which used to
/// own a private copy of each) so both tabs render the same look instead of
/// drifting apart.
class EmptyMatchesState extends StatelessWidget {
  const EmptyMatchesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: 24.p,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_cricket_outlined,
              size: 56,
              color: context.colorScheme.onSurfaceVariant,
            ),
            16.h,
            CricketText(
              text: TranslationKeys.noMatchesYet.tr,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            8.h,
            CricketText(
              text: TranslationKeys.noMatchesYetHint.tr,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            24.h,
            CricketButton(
              buttonText: TranslationKeys.startFirstMatch.tr,
              prefixIcon: const Icon(Icons.add),
              onPressed: () => Get.toNamed<dynamic>(AppRoutes.createMatch),
              width: 220,
            ),
          ],
        ),
      ),
    );
  }
}

class MatchesErrorState extends StatelessWidget {
  const MatchesErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: 24.p,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: context.colorScheme.onSurfaceVariant,
            ),
            16.h,
            CricketText(
              text: message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            24.h,
            CricketButton(
              buttonText: TranslationKeys.retry.tr,
              onPressed: () => onRetry(),
              width: 160,
            ),
          ],
        ),
      ),
    );
  }
}

/// A section header used by every capped preview list on the Home dashboard
/// ("Live Now", "Continue Scoring", "Recent Matches") — an optional
/// "See all" jumps to the Matches tab instead of pushing a new route, since
/// it's the same shell, just a different tab.
class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    required this.title,
    this.onSeeAll,
    super.key,
  });

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CricketText(
          text: title,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: CricketText(
              text: TranslationKeys.seeAll.tr,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.secondary,
              ),
            ),
          ),
      ],
    );
  }
}
