import 'package:cricket_scorer/features/auth/data/models/login_response.dart';
import 'package:flutter_test/flutter_test.dart';

// The backend's loginUser response is user.toObject() minus a few explicitly
// stripped secret fields — language/userType/fcmToken ride along in every
// real response but were undeclared here, so json_serializable's generated
// fromJson silently dropped them on parse. Harmless today only because each
// has its own dedicated read path elsewhere (language: GET /user/language);
// declaring them is what lets a future screen use this response as a cache
// for any of the three instead of a fresh call.
void main() {
  test('parses language, userType, and fcmToken from a real login payload', () {
    final user = LoggedInUser.fromJson({
      '_id': 'user-1',
      'email': 'scorer@example.com',
      'isEmailVerified': true,
      'fullName': 'Scorer One',
      'language': 'hi',
      'userType': 'organization',
      'fcmToken': 'a-real-fcm-token',
    });

    expect(user.language, 'hi');
    expect(user.userType, 'organization');
    expect(user.fcmToken, 'a-real-fcm-token');
  });

  test('round-trips through toJson', () {
    final user = LoggedInUser(
      id: 'user-1',
      language: 'mr',
      userType: 'player',
      fcmToken: 'token-abc',
    );

    final json = user.toJson();

    expect(json['language'], 'mr');
    expect(json['userType'], 'player');
    expect(json['fcmToken'], 'token-abc');
  });
}
