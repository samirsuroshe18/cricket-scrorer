import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/core/utils/validators.dart';
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

  /// 0 = empty/none, 1 = weak … 4 = strong. The page maps this score to a
  /// themed color; the controller stays free of presentation concerns.
  final passwordStrength = 0.obs;

  /// Holds a [TranslationKeys] key — the page applies `.tr`.
  final strengthLabel = ''.obs;

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
      return;
    }

    int score = 0;

    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    passwordStrength.value = score;

    strengthLabel.value = switch (score) {
      1 => TranslationKeys.passwordWeak,
      2 => TranslationKeys.passwordFair,
      3 => TranslationKeys.passwordGood,
      4 => TranslationKeys.passwordStrong,
      _ => '',
    };
  }

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
