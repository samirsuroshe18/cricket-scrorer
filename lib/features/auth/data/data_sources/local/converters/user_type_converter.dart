import 'package:cricket_scorer/core/enums/user_type.dart';
import 'package:floor/floor.dart';

class UserTypeConverter extends TypeConverter<UserType, String> {
  @override
  UserType decode(String databaseValue) {
    return UserType.values.firstWhere((e) => e.name == databaseValue);
  }

  @override
  String encode(UserType value) {
    return value.name;
  }
}
