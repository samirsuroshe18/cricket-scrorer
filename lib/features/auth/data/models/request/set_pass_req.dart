import 'package:json_annotation/json_annotation.dart';

part 'set_pass_req.g.dart';

@JsonSerializable()
class SetPassReq {
  final String email;
  final String newPassword;
  final String confirmPassword;
  final String resetToken;

  SetPassReq({
    required this.email,
    required this.newPassword,
    required this.confirmPassword,
    required this.resetToken,
  });

  factory SetPassReq.fromJson(Map<String, dynamic> json) =>
      _$SetPassReqFromJson(json);

  Map<String, dynamic> toJson() => _$SetPassReqToJson(this);
}
