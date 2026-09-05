import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_outlined_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Opens the assign/reassign/remove sheet for [item] — shared by
/// `HomePage` and `TeamProfileScreen` so the sheet itself isn't duplicated,
/// only the thin controller methods it calls (same duplication boundary
/// `TeamProfileController` already draws against `HomeController`).
///
/// [loadCandidates] returning `null` means an error was already shown by
/// the caller (e.g. the viewer has no assign-authority on this match) —
/// this function opens nothing in that case. An empty, non-null list means
/// the match has no organization-linked team to draw candidates from.
Future<void> showAssignScorerSheet({
  required MatchHistoryItem item,
  required Future<List<MatchUserRef>?> Function(String matchId)
  loadCandidates,
  required Future<bool> Function(String matchId, String? scorerId) onAssign,
}) async {
  final candidates = await loadCandidates(item.matchId);
  if (candidates == null) return;
  if (candidates.isEmpty) {
    CricketSnackbar.showErrorMessage(TranslationKeys.noScorerCandidates.tr);
    return;
  }

  final assigned = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.assignScorer.tr,
    child: SingleChildScrollView(
      child: Builder(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketText(
              text: TranslationKeys.tapToHandOffScoring.tr,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            16.h,
            for (final candidate in candidates)
              _CandidateRow(
                candidate: candidate,
                isCurrentlyAssigned: candidate.id == item.assignedScorer?.id,
                onTap: () async {
                  final success = await onAssign(item.matchId, candidate.id);
                  if (success) Get.back<bool>(result: true);
                },
              ),
            if (item.assignedScorer != null) ...[
              12.h,
              Divider(color: context.colorScheme.outline.withValues(alpha: 0.2)),
              12.h,
              CricketOutlinedButton(
                buttonName: TranslationKeys.removeAssignment.tr,
                onPressed: () async {
                  final success = await onAssign(item.matchId, null);
                  if (success) Get.back<bool>(result: true);
                },
              ),
            ],
          ],
        ),
      ),
    ),
  );

  if (assigned == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.scorerAssigned.tr);
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.candidate,
    required this.isCurrentlyAssigned,
    required this.onTap,
  });

  final MatchUserRef candidate;
  final bool isCurrentlyAssigned;
  final VoidCallback onTap;

  /// Same derivation as `OrganizationDetailScreen`/`_TeamHeader`'s own
  /// private `_monogram()` — duplicated rather than shared, matching this
  /// codebase's established pattern for this exact helper.
  String _monogram(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final letters = words.take(2).map((w) => w.isEmpty ? '' : w[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: context.colors.chipBackground,
                child: CricketText(
                  text: _monogram(candidate.name),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              12.w,
              Expanded(
                child: CricketText(
                  text: candidate.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
              if (isCurrentlyAssigned)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.statusSuccess.withValues(alpha: 0.12),
                    borderRadius: 8.radius,
                  ),
                  child: CricketText(
                    text: TranslationKeys.currentScorer.tr,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.statusSuccess,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
