import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginModel {
  final String email;
  final String password;
  final String? fcmToken;
  final bool rememberMe;

  LoginModel({
    required this.email,
    required this.password,
    this.rememberMe = false,
    this.fcmToken,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}
