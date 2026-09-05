// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

User userFromJson(String str) =>
    User.fromJson(json.decode(str) as Map<String, dynamic>);

String userToJson(User data) => json.encode(data.toJson());

@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'isEmailVerified')
  final bool? isEmailVerified;
  @JsonKey(name: 'fullName')
  final String? fullName;
  @JsonKey(name: 'userName')
  final String? userName;
  @JsonKey(name: 'photoUrl')
  final String? photoUrl;
  @JsonKey(name: 'bio')
  final String? bio;
  @JsonKey(name: 'battingStyle')
  final String? battingStyle;
  @JsonKey(name: 'bowlingStyle')
  final String? bowlingStyle;
  @JsonKey(name: 'profileCompleted')
  final bool? profileCompleted;
  @JsonKey(name: 'accountStatus')
  final String? accountStatus;
  final String? language;
  @JsonKey(name: 'isDeleted')
  final bool? isDeleted;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;
  @JsonKey(name: 'lastLoginAt')
  final DateTime? lastLoginAt;

  User({
    this.id,
    this.email,
    this.isEmailVerified,
    this.fullName,
    this.userName,
    this.photoUrl,
    this.bio,
    this.battingStyle,
    this.bowlingStyle,
    this.profileCompleted,
    this.accountStatus,
    this.language,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  User copyWith({
    String? id,
    String? email,
    bool? isEmailVerified,
    String? fullName,
    String? userName,
    String? photoUrl,
    String? bio,
    String? battingStyle,
    String? bowlingStyle,
    bool? profileCompleted,
    String? accountStatus,
    String? language,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    fullName: fullName ?? this.fullName,
    userName: userName ?? this.userName,
    photoUrl: photoUrl ?? this.photoUrl,
    bio: bio ?? this.bio,
    battingStyle: battingStyle ?? this.battingStyle,
    bowlingStyle: bowlingStyle ?? this.bowlingStyle,
    profileCompleted: profileCompleted ?? this.profileCompleted,
    accountStatus: accountStatus ?? this.accountStatus,
    language: language ?? this.language,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
