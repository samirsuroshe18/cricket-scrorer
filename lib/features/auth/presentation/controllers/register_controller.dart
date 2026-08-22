import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/core/utils/validators.dart';
import 'package:cricket_scorer/features/auth/data/models/request/register_req.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final RegisterUseCase registerUseCase;

  RegisterController({required this.registerUseCase});

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.toggle();
  }

  void goToLogin() {
    Get.back<dynamic>();
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.fullNameRequired.tr;
    }
    if (value.trim().length < 2) {
      return TranslationKeys.nameTooShort.tr;
    }
    return null;
  }

  String? validateEmail(String? value) => Validators.email(value);

  String? validatePassword(String? value) => Validators.password(value);

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.confirmPasswordRequired.tr;
    }
    if (value != passwordController.text) {
      return TranslationKeys.passwordsDoNotMatch.tr;
    }
    return null;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    CricketLoaderDialog.show();

    Either<CricketResponse<Map<String, dynamic>>, CricketFailure> response =
        await registerUseCase(
          params: RegisterReq(
            fullName: fullNameController.text.trim(),
            email: emailController.text.trim().toLowerCase(),
            password: passwordController.text,
          ),
        );

    CricketLoaderDialog.hide();

    if (response.isResult) {
      CricketSnackbar.showSuccessMessage(response.result.message);
      unawaited(
        Get.toNamed<dynamic>(
          AppRoutes.otpVerification,
          arguments: {
            'email': emailController.text.trim().toLowerCase(),
            'type': 'EMAIL_VERIFICATION',
          },
        ),
      );
      clearFields();
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  void clearFields() {
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
