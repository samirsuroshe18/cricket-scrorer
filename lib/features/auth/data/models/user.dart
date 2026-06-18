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
  @JsonKey(name: 'lastLoginAt')
  final DateTime? lastLoginAt;

  User({
    this.id,
    this.email,
    this.isEmailVerified,
    this.userName,
    this.profileCompleted,
    this.accountStatus,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  User copyWith({
    String? id,
    String? email,
    bool? isEmailVerified,
    String? userName,
    bool? profileCompleted,
    String? accountStatus,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    userName: userName ?? this.userName,
    profileCompleted: profileCompleted ?? this.profileCompleted,
    accountStatus: accountStatus ?? this.accountStatus,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
