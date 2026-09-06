import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/global/presentation/bindings/image_preview_binding.dart';
import 'package:cricket_scorer/core/global/presentation/pages/cricket_image_preview.dart';
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
import 'package:cricket_scorer/features/scoring/presentation/bindings/create_match_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/bindings/result_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/bindings/player_stats_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/bindings/score_ball_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/bindings/spectator_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/bindings/team_profile_binding.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/create_match_screen.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/result_screen.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/player_stats_screen.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/score_ball_screen.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/spectator_screen.dart';
import 'package:cricket_scorer/features/scoring/presentation/pages/team_profile_screen.dart';
import 'package:cricket_scorer/features/organization/presentation/bindings/organization_detail_binding.dart';
import 'package:cricket_scorer/features/organization/presentation/bindings/organizations_list_binding.dart';
import 'package:cricket_scorer/features/organization/presentation/pages/organization_detail_screen.dart';
import 'package:cricket_scorer/features/organization/presentation/pages/organizations_list_screen.dart';
import 'package:cricket_scorer/features/search/presentation/bindings/search_binding.dart';
import 'package:cricket_scorer/features/search/presentation/pages/search_screen.dart';
import 'package:cricket_scorer/features/tournament/presentation/bindings/tournament_detail_binding.dart';
import 'package:cricket_scorer/features/tournament/presentation/pages/tournament_detail_screen.dart';
import 'package:cricket_scorer/features/tournament/presentation/pages/tournament_leaderboards_screen.dart';
import 'package:cricket_scorer/features/tournament/presentation/pages/tournament_standings_screen.dart';
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
    GetPage(
      name: AppRoutes.imagePreview,
      page: () => const CricketImagePreview(),
      binding: ImagePreviewBinding(),
    ),
    GetPage(
      name: AppRoutes.createMatch,
      page: () => const CreateMatchScreen(),
      binding: CreateMatchBinding(),
    ),
    GetPage(
      name: AppRoutes.scoreBall,
      page: () => const ScoreBallScreen(),
      binding: ScoreBallBinding(),
    ),
    GetPage(
      name: AppRoutes.spectator,
      page: () => const SpectatorScreen(),
      binding: SpectatorBinding(),
    ),
    GetPage(
      name: AppRoutes.matchResult,
      page: () => const ResultScreen(),
      binding: ResultBinding(),
    ),
    GetPage(
      name: AppRoutes.playerStats,
      page: () => const PlayerStatsScreen(),
      binding: PlayerStatsBinding(),
    ),
    GetPage(
      name: AppRoutes.teamProfile,
      page: () => const TeamProfileScreen(),
      binding: TeamProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.organizations,
      page: () => const OrganizationsListScreen(),
      binding: OrganizationsListBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: AppRoutes.organizationDetail,
      page: () => const OrganizationDetailScreen(),
      binding: OrganizationDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.tournamentDetail,
      page: () => const TournamentDetailScreen(),
      binding: TournamentDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.tournamentStandings,
      page: () => const TournamentStandingsScreen(),
    ),
    GetPage(
      name: AppRoutes.tournamentLeaderboards,
      page: () => const TournamentLeaderboardsScreen(),
    ),
  ];
}
