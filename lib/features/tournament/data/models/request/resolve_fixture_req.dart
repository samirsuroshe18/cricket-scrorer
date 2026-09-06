import 'package:json_annotation/json_annotation.dart';

part 'resolve_fixture_req.g.dart';

@JsonSerializable()
class ResolveFixtureReq {
  final String winner;

  ResolveFixtureReq({required this.winner});

  factory ResolveFixtureReq.fromJson(Map<String, dynamic> json) =>
      _$ResolveFixtureReqFromJson(json);

  Map<String, dynamic> toJson() => _$ResolveFixtureReqToJson(this);
}
