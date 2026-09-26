import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The four settable `Player.role` wire values, with their labels.
const Map<String, String> _rosterRoles = <String, String>{
  'batsman': TranslationKeys.roleBatsman,
  'bowler': TranslationKeys.roleBowler,
  'allrounder': TranslationKeys.roleAllrounder,
  'wicketkeeper': TranslationKeys.roleWicketkeeper,
};

/// Role chips for the roster sheets. Tapping the selected chip clears it —
/// `null` means "no role chosen", which the add sheet omits from the request
/// and the edit sheet reads as "leave unchanged".
class RosterRolePicker extends StatelessWidget {
  const RosterRolePicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final MapEntry(key: role, value: labelKey) in _rosterRoles.entries)
          ChoiceChip(
            label: CricketText(text: labelKey.tr),
            selected: selected == role,
            onSelected: (isSelected) => onChanged(isSelected ? role : null),
          ),
      ],
    );
  }
}

/// Parses the optional jersey-number field: blank is `null` (not provided),
/// an in-range integer is the number, anything else is invalid.
({bool valid, int? value}) parseJerseyNumber(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return (valid: true, value: null);
  final number = int.tryParse(trimmed);
  if (number == null || number < 0 || number > 999) {
    return (valid: false, value: null);
  }
  return (valid: true, value: number);
}
