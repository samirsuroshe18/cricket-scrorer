import 'dart:async';

import 'package:cricket_scorer/core/enums/user_type.dart';
import 'package:cricket_scorer/features/auth/data/data_sources/local/DAO/user_dao.dart';
import 'package:cricket_scorer/features/auth/data/data_sources/local/converters/user_type_converter.dart';
import 'package:cricket_scorer/features/auth/data/models/user_details.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@TypeConverters([UserTypeConverter])
@Database(version: 1, entities: [UserDetails])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
}
