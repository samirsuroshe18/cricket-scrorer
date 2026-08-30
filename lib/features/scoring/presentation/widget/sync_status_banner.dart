import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/data_sources/local/offline_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The one persistently-visible signal that the console isn't quietly losing
/// a scorer's work. Hidden when there is genuinely nothing to report —
/// everything synced and idle — same early-return convention as
/// [RateStatsLine]/[TossLine]; visible in every other state, including while
/// a flush is actually in flight, so "syncing" is never silently
/// indistinguishable from "stuck".
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({
    required this.pendingCount,
    required this.phase,
    required this.lastError,
    required this.onRetry,
    super.key,
  });

  final int pendingCount;
  final SyncPhase phase;
  final String? lastError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0 && phase == SyncPhase.idle) {
      return const SizedBox.shrink();
    }

    final Color accent;
    final String message;
    switch (phase) {
      case SyncPhase.conflict:
        accent = context.colors.statusDanger;
        message = TranslationKeys.syncConflictTitle.tr;
      case SyncPhase.blockedOnRule:
        accent = context.colors.statusWarning;
        message = TranslationKeys.syncBlockedOnRule.tr;
      case SyncPhase.syncing:
        accent = context.colors.statusInfo;
        message = TranslationKeys.syncingNow.tr;
      case SyncPhase.idle:
        accent = context.colors.statusWarning;
        message = '$pendingCount ${TranslationKeys.unsyncedDeliveries.tr}';
    }

    return Container(
      width: double.infinity,
      padding: 12.ph.copyWith(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: 12.radius,
      ),
      child: Row(
        children: [
          Icon(LucideIcons.cloudOff, size: 16, color: accent),
          8.w,
          Expanded(
            child: CricketText(
              text: message,
              style: context.textTheme.bodySmall?.copyWith(color: accent),
              maxLines: 2,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
          // No retry affordance while a flush is already running, and none
          // for a conflict or a blocked-on-rule state — both are resolved
          // through their own alert sheet, which
          // `ScoreBallController._promptIfNeeded` reopens on tap, via
          // [onRetry] being reused as the "review it again" trigger. The
          // icon reflects that: a triangle (needs a decision), never the
          // refresh glyph, for either — a blocked delivery cannot actually
          // be fixed by retrying.
          if (phase == SyncPhase.syncing)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              tooltip: switch (phase) {
                SyncPhase.conflict => TranslationKeys.syncConflictTitle.tr,
                SyncPhase.blockedOnRule => TranslationKeys.syncBlockedTitle.tr,
                SyncPhase.syncing || SyncPhase.idle =>
                  TranslationKeys.retrySync.tr,
              },
              icon: Icon(
                phase == SyncPhase.conflict || phase == SyncPhase.blockedOnRule
                    ? LucideIcons.triangleAlert
                    : LucideIcons.refreshCw,
                size: 18,
                color: accent,
              ),
              onPressed: onRetry,
            ),
        ],
      ),
    );
  }
}
