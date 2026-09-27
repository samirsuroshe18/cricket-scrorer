import 'package:json_annotation/json_annotation.dart';

part 'looked_up_user_res.g.dart';

/// `data` of `GET /v1/user/lookup`: exactly what a scorer needs to confirm
/// they found the right person — no email, phone or stats.
@JsonSerializable()
class LookedUpUserRes {
  final String userId;
  final String fullName;
  final String? userName;
  final String? photoUrl;

  LookedUpUserRes({
    required this.userId,
    required this.fullName,
    this.userName,
    this.photoUrl,
  });

  factory LookedUpUserRes.fromJson(Map<String, dynamic> json) =>
      _$LookedUpUserResFromJson(json);

  Map<String, dynamic> toJson() => _$LookedUpUserResToJson(this);
}
