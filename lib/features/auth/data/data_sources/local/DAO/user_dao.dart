import 'package:cricket_scorer/features/auth/data/models/user_details.dart';
import 'package:floor/floor.dart';

@dao
abstract class UserDao {
  @Insert()
  Future<void> insertUserDetails(UserDetails userDetails);

  @Query('SELECT * FROM userDetails LIMIT 1')
  Future<UserDetails?> getUserDetails();
}