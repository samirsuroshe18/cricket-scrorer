import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';

/// Client-side mirror of the backend's `resolveStrike.js`. See
/// `resolve_delivery.dart` for why this is a port rather than a
/// reimplementation.
///
/// Matched by (trimmed, case-insensitive) name rather than id — see
/// `pre_event_state.dart` for why. With no dismissal this is a plain swap;
/// order is load-bearing on a wicket: [dismissedName] names a batsman as of
/// *before* the ball, and rotation may have moved them, so the substitution
/// below matches on the player rather than on an end — the run-out case this
/// exists for. Runs/balls travel WITH the pair being rotated/substituted, not
/// separately, so a batsman's own figures can never end up attached to the
/// wrong name.
class StrikePreview {
  final BatsmanFigures striker;
  final BatsmanFigures nonStriker;

  const StrikePreview({required this.striker, required this.nonStriker});
}

bool _sameName(String? a, String? b) =>
    a != null &&
    b != null &&
    a.trim().toLowerCase() == b.trim().toLowerCase();

StrikePreview resolveStrikePreview({
  required BatsmanFigures striker,
  required BatsmanFigures nonStriker,
  bool rotated = false,
  String? dismissedName,
  String? incomingName,
}) {
  final pair = rotated
      ? StrikePreview(striker: nonStriker, nonStriker: striker)
      : StrikePreview(striker: striker, nonStriker: nonStriker);

  if (dismissedName == null) return pair;

  // The incoming batsman starts at (0, 0) — nothing offline can know
  // otherwise, and nor could the server before this ball was ever scored.
  final incoming = BatsmanFigures(name: incomingName);

  if (_sameName(pair.striker.name, dismissedName)) {
    return StrikePreview(striker: incoming, nonStriker: pair.nonStriker);
  }

  if (_sameName(pair.nonStriker.name, dismissedName)) {
    return StrikePreview(striker: pair.striker, nonStriker: incoming);
  }

  // Dismissed name matches neither — a bug upstream (a preview built off a
  // stale pair). Leave the pair untouched rather than evicting the wrong
  // batsman; the next real ack corrects it regardless.
  return pair;
}
