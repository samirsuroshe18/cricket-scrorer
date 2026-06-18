class AuthEndpoint {
  const AuthEndpoint();

  final String login = '/v1/user/login';
  final String register = '/v1/user/register';
  final String getUser = '/v1/user/get-current-user';
  final String forgotPassword = '/v1/user/forgot-password';
  final String verifyOtp = '/v1/user/verify-otp';
  final String resendOtp = '/v1/user/resend-otp';
  final String setPass = '/v1/user/set-password';
  final String updateProfile = '/v1/user/update-profile';
  final String logout = '/v1/user/logout';
}
