import 'package:json_annotation/json_annotation.dart';

part 'bowler.g.dart';

/// A named bowler, exactly as the server reported him. Carried by
/// `start-innings` (the opening bowler) and by `select-bowler` (the bowler for
/// the over about to start, plus the previous one).
///
/// Bowler *figures* — overs, maidens, runs conceded, wickets — are not in this
/// model because the server does not compute them yet. See `docs/api.md`.
@JsonSerializable()
class Bowler {
  final String? bowlerId;
  final String? bowlerName;

  Bowler({this.bowlerId, this.bowlerName});

  factory Bowler.fromJson(Map<String, dynamic> json) => _$BowlerFromJson(json);

  Map<String, dynamic> toJson() => _$BowlerToJson(this);
}
