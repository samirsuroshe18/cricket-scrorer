import 'package:cricket_scorer/core/database/app_database.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/features/auth/data/auth_endpoint.dart';
import 'package:cricket_scorer/features/auth/data/data_sources/local/DAO/user_dao.dart';
import 'package:cricket_scorer/features/auth/data/data_sources/remote/user_api_service/user_api_service.dart';
import 'package:cricket_scorer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cricket_scorer/features/auth/domain/repositories/auth_repository.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/forgot_password.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/get_user.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/login.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/logout.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/register.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/resend_otp.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/set_password.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/update_profile.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/verify_otp.dart';
import 'package:get/get.dart';

class AuthInjection {
  AuthInjection._();

  static void init() {
    const authEndpoint = AuthEndpoint();

    Get.lazyPut<UserDao>(
      () => Get.find<AppDatabase>().userDao,
      fenix: true,
    );

    Get.lazyPut<UserApiService>(
      () => UserApiService(
        apiClient: Get.find<ApiClient>(),
        authEndpoint: authEndpoint,
      ),
      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        userApiService: Get.find<UserApiService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<GetUserUseCase>(
      () => GetUserUseCase(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ForgotPasswordUseCase>(
      () => ForgotPasswordUseCase(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<VerifyOtpUseCase>(
      () => VerifyOtpUseCase(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ResendOtpUseCase>(
      () => ResendOtpUseCase(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RegisterUseCase>(
      () => RegisterUseCase(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<LogoutUseCase>(
      () => LogoutUseCase(
        authRepository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );
  }
}
