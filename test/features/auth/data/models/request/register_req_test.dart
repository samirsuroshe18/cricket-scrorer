import 'package:cricket_scorer/features/auth/data/models/request/register_req.dart';
import 'package:flutter_test/flutter_test.dart';

// userName/fcmToken/rememberMe used to be declared here, matching nothing on
// the backend: registerUser reads only fullName/email/password from the
// request body. No call site ever populated them, so this was latent drift
// rather than a live bug — but a future screen populating userName expecting
// it to land server-side would have been silently ignored. This pins the
// request body to exactly what the backend reads.
void main() {
  test('toJson sends only the fields registerUser actually reads', () {
    final req = RegisterReq(
      email: 'scorer@example.com',
      fullName: 'Scorer One',
      password: 'password123',
    );

    expect(req.toJson().keys.toSet(), {'email', 'fullName', 'password'});
  });
}
