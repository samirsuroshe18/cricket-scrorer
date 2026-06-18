import 'package:json_annotation/json_annotation.dart';

part 'verify_otp_res.g.dart';

@JsonSerializable()
class VerifyOtpRes {
  final String? resetToken;

  VerifyOtpRes({required this.resetToken});

  factory VerifyOtpRes.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpResToJson(this);
}
