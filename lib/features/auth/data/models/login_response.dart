// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'loggedInUser')
  final LoggedInUser? loggedInUser;
  @JsonKey(name: 'accessToken')
  final String? accessToken;
  @JsonKey(name: 'refreshToken')
  final String? refreshToken;

  LoginResponse({
    this.loggedInUser,
    this.accessToken,
    this.refreshToken,
  });

  LoginResponse copyWith({
    LoggedInUser? loggedInUser,
    String? accessToken,
    String? refreshToken,
  }) => LoginResponse(
    loggedInUser: loggedInUser ?? this.loggedInUser,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
  );

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class LoggedInUser {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'isEmailVerified')
  final bool? isEmailVerified;
  @JsonKey(name: 'userName')
  final String? userName;
  @JsonKey(name: 'profileCompleted')
  final bool? profileCompleted;
  @JsonKey(name: 'accountStatus')
  final String? accountStatus;
  @JsonKey(name: 'isDeleted')
  final bool? isDeleted;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;
  @JsonKey(name: '__v')
  final int? v;
  @JsonKey(name: 'lastLoginAt')
  final DateTime? lastLoginAt;
  @JsonKey(name: 'passwordChangedAt')
  final DateTime? passwordChangedAt;
  @JsonKey(name: 'bio')
  final String? bio;
  @JsonKey(name: 'fullName')
  final String? fullName;
  @JsonKey(name: 'photoUrl')
  final String? photoUrl;
  // Sent by the backend's loginUser (user.toObject() minus the explicitly
  // stripped secret fields) but previously undeclared here, so they were
  // silently dropped on parse — harmless today only because each has its
  // own dedicated endpoint (language: GET /user/language) or isn't read
  // back from this response anywhere yet (userType, fcmToken). Declaring
  // them is what would let a future screen use this response as a cache for
  // any of the three instead of a fresh call.
  @JsonKey(name: 'language')
  final String? language;
  @JsonKey(name: 'userType')
  final String? userType;
  @JsonKey(name: 'fcmToken')
  final String? fcmToken;

  LoggedInUser({
    this.id,
    this.email,
    this.isEmailVerified,
    this.userName,
    this.profileCompleted,
    this.accountStatus,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.lastLoginAt,
    this.passwordChangedAt,
    this.bio,
    this.fullName,
    this.photoUrl,
    this.language,
    this.userType,
    this.fcmToken,
  });

  LoggedInUser copyWith({
    String? id,
    String? email,
    bool? isEmailVerified,
    String? userName,
    bool? profileCompleted,
    String? accountStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    DateTime? lastLoginAt,
    DateTime? passwordChangedAt,
    String? bio,
    String? fullName,
    String? photoUrl,
    String? language,
    String? userType,
    String? fcmToken,
  }) => LoggedInUser(
    id: id ?? this.id,
    email: email ?? this.email,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    userName: userName ?? this.userName,
    profileCompleted: profileCompleted ?? this.profileCompleted,
    accountStatus: accountStatus ?? this.accountStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    v: v ?? this.v,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
    bio: bio ?? this.bio,
    fullName: fullName ?? this.fullName,
    photoUrl: photoUrl ?? this.photoUrl,
    language: language ?? this.language,
    userType: userType ?? this.userType,
    fcmToken: fcmToken ?? this.fcmToken,
  );

  factory LoggedInUser.fromJson(Map<String, dynamic> json) =>
      _$LoggedInUserFromJson(json);

  Map<String, dynamic> toJson() => _$LoggedInUserToJson(this);
}
