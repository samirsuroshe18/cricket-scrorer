import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<String> tournamentFormats = ['knockout', 'round_robin', 'league'];
const List<String> tournamentStatuses = ['upcoming', 'ongoing', 'completed'];

String tournamentFormatLabel(String format) => switch (format) {
  'knockout' => TranslationKeys.formatKnockout.tr,
  'round_robin' => TranslationKeys.formatRoundRobin.tr,
  'league' => TranslationKeys.formatLeague.tr,
  _ => format,
};

// 'upcoming'/'completed' reuse match history's own status labels
// (TranslationKeys.statusUpcoming/statusCompleted) — same English words,
// no reason for a second, tournament-specific pair. 'ongoing' is the one
// genuinely new value (match statuses use 'live', not 'ongoing').
String tournamentStatusLabel(String status) => switch (status) {
  'upcoming' => TranslationKeys.statusUpcoming.tr,
  'ongoing' => TranslationKeys.statusOngoing.tr,
  'completed' => TranslationKeys.statusCompleted.tr,
  _ => status,
};

/// The same three semantic-status colors `_RosterRow`'s role pill and
/// match-result badges already draw from — `ongoing` reuses `statusWarning`
/// (this app's "live" color everywhere else), not a fourth new color.
Color tournamentStatusColor(BuildContext context, String status) =>
    switch (status) {
      'upcoming' => context.colors.statusInfo,
      'ongoing' => context.colors.statusWarning,
      'completed' => context.colors.statusSuccess,
      _ => context.colorScheme.onSurfaceVariant,
    };

/// A single tappable pill, shared by [FormatChoiceChips] and
/// [StatusChoiceChips]. Deliberately not a Material `ChoiceChip` — this
/// app's own pills (the member/team role badges on `OrganizationDetailScreen`,
/// the status badge on `_TournamentRow`) are flat, borderless, alpha-tinted
/// containers with bold colored text, not the default outlined-with-checkmark
/// Material chip. Reusing that exact shape here keeps the picker looking
/// like it belongs to this app rather than a generic Material form control.
class _SelectablePill extends StatelessWidget {
  const _SelectablePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colorScheme.primary
        : context.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: 20.radius,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? context.colorScheme.primary.withValues(alpha: 0.12)
                : context.colors.chipBackground,
            borderRadius: 20.radius,
          ),
          child: CricketText(
            text: label,
            style: context.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of tappable format pills — used at both creation (no initial
/// selection required beyond the caller's own default) and in the edit
/// sheet (pre-selected to the tournament's current format).
class FormatChoiceChips extends StatelessWidget {
  const FormatChoiceChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final format in tournamentFormats)
          _SelectablePill(
            label: tournamentFormatLabel(format),
            selected: selected == format,
            onTap: () => onSelected(format),
          ),
      ],
    );
  }
}

/// Same shape as [FormatChoiceChips], for `status` — only ever shown in the
/// edit sheet, never at creation.
class StatusChoiceChips extends StatelessWidget {
  const StatusChoiceChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final status in tournamentStatuses)
          _SelectablePill(
            label: tournamentStatusLabel(status),
            selected: selected == status,
            onTap: () => onSelected(status),
          ),
      ],
    );
  }
}
