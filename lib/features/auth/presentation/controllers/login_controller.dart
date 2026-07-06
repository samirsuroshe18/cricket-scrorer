import 'dart:async';
import 'dart:convert';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_user_language.dart';
import 'package:cricket_scorer/core/global/domain/usecases/get_version.dart';
import 'package:cricket_scorer/core/global/domain/usecases/update_language.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/language_service.dart';
import 'package:cricket_scorer/core/services/secure_storages_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/login_request_model.dart';
import 'package:cricket_scorer/features/auth/data/models/login_response.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final GetVersionUseCase getVersionUseCase;
  final GetLanguageUseCase getLanguageUseCase;
  final UpdateLanguageUseCase updateLanguageUseCase;

  final LoginUseCase loginUseCase;

  LoginController({
    required this.loginUseCase,
    required this.getVersionUseCase,
    required this.getLanguageUseCase,
    required this.updateLanguageUseCase,
  });

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void goToRegister() {
    clearFields();
    unawaited(Get.toNamed(AppRoutes.register));
  }

  void onForgotPassword() {
    clearFields();
    unawaited(Get.toNamed(AppRoutes.forgotPassword));
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!GetUtils.isEmail(value.trim())) {
      return 'Enter a valid email';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    CricketLoaderDialog.show();

    Either<CricketResponse<LoginResponse>, CricketFailure> response =
        await loginUseCase(
          params: LoginModel(
            email: emailController.text.trim().toLowerCase(),
            password: passwordController.text,
            rememberMe: false,
          ),
        );

    CricketLoaderDialog.hide();

    if (response.isResult) {
      try {
        await SecureStorageService.secure.set(
          SharedPrefKey.accessToken,
          response.result.data?.accessToken ?? '',
        );

        await SharedPreferenceService.sharedPrefService.set(
          SharedPrefKey.userDetails,
          jsonEncode(response.result.data?.loggedInUser?.toJson()),
        );

        bool? onboardingCompleted =
            await SharedPreferenceService.sharedPrefService.get(
                  SharedPrefKey.onboardingCompleted,
                )
                as bool?;
        if (onboardingCompleted == null || !onboardingCompleted) {
          unawaited(
            Get.offAllNamed(
              AppRoutes.onBoarding,
              arguments:
                  {
                        'profileCompleted':
                            response
                                .result
                                .data
                                ?.loggedInUser
                                ?.profileCompleted ??
                            false,
                      }
                      as Map<String, dynamic>,
            ),
          );
          return;
        } else if (!(response.result.data?.loggedInUser?.profileCompleted ?? false)) {
          unawaited(Get.offAllNamed(AppRoutes.updateProfile));
          return;
        } else {
          unawaited(Get.offAllNamed(AppRoutes.home));
        }

        CricketSnackbar.showSuccessMessage(response.result.message);
        unawaited(
          Get.find<LanguageService>().syncLanguageFromServer(
            getUserLanguageUseCase: Get.find<GetUserLanguageUseCase>(),
            updateLanguageUseCase: Get.find<UpdateLanguageUseCase>(),
          ),
        );
      } catch (e) {
        CricketSnackbar.showErrorMessage(
          'Failed to save login session. Please try again.',
        );
      }
    } else {
      if (response.fallback.statusCode == 403) {
        unawaited(
          Get.toNamed<dynamic>(
            AppRoutes.otpVerification,
            arguments: {
              'email': emailController.text.trim().toLowerCase(),
              'type': 'EMAIL_VERIFICATION',
            },
          ),
        );
      }
      CricketSnackbar.showAlertMessage(response.fallback.message);
    }
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
