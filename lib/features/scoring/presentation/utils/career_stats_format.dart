import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';

/// `null` (never dismissed) renders as "-", not "0.00" — a stored `null`
/// already carries this same distinction server-side; this is display only,
/// not a re-derivation of the average itself.
String formatAverage(double? average) {
  if (average == null) return '-';
  return average.toStringAsFixed(2);
}

/// Cricket convention: "87*" for a not-out score. `null` (no innings batted
/// yet) renders as "-".
String formatHighScore(HighScore? highScore) {
  if (highScore == null) return '-';
  return '${highScore.runs}${highScore.isNotOut ? '*' : ''}';
}

/// Cricket convention: "3/24" (wickets/runs). `null` (no innings bowled yet)
/// renders as "-".
String formatBestBowling(BestBowling? bestBowling) {
  if (bestBowling == null) return '-';
  return '${bestBowling.wickets}/${bestBowling.runs}';
}

/// "4.2" format from a raw legal-delivery count — the inverse of the
/// server's own `formatOvers`, applied client-side since `CareerStats`
/// stores `legalDeliveries` as a plain int, not a pre-formatted string.
String formatOversFromLegalDeliveries(int legalDeliveries) {
  final wholeOvers = legalDeliveries ~/ 6;
  final remainder = legalDeliveries % 6;
  return '$wholeOvers.$remainder';
}
