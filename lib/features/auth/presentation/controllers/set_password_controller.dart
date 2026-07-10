import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/set_pass_req.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/set_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetPasswordController extends GetxController {
  final ResetPasswordUseCase resetPasswordUseCase;

  SetPasswordController({required this.resetPasswordUseCase});

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  final passwordStrength = 0.obs;
  final strengthLabel = ''.obs;
  final strengthColor = Colors.transparent.obs;

  String _resetToken = '';
  String _email = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _resetToken = args?['resetToken'] as String? ?? '';
    _email = args?['email'] as String? ?? '';

    passwordController.addListener(_evaluatePasswordStrength);
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.toggle();
  }

  void _evaluatePasswordStrength() {
    final password = passwordController.text;

    if (password.isEmpty) {
      passwordStrength.value = 0;
      strengthLabel.value = '';
      strengthColor.value = Colors.transparent;
      return;
    }

    int score = 0;

    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    passwordStrength.value = score;

    switch (score) {
      case 1:
        strengthLabel.value = 'Weak';
        strengthColor.value = Colors.red;
        break;
      case 2:
        strengthLabel.value = 'Fair';
        strengthColor.value = Colors.orange;
        break;
      case 3:
        strengthLabel.value = 'Good';
        strengthColor.value = Colors.blue;
        break;
      case 4:
        strengthLabel.value = 'Strong';
        strengthColor.value = Colors.green;
        break;
      default:
        strengthLabel.value = '';
        strengthColor.value = Colors.transparent;
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.passwordRequired.tr;
    }
    if (value.length < 6) {
      return TranslationKeys.passwordTooShort.tr;
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.confirmPasswordRequired.tr;
    }
    if (value != passwordController.text) {
      return TranslationKeys.passwordsDoNotMatch.tr;
    }
    return null;
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    if (_resetToken.isEmpty) {
      CricketSnackbar.showErrorMessage(
        TranslationKeys.resetTokenMissing.tr,
      );
      return;
    }

    CricketLoaderDialog.show();

    Either<CricketResponse<void>, CricketFailure> response =
        await resetPasswordUseCase(
          params: SetPassReq(
            email: _email,
            resetToken: _resetToken,
            newPassword: passwordController.text,
            confirmPassword: confirmPasswordController.text,
          ),
        );

    CricketLoaderDialog.hide();

    if (response.isResult) {
      CricketSnackbar.showSuccessMessage(response.result.message);
      Get.until((route) => route.settings.name == AppRoutes.login);
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  @override
  void onClose() {
    passwordController.removeListener(_evaluatePasswordStrength);
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
