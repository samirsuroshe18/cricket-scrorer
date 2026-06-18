import 'package:cricket_scorer/core/enums/user_type.dart';
import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_details.g.dart';

@Entity(tableName: 'userDetails')
@JsonSerializable()
class UserDetails {
  @primaryKey
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final String? profilePhotoUrl;
  final UserType? type;

  const UserDetails({
    this.id,
    this.name,
    this.profilePhotoUrl,
    this.type,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) =>
      _$UserDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailsToJson(this);

  UserDetails copyWith({
    String? id,
    String? name,
    String? profilePhotoUrl,
    UserType? type,
  }) {
    return UserDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}
