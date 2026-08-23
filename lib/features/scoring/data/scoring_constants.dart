/// Wire values for the score-ball contract. See `docs/api.md`.
///
/// [ExtraType] and [RunsFrom] are independent: [ExtraType] is the delivery
/// fault (penalty + must be re-bowled), [RunsFrom] is who the runs belong to.
/// A no-ball that also goes for byes sets both.
library;

class ExtraType {
  const ExtraType._();

  static const String wide = 'wide';
  static const String noBall = 'no_ball';
}

class RunsFrom {
  const RunsFrom._();

  static const String bat = 'bat';
  static const String bye = 'bye';
  static const String legBye = 'leg_bye';
}
