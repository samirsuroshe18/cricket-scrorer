import 'package:json_annotation/json_annotation.dart';

part 'forgot_pass_req.g.dart';

@JsonSerializable()
class ForgotPassReq {
  final String email;

  ForgotPassReq({
    required this.email,
  });

  factory ForgotPassReq.fromJson(Map<String, dynamic> json) =>
      _$ForgotPassReqFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPassReqToJson(this);
}
