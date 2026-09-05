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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 8.radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: CricketText(
                  text: candidate.name,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
              if (isCurrentlyAssigned)
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: context.colors.statusSuccess,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
