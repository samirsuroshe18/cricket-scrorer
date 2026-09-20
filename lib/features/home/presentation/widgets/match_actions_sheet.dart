import 'dart:async';

import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/match_card_actions.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/assign_scorer_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The two management actions a Home card no longer wears on its face:
/// assigning a scorer and deleting the match. Opened by a long-press (or the
/// screen reader's custom action), so a live card carries no destructive icon
/// a thumb can hit by accident mid-match. The Matches tab still shows both
/// inline — that list is for management, this one is for glancing.
Future<void> showMatchActionsSheet({
  required HomeController controller,
  required MatchHistoryItem item,
}) {
  return Get.bottomSheet<void>(
    SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Get.context?.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Get.context?.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _Action(
              icon: Icons.person_add_alt,
              label: TranslationKeys.assignScorer.tr,
              onTap: () {
                Get.back<void>();
                unawaited(
                  showAssignScorerSheet(
                    item: item,
                    loadCandidates: controller.loadScorerCandidates,
                    onAssign: controller.assignScorer,
                  ),
                );
              },
            ),
            _Action(
              icon: Icons.delete_outline,
              label: TranslationKeys.deleteMatch.tr,
              destructive: true,
              onTap: () {
                Get.back<void>();
                unawaited(confirmDeleteMatch(controller, item));
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ink = destructive
        ? context.colors.statusDanger
        : context.colorScheme.onSurface;

    return ListTile(
      minTileHeight: 52,
      leading: Icon(icon, color: ink),
      title: CricketText(
        text: label,
        style: context.homeText(15, weight: FontWeight.w500, color: ink),
      ),
      onTap: onTap,
    );
  }
}
