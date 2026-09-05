import 'package:json_annotation/json_annotation.dart';

part 'update_profile_req.g.dart';

@JsonSerializable()
class UpdateProfileReq {
  final String userName;
  final String? bio;

  // Start unselected, unlike bio/userName which always carry a String from
  // their TextEditingController — includeIfNull keeps toJson() from putting
  // a literal null into the map FormData.fromMap builds when neither is set.
  @JsonKey(includeIfNull: false)
  final String? battingStyle;
  @JsonKey(includeIfNull: false)
  final String? bowlingStyle;

  UpdateProfileReq({
    required this.userName,
    this.bio,
    this.battingStyle,
    this.bowlingStyle,
  });

  factory UpdateProfileReq.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileReqFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileReqToJson(this);
}
