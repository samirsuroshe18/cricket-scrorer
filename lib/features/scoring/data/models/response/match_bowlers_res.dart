import 'package:json_annotation/json_annotation.dart';

part 'match_bowlers_res.g.dart';

/// `GET /v1/match/:matchId/bowlers` — the current innings' bowling side's
/// full roster, each with figures for this innings. Includes batters who
/// have never bowled, with zero figures — see docs/api.md.
@JsonSerializable(explicitToJson: true)
class MatchBowlersRes {
  final List<BowlerFigureRes> bowlers;

  MatchBowlersRes({required this.bowlers});

  factory MatchBowlersRes.fromJson(Map<String, dynamic> json) =>
      _$MatchBowlersResFromJson(json);

  Map<String, dynamic> toJson() => _$MatchBowlersResToJson(this);
}

@JsonSerializable()
class BowlerFigureRes {
  final String id;
  final String name;
  final int legalDeliveries;
  final int runsConceded;
  final int wickets;

  BowlerFigureRes({
    required this.id,
    required this.name,
    required this.legalDeliveries,
    required this.runsConceded,
    required this.wickets,
  });

  factory BowlerFigureRes.fromJson(Map<String, dynamic> json) =>
      _$BowlerFigureResFromJson(json);

  Map<String, dynamic> toJson() => _$BowlerFigureResToJson(this);
}
