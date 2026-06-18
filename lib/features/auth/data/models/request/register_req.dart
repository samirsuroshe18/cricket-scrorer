import 'package:json_annotation/json_annotation.dart';

part 'register_req.g.dart';

@JsonSerializable()
class RegisterReq {
  final String email;
  final String? userName;
  final String? fullName;
  final String password;
  final String? fcmToken;
  final bool rememberMe;

  RegisterReq({
    required this.email,
    this.userName,
    this.fullName,
    required this.password,
    this.rememberMe = false,
    this.fcmToken,
  });

  factory RegisterReq.fromJson(Map<String, dynamic> json) =>
      _$RegisterReqFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterReqToJson(this);
}
