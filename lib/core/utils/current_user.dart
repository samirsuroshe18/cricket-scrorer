import 'dart:convert';

import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';

/// The signed-in user's id, read synchronously from the same cache
/// `language_service.dart`'s own sync already relies on: the stored value
/// is a `LoggedInUser`'s JSON (written by `login_controller.dart`), decoded
/// here via `User.fromJson` — both map their id from the same `_id` JSON
/// key, so the cross-decode is exactly what that existing call site already
/// depends on working. Synchronous because a `Bindings.dependencies()`
/// override, one of this function's callers, cannot await a network call
/// before returning.
String currentUserId() {
  final userJson =
      SharedPreferenceService.sharedPrefService.get(SharedPrefKey.userDetails)
          as String?;
  if (userJson == null) return '';
  final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  return user.id ?? '';
}
