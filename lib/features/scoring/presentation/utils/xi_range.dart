/// Where a side's Playing XI count sits against the match's configured
/// `minPlayingXi`/`maxPlayingXi`. Shared by `SquadController` (to gate Skip
/// and Save & continue) and `SquadScreen` (to show the same status as a tab
/// badge and a caption), so the two can never disagree about what counts as
/// valid.
enum XiRangeStatus {
  /// The match carries no min/max (for example one reopened from history
  /// before this range existed) — nothing to compare against, so the
  /// server-side save stays the backstop.
  hidden,

  /// Nothing chosen yet — a valid, deliberate "leave it unset" state; Skip
  /// and Save & continue both already treat an empty XI as a real choice.
  empty,

  /// Fewer than the minimum — not yet a usable Playing XI.
  belowMin,

  /// Anywhere from the minimum up to the maximum — done. Reaching the
  /// maximum is never required, only reaching the minimum.
  ready,

  /// More than the maximum — needs trimming back down.
  aboveMax,
}

/// A count classified against a match's Playing XI range. [min]/[max] are 0
/// when the match carries neither — read [status] first.
class XiRange {
  final XiRangeStatus status;
  final int count;
  final int min;
  final int max;

  const XiRange._(this.status, this.count, this.min, this.max);

  factory XiRange.of(int count, int? min, int? max) {
    if (min == null || max == null) {
      return XiRange._(XiRangeStatus.hidden, count, 0, 0);
    }
    if (count == 0) return XiRange._(XiRangeStatus.empty, count, min, max);
    if (count < min) return XiRange._(XiRangeStatus.belowMin, count, min, max);
    if (count > max) return XiRange._(XiRangeStatus.aboveMax, count, min, max);
    return XiRange._(XiRangeStatus.ready, count, min, max);
  }

  /// How many more are needed to reach [min]. Only meaningful when
  /// [status] is [XiRangeStatus.belowMin].
  int get short => min - count;

  /// How many too many over [max]. Only meaningful when [status] is
  /// [XiRangeStatus.aboveMax].
  int get over => count - max;

  /// True when this status should block Skip / Save & continue: some
  /// players are chosen, but not enough — or too many — for a valid
  /// Playing XI. A fully empty XI never blocks; that is the existing
  /// "leave it unset" path both buttons already support.
  bool get blocksLeaving =>
      status == XiRangeStatus.belowMin || status == XiRangeStatus.aboveMax;
}
