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
          ChoiceChip(
            label: CricketText(text: tournamentFormatLabel(format)),
            selected: selected == format,
            selectedColor: context.colors.chipSelected,
            backgroundColor: context.colors.chipBackground,
            onSelected: (_) => onSelected(format),
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
          ChoiceChip(
            label: CricketText(text: tournamentStatusLabel(status)),
            selected: selected == status,
            selectedColor: context.colors.chipSelected,
            backgroundColor: context.colors.chipBackground,
            onSelected: (_) => onSelected(status),
          ),
      ],
    );
  }
}
