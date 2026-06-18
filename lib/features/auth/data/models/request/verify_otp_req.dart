import 'package:json_annotation/json_annotation.dart';

part 'verify_otp_req.g.dart';

@JsonSerializable()
class VerifyOtpReq {
  final String email;
  final String? emailOtp;
  final String type;

  VerifyOtpReq({
    required this.email,
    this.emailOtp,
    required this.type,
  });

  factory VerifyOtpReq.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpReqFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpReqToJson(this);
}
