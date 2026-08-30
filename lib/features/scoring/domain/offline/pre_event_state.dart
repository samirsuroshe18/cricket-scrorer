/// The innings/over counters immediately before one delivery, threaded
/// through [resolveOver]/[resolveStrikePreview] the same way the server's own
/// `preEventState` snapshot drives `resolveBallOutcome`/`resolveStrike`.
///
/// Name-keyed rather than id-keyed, deliberately: unlike the server, the
/// client has no reliable local player-id concept for a name typed offline
/// (ids are assigned server-side, on sync), and this struct exists purely to
/// preview a score for display — matching by trimmed, case-insensitive name
/// is the right amount of precision for that, not a shortcut taken for lack
/// of a better option.
class ExtrasSnapshot {
  final int wides;
  final int noBalls;
  final int byes;
  final int legByes;

  const ExtrasSnapshot({
    this.wides = 0,
    this.noBalls = 0,
    this.byes = 0,
    this.legByes = 0,
  });

  ExtrasSnapshot plus(ExtrasSnapshot buckets) => ExtrasSnapshot(
    wides: wides + buckets.wides,
    noBalls: noBalls + buckets.noBalls,
    byes: byes + buckets.byes,
    legByes: legByes + buckets.legByes,
  );

  int get total => wides + noBalls + byes + legByes;

  Map<String, dynamic> toJson() => {
    'wides': wides,
    'noBalls': noBalls,
    'byes': byes,
    'legByes': legByes,
  };

  factory ExtrasSnapshot.fromJson(Map<String, dynamic> json) => ExtrasSnapshot(
    wides: json['wides'] as int? ?? 0,
    noBalls: json['noBalls'] as int? ?? 0,
    byes: json['byes'] as int? ?? 0,
    legByes: json['legByes'] as int? ?? 0,
  );
}

/// One batsman's own runs and legal balls faced, carried alongside their name
/// so [resolveStrikePreview] can rotate/substitute the figures in lockstep
/// with the pair itself — mirroring the server's `liveStrikeFigures` update
/// rule (`runs` credited regardless of legality, `balls` only on a legal
/// delivery), just applied incrementally instead of re-aggregated from full
/// ball history.
class BatsmanFigures {
  final String? name;
  final int runs;
  final int balls;

  const BatsmanFigures({this.name, this.runs = 0, this.balls = 0});

  Map<String, dynamic> toJson() => {'name': name, 'runs': runs, 'balls': balls};

  factory BatsmanFigures.fromJson(Map<String, dynamic> json) => BatsmanFigures(
    name: json['name'] as String?,
    runs: json['runs'] as int? ?? 0,
    balls: json['balls'] as int? ?? 0,
  );
}

class PreEventState {
  final int totalRuns;
  final int wickets;
  final int legalBalls;
  final int totalBalls;
  final int oversCompleted;
  final BatsmanFigures striker;
  final BatsmanFigures nonStriker;
  final String? currentBowlerName;
  final int overTotalRuns;
  final int overLegalDeliveries;
  final ExtrasSnapshot extrasSnapshot;
  final ExtrasSnapshot overExtrasSnapshot;

  const PreEventState({
    required this.totalRuns,
    required this.wickets,
    required this.legalBalls,
    required this.totalBalls,
    required this.oversCompleted,
    this.striker = const BatsmanFigures(),
    this.nonStriker = const BatsmanFigures(),
    this.currentBowlerName,
    required this.overTotalRuns,
    required this.overLegalDeliveries,
    this.extrasSnapshot = const ExtrasSnapshot(),
    this.overExtrasSnapshot = const ExtrasSnapshot(),
  });

  Map<String, dynamic> toJson() => {
    'totalRuns': totalRuns,
    'wickets': wickets,
    'legalBalls': legalBalls,
    'totalBalls': totalBalls,
    'oversCompleted': oversCompleted,
    'striker': striker.toJson(),
    'nonStriker': nonStriker.toJson(),
    'currentBowlerName': currentBowlerName,
    'overTotalRuns': overTotalRuns,
    'overLegalDeliveries': overLegalDeliveries,
    'extrasSnapshot': extrasSnapshot.toJson(),
    'overExtrasSnapshot': overExtrasSnapshot.toJson(),
  };

  factory PreEventState.fromJson(Map<String, dynamic> json) => PreEventState(
    totalRuns: json['totalRuns'] as int,
    wickets: json['wickets'] as int,
    legalBalls: json['legalBalls'] as int,
    totalBalls: json['totalBalls'] as int,
    oversCompleted: json['oversCompleted'] as int,
    striker: BatsmanFigures.fromJson(
      json['striker'] as Map<String, dynamic>? ?? const {},
    ),
    nonStriker: BatsmanFigures.fromJson(
      json['nonStriker'] as Map<String, dynamic>? ?? const {},
    ),
    currentBowlerName: json['currentBowlerName'] as String?,
    overTotalRuns: json['overTotalRuns'] as int,
    overLegalDeliveries: json['overLegalDeliveries'] as int,
    extrasSnapshot: ExtrasSnapshot.fromJson(
      json['extrasSnapshot'] as Map<String, dynamic>? ?? const {},
    ),
    overExtrasSnapshot: ExtrasSnapshot.fromJson(
      json['overExtrasSnapshot'] as Map<String, dynamic>? ?? const {},
    ),
  );
}
