import 'package:json_annotation/json_annotation.dart';

part 'create_tournament_req.g.dart';

@JsonSerializable()
class CreateTournamentReq {
  final String name;

  /// `knockout` | `round_robin` | `league`.
  final String format;

  CreateTournamentReq({required this.name, required this.format});

  factory CreateTournamentReq.fromJson(Map<String, dynamic> json) =>
      _$CreateTournamentReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTournamentReqToJson(this);
}
