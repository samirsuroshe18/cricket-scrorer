import 'package:json_annotation/json_annotation.dart';

part 'register_req.g.dart';

// userName/fcmToken/rememberMe used to be declared here, matching nothing on
// the backend: registerUser reads only fullName/email/password from the
// request body. No call site ever populated them (register_controller.dart
// is the only one), so this was latent drift rather than a live bug — but a
// future screen populating userName expecting it to land server-side would
// have been silently ignored. Registration doesn't collect a username at
// all yet; add the field back here (and to registerUser) together, in the
// same change, if that ever changes.
@JsonSerializable()
class RegisterReq {
  final String email;
  final String? fullName;
  final String password;

  RegisterReq({
    required this.email,
    this.fullName,
    required this.password,
  });

  factory RegisterReq.fromJson(Map<String, dynamic> json) =>
      _$RegisterReqFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterReqToJson(this);
}
