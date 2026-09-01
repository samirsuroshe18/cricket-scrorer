import 'package:cricket_scorer/features/scoring/domain/offline/pre_event_state.dart';

/// Client-side mirror of the backend's `resolveStrike.js`. See
/// `resolve_delivery.dart` for why this is a port rather than a
/// reimplementation.
///
/// Substitution on a wicket is positional, not name-based: [dismissedWasStriker]
/// names a *slot* (striker or non-striker) as of *before* the ball, and
/// rotation may have swapped which slot that person now occupies — XORing
/// against [rotated] follows them there without ever needing to recognise
/// them by name. This used to match on `BatsmanFigures.name` instead (see
/// `pre_event_state.dart`'s doc comment on why names are all this struct
/// has), which broke down for two identically- or near-identically-named
/// players at the crease — a common local-lineup collision (two "Ali"s) —
/// since a dismissed "Ali" could evict the *other* Ali's figures instead of
/// their own. Positional matching can't make that mistake: there are only
/// ever two slots, and this ball's own `dismissedBatsman` selection already
/// says unambiguously which one was out, independent of what either player
/// is named.
class StrikePreview {
  final BatsmanFigures striker;
  final BatsmanFigures nonStriker;

  const StrikePreview({required this.striker, required this.nonStriker});
}

StrikePreview resolveStrikePreview({
  required BatsmanFigures striker,
  required BatsmanFigures nonStriker,
  bool rotated = false,
  bool isWicket = false,
  bool dismissedWasStriker = false,
  String? incomingName,
}) {
  final pair = rotated
      ? StrikePreview(striker: nonStriker, nonStriker: striker)
      : StrikePreview(striker: striker, nonStriker: nonStriker);

  if (!isWicket) return pair;

  // The incoming batsman starts at (0, 0) — nothing offline can know
  // otherwise, and nor could the server before this ball was ever scored.
  final incoming = BatsmanFigures(name: incomingName);

  // Whichever slot held the dismissed batsman before this ball holds them
  // after rotation too, unless rotation swapped the pair — the two cancel
  // out via XOR rather than a second round of name matching.
  final dismissedIsNowStriker = dismissedWasStriker != rotated;

  return dismissedIsNowStriker
      ? StrikePreview(striker: incoming, nonStriker: pair.nonStriker)
      : StrikePreview(striker: pair.striker, nonStriker: incoming);
}
