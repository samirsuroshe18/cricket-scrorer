import 'package:json_annotation/json_annotation.dart';

part 'register_pool_player_req.g.dart';

/// `POST /v1/tournament/:tournamentId/pool` — `playerId` optional, mirroring
/// `SelectBowlerReq`'s `bowlerName`/optional `bowlerId` pair: given, it must
/// already be owned by the caller; omitted, `playerName` find-or-creates
/// under the caller's own scorer scope.
@JsonSerializable()
class RegisterPoolPlayerReq {
  final String? playerName;
  final String? playerId;
  final int basePrice;

  RegisterPoolPlayerReq({this.playerName, this.playerId, required this.basePrice});

  factory RegisterPoolPlayerReq.fromJson(Map<String, dynamic> json) =>
      _$RegisterPoolPlayerReqFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterPoolPlayerReqToJson(this);
}
