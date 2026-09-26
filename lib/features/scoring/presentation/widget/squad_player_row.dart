import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/domain/squad_rules.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One player of the squad being edited: name, role chips, and the C / VC /
/// WK toggles. Stateless — every change goes back out through a callback so
/// `SquadController` stays the single owner of the draft.
class SquadPlayerRow extends StatelessWidget {
  const SquadPlayerRow({
    super.key,
    required this.row,
    required this.isCaptain,
    required this.isViceCaptain,
    required this.isKeeper,
    required this.onRole,
    required this.onCaptain,
    required this.onViceCaptain,
    required this.onKeeper,
    required this.onRemove,
  });

  final SquadRow row;
  final bool isCaptain;
  final bool isViceCaptain;
  final bool isKeeper;
  final ValueChanged<String> onRole;
  final VoidCallback onCaptain;
  final VoidCallback onViceCaptain;
  final VoidCallback onKeeper;
  final VoidCallback onRemove;

  static String roleLabel(String role) => switch (role) {
    'bowler' => TranslationKeys.roleBowler.tr,
    'allrounder' => TranslationKeys.roleAllrounder.tr,
    _ => TranslationKeys.roleBatsman.tr,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('squad_row_${row.name}'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: 12.radius,
        border: context.isDark
            ? null
            : Border.all(color: context.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CricketText(
                  text: row.name,
                  style: context.textTheme.titleSmall,
                ),
              ),
              _Badge(
                badgeKey: Key('squad_c_${row.name}'),
                label: TranslationKeys.captainShort.tr,
                semantics: '${TranslationKeys.captain.tr}, ${row.name}',
                selected: isCaptain,
                onTap: onCaptain,
              ),
              _Badge(
                badgeKey: Key('squad_vc_${row.name}'),
                label: TranslationKeys.viceCaptainShort.tr,
                semantics: '${TranslationKeys.viceCaptain.tr}, ${row.name}',
                selected: isViceCaptain,
                onTap: onViceCaptain,
              ),
              _Badge(
                badgeKey: Key('squad_wk_${row.name}'),
                label: TranslationKeys.wicketkeeperShort.tr,
                semantics: '${TranslationKeys.wicketkeeper.tr}, ${row.name}',
                selected: isKeeper,
                onTap: onKeeper,
              ),
              IconButton(
                key: Key('squad_remove_${row.name}'),
                tooltip: '${TranslationKeys.removePlayer.tr}, ${row.name}',
                icon: const Icon(Icons.close, size: 18),
                onPressed: onRemove,
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final role in squadRoles)
                ChoiceChip(
                  key: Key('squad_role_${row.name}_$role'),
                  label: Text(roleLabel(role)),
                  selected: row.role == role,
                  onSelected: (_) => onRole(role),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.badgeKey,
    required this.label,
    required this.semantics,
    required this.selected,
    required this.onTap,
  });

  final Key badgeKey;
  final String label;
  final String semantics;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Semantics(
      label: semantics,
      button: true,
      selected: selected,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        key: badgeKey,
        onTap: onTap,
        borderRadius: 20.radius,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? scheme.primary : Colors.transparent,
              borderRadius: 20.radius,
              border: Border.all(color: scheme.primary),
            ),
            child: Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: selected ? scheme.onPrimary : scheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
