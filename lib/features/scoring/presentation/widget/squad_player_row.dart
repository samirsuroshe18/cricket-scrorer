import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/domain/squad_rules.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One player of the squad being edited. Tapping the row toggles it between
/// the Playing XI and the Bench; a trailing menu holds the role and Remove.
/// Captain / vice-captain / keeper are shown as tags next to the name but set
/// from the leader-picker sheet above the list, not from this row. Stateless
/// — every change goes back out through a callback so `SquadController`
/// stays the single owner of the draft.
///
/// [compact] is for a match already under way, where only the XI move can be
/// saved: the row keeps its original layout with an explicit move button and
/// no menu, role or tags.
class SquadPlayerRow extends StatelessWidget {
  const SquadPlayerRow({
    super.key,
    required this.row,
    required this.isCaptain,
    required this.isViceCaptain,
    required this.isKeeper,
    required this.onRole,
    required this.onRemove,
    required this.inXi,
    required this.onMove,
    this.compact = false,
  });

  final SquadRow row;
  final bool isCaptain;
  final bool isViceCaptain;
  final bool isKeeper;
  final ValueChanged<String> onRole;
  final VoidCallback onRemove;

  /// Whether the player is in the Playing XI (else the Bench); decides which
  /// way tapping the row (or, in [compact] mode, the move button) sends them.
  final bool inXi;
  final VoidCallback onMove;
  final bool compact;

  static String roleLabel(String role) => switch (role) {
    'bowler' => TranslationKeys.roleBowler.tr,
    'allrounder' => TranslationKeys.roleAllrounder.tr,
    _ => TranslationKeys.roleBatsman.tr,
  };

  List<String> get _tags => [
    if (isCaptain) TranslationKeys.captainShort.tr,
    if (isViceCaptain) TranslationKeys.viceCaptainShort.tr,
    if (isKeeper) TranslationKeys.wicketkeeperShort.tr,
  ];

  String _semanticsLabel() {
    final parts = [
      row.name,
      if (row.role != null) roleLabel(row.role!),
      if (isCaptain) TranslationKeys.captain.tr,
      if (isViceCaptain) TranslationKeys.viceCaptain.tr,
      if (isKeeper) TranslationKeys.wicketkeeper.tr,
    ];
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    if (compact) return _compactRow(context);

    final roleText = row.role == null ? null : roleLabel(row.role!);

    return Container(
      key: Key('squad_row_${row.name}'),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: inXi ? context.colors.chipSelected : context.colorScheme.surface,
        borderRadius: 12.radius,
        border: context.isDark
            ? null
            : Border.all(color: context.colorScheme.outline),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: 12.radius,
        child: InkWell(
          key: Key(
            inXi ? 'squad_toBench_${row.name}' : 'squad_toXi_${row.name}',
          ),
          borderRadius: 12.radius,
          onTap: onMove,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                // Semantics scoped to the move affordance only, so the
                // trailing menu below keeps its own accessible entry point
                // instead of being swallowed by excludeSemantics.
                Expanded(
                  child: Semantics(
                    label: _semanticsLabel(),
                    selected: inXi,
                    button: true,
                    excludeSemantics: true,
                    child: Row(
                      children: [
                        _avatar(context),
                        12.w,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                children: [
                                  CricketText(
                                    text: row.name,
                                    style: context.textTheme.titleSmall,
                                  ),
                                  for (final tag in _tags)
                                    _tagChip(context, tag),
                                ],
                              ),
                              if (roleText != null)
                                CricketText(
                                  text: roleText,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _menu(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    final initials = row.name.isEmpty ? '?' : row.name[0].toUpperCase();
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: inXi
                ? context.colors.chipSelected
                : context.colors.chipBackground,
            foregroundColor: inXi
                ? context.colorScheme.onSurface
                : context.colorScheme.onSurfaceVariant,
            child: CricketText(
              text: initials,
              style: context.textTheme.titleSmall?.copyWith(
                color: inXi
                    ? context.colorScheme.onSurface
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (inXi)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.surface,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: context.colors.statusSuccess,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tagChip(BuildContext context, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: context.colorScheme.primary,
      borderRadius: 9.radius,
    ),
    child: CricketText(
      text: label,
      style: context.textTheme.labelSmall?.copyWith(
        color: context.colorScheme.onPrimary,
      ),
    ),
  );

  Widget _menu(BuildContext context) => PopupMenuButton<String>(
    key: Key('squad_menu_${row.name}'),
    tooltip: TranslationKeys.squadPlayerOptions.tr,
    icon: const Icon(Icons.more_vert),
    onSelected: (value) => value == 'remove' ? onRemove() : onRole(value),
    itemBuilder: (context) => [
      PopupMenuItem<String>(
        enabled: false,
        height: 32,
        child: CricketText(
          text: TranslationKeys.squadSetRole.tr,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      for (final role in squadRoles)
        CheckedPopupMenuItem<String>(
          key: Key('squad_role_${row.name}_$role'),
          value: role,
          checked: row.role == role,
          child: Text(roleLabel(role)),
        ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        key: Key('squad_remove_${row.name}'),
        value: 'remove',
        child: Text(TranslationKeys.removePlayer.tr),
      ),
    ],
  );

  Widget _compactRow(BuildContext context) {
    final moveButton = TextButton.icon(
      key: Key(inXi ? 'squad_toBench_${row.name}' : 'squad_toXi_${row.name}'),
      onPressed: onMove,
      icon: Icon(inXi ? Icons.arrow_downward : Icons.arrow_upward, size: 16),
      label: Text(
        (inXi ? TranslationKeys.moveToBench : TranslationKeys.moveToXi).tr,
      ),
    );

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
      child: Row(
        children: [
          Expanded(
            child: CricketText(
              text: row.name,
              style: context.textTheme.titleSmall,
            ),
          ),
          moveButton,
        ],
      ),
    );
  }
}
