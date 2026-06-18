import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'type')
enum UserType {
  standardUser('standardUser'),
  institutionUser('institutionUser');

  final String type;

  const UserType(this.type);
}