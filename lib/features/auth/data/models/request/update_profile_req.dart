import 'package:json_annotation/json_annotation.dart';

part 'update_profile_req.g.dart';

@JsonSerializable()
class UpdateProfileReq {
  final String userName;
  final String? bio;

  UpdateProfileReq({
    required this.userName,
    this.bio,
  });

  factory UpdateProfileReq.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileReqFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileReqToJson(this);
}
