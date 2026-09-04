/// Wire values for the update-profile contract's cricket-specific fields.
/// See `docs/api.md` → `POST /v1/user/update-profile`.
library;

/// Arm and pace/spin are deliberately not split into two fields — see
/// docs/api.md for why bowling style stops at four values rather than the
/// full professional taxonomy.
class BattingStyle {
  const BattingStyle._();

  static const String rightHanded = 'right_handed';
  static const String leftHanded = 'left_handed';

  static const List<String> all = <String>[rightHanded, leftHanded];
}

class BowlingStyle {
  const BowlingStyle._();

  static const String rightArmPace = 'right_arm_pace';
  static const String leftArmPace = 'left_arm_pace';
  static const String rightArmSpin = 'right_arm_spin';
  static const String leftArmSpin = 'left_arm_spin';

  static const List<String> all = <String>[
    rightArmPace,
    leftArmPace,
    rightArmSpin,
    leftArmSpin,
  ];
}
