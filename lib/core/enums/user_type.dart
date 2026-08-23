import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'type')
enum UserType {
  player('player'),
  organization('organization');

  final String type;

  const UserType(this.type);
}
