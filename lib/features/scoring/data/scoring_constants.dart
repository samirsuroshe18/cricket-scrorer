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

/// The six dismissals in scope for v1. `obstructing` and `timed_out` are out;
/// retired hurt/out are excluded for a different reason — they happen between
/// balls and consume no delivery, so they cannot ride on a score-ball at all.
class WicketType {
  const WicketType._();

  static const String bowled = 'bowled';
  static const String caught = 'caught';
  static const String lbw = 'lbw';
  static const String runOut = 'run_out';
  static const String stumped = 'stumped';
  static const String hitWicket = 'hit_wicket';

  static const List<String> all = <String>[
    bowled,
    caught,
    lbw,
    runOut,
    stumped,
    hitWicket,
  ];

  /// Only a run out can dismiss the non-striker, and only a run out can carry
  /// runs. Every other type takes the striker off a ball worth nothing.
  static bool takesEitherBatsman(String type) => type == runOut;

  /// Mirrors the server's legality table in `docs/api.md`: off a no-ball only a
  /// run out is possible, off a wide only a stumping or a run out.
  ///
  /// This deliberately duplicates a server rule. It exists so the console can
  /// grey out impossible types instead of letting a scorer discover them as a
  /// 400 mid-over — the server stays authoritative, this only gates the UI.
  /// If the server's table changes, change this with it.
  static List<String> allowedFor(String? extraType) {
    switch (extraType) {
      case ExtraType.noBall:
        return const <String>[runOut];
      case ExtraType.wide:
        return const <String>[stumped, runOut];
      default:
        return all;
    }
  }
}

/// Which end the dismissed batsman was at, as of *before* the delivery.
class DismissedBatsman {
  const DismissedBatsman._();

  static const String striker = 'striker';
  static const String nonStriker = 'non_striker';
}
