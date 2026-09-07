import 'package:json_annotation/json_annotation.dart';

part 'update_pool_entry_req.g.dart';

/// `PATCH /v1/tournament/:tournamentId/pool/:playerId` — basePrice only,
/// always required (not a partial-update shape like UpdateTournamentReq).
@JsonSerializable()
class UpdatePoolEntryReq {
  final int basePrice;

  UpdatePoolEntryReq({required this.basePrice});

  factory UpdatePoolEntryReq.fromJson(Map<String, dynamic> json) =>
      _$UpdatePoolEntryReqFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePoolEntryReqToJson(this);
}
