import 'package:json_annotation/json_annotation.dart';

part 'fixture_res.g.dart';

/// A fixture's `teamA`/`teamB` — null for `teamB` only on a bye fixture.
@JsonSerializable()
class FixtureTeamRef {
  final String id;
  final String name;
  final String? shortName;

  FixtureTeamRef({required this.id, required this.name, this.shortName});

  factory FixtureTeamRef.fromJson(Map<String, dynamic> json) =>
      _$FixtureTeamRefFromJson(json);

  Map<String, dynamic> toJson() => _$FixtureTeamRefToJson(this);
}

/// A resolved fixture's winner — lighter than [FixtureTeamRef] (no
/// `shortName`), matching what `docs/api.md` actually returns for `winner`.
@JsonSerializable()
class FixtureWinnerRef {
  final String id;
  final String name;

  FixtureWinnerRef({required this.id, required this.name});

  factory FixtureWinnerRef.fromJson(Map<String, dynamic> json) =>
      _$FixtureWinnerRefFromJson(json);

  Map<String, dynamic> toJson() => _$FixtureWinnerRefToJson(this);
}

/// One row of `GET .../fixtures`' or `POST .../fixtures`' `fixtures` array —
/// see `docs/api.md`'s Fixture section.
@JsonSerializable(explicitToJson: true)
class FixtureRes {
  final String id;
  final int round;
  final int order;
  final FixtureTeamRef teamA;

  /// Null only when [isBye] is true.
  final FixtureTeamRef? teamB;
  final bool isBye;

  /// `scheduled` | `bye` | `completed` | `unresolved`.
  final String status;

  /// Null until the fixture resolves.
  final FixtureWinnerRef? winner;

  /// Null until `POST .../fixtures/:fixtureId/start-match` creates the
  /// real match for this fixture.
  final String? matchId;

  FixtureRes({
    required this.id,
    required this.round,
    required this.order,
    required this.teamA,
    this.teamB,
    required this.isBye,
    required this.status,
    this.winner,
    this.matchId,
  });

  factory FixtureRes.fromJson(Map<String, dynamic> json) =>
      _$FixtureResFromJson(json);

  Map<String, dynamic> toJson() => _$FixtureResToJson(this);
}
