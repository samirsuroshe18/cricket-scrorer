import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_entity_avatar.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/features/scoring/domain/squad_rules.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Opens a single-choice picker over the Playing XI for one leader role
/// (captain, vice-captain or keeper). [current] is the name that already
/// holds the role, if any; picking it again — or the explicit clear row —
/// both call [onPick] with that same name, matching `SquadDraft.setCaptain`
/// and its siblings, which clear a role when told to set it to whoever
/// already holds it.
Future<void> showLeaderPickerSheet({
  required String title,
  required String clearLabel,
  required List<SquadRow> candidates,
  required String? current,
  required void Function(String name) onPick,
}) async {
  await CustomBottomSheet.wrapBottomSheet<void>(
    headlineText: title,
    child: _LeaderPickerList(
      clearLabel: clearLabel,
      candidates: candidates,
      current: current,
      onPick: onPick,
    ),
  );
}

class _LeaderPickerList extends StatelessWidget {
  const _LeaderPickerList({
    required this.clearLabel,
    required this.candidates,
    required this.current,
    required this.onPick,
  });

  final String clearLabel;
  final List<SquadRow> candidates;
  final String? current;
  final void Function(String name) onPick;

  bool _isCurrent(SquadRow row) =>
      current != null && current!.toLowerCase() == row.name.toLowerCase();

  void _pick(String name) {
    Get.back<void>();
    onPick(name);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        for (final row in candidates) _candidateRow(context, row),
        if (current != null) _clearRow(context),
      ],
    );
  }

  Widget _candidateRow(BuildContext context, SquadRow row) {
    final selected = _isCurrent(row);
    return InkWell(
      key: Key('leader_picker_row_${row.name}'),
      onTap: () => _pick(row.name),
      child: Semantics(
        label: row.name,
        selected: selected,
        button: true,
        excludeSemantics: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CricketEntityAvatar(name: row.name, size: 40),
              12.w,
              Expanded(
                child: CricketText(
                  text: row.name,
                  style: context.textTheme.bodyLarge,
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? context.colorScheme.secondary
                    : context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _clearRow(BuildContext context) {
    return InkWell(
      key: const Key('leader_picker_clear'),
      onTap: () => _pick(current!),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.close, color: context.colorScheme.error),
            12.w,
            CricketText(
              text: clearLabel,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
