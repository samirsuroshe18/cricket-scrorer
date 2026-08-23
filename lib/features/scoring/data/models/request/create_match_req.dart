import 'package:json_annotation/json_annotation.dart';

part 'create_match_req.g.dart';

@JsonSerializable()
class CreateMatchReq {
  final String teamAName;
  final String teamBName;
  final int totalOvers;

  CreateMatchReq({
    required this.teamAName,
    required this.teamBName,
    required this.totalOvers,
  });

  factory CreateMatchReq.fromJson(Map<String, dynamic> json) =>
      _$CreateMatchReqFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMatchReqToJson(this);
}
