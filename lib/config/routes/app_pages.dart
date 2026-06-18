import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/features/auth/presentation/bindings/forgot_password_binding.dart';
import 'package:cricket_scorer/features/auth/presentation/bindings/login_binding.dart';
import 'package:cricket_scorer/features/auth/presentation/bindings/onboarding_binding.dart';
import 'package:cricket_scorer/features/auth/presentation/bindings/otp_verification_binding.dart';
import 'package:cricket_scorer/features/auth/presentation/bindings/register_binding.dart';
import 'package:cricket_scorer/features/auth/presentation/bindings/set_password_binding.dart';
import 'package:cricket_scorer/features/auth/presentation/bindings/splash_binding.dart';
import 'package:cricket_scorer/features/auth/presentation/bindings/update_profile_binding.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/login_screen.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/otp_verification_screen.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/register_screen.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/set_password_screen.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/splash_screen.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/update_profile_screen.dart';
import 'package:cricket_scorer/features/home/presentation/bindings/home_binding.dart';
import 'package:cricket_scorer/features/home/presentation/pages/home_page.dart';
import 'package:get/get.dart';

abstract class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationScreen(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.setPassword,
      page: () => const SetPasswordScreen(),
      binding: SetPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.onBoarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.updateProfile,
      page: () => const UpdateProfileScreen(),
      binding: UpdateProfileBinding(),
    ),
  ];
}
