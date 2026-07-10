import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/verify_otp_req.dart';
import 'package:cricket_scorer/features/auth/data/models/response/verify_otp_res.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/resend_otp.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/verify_otp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerificationController extends GetxController {
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;

  OtpVerificationController({
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
  });

  final formKey = GlobalKey<FormState>();

  // 6 individual controllers and focus nodes for OTP boxes
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final focusNodes = List.generate(6, (_) => FocusNode());

  final maskedTarget = ''.obs;
  final isResendEnabled = false.obs;
  final resendCountdown = 30.obs;

  Timer? _countdownTimer;

  // Passed via Get.arguments from RegisterScreen or ForgotPasswordScreen
  String _email = '';
  String _type = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _email = args?['email'] as String? ?? '';
    _type = args?['type'] as String? ?? '';
    maskedTarget.value = _email.isNotEmpty ? _maskEmail(_email) : '******';
    _startResendCountdown();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final visible = name.length > 2 ? name.substring(0, 2) : name[0];
    return '$visible***@${parts[1]}';
  }

  void _startResendCountdown() {
    isResendEnabled.value = false;
    resendCountdown.value = 30;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value <= 1) {
        timer.cancel();
        isResendEnabled.value = true;
      } else {
        resendCountdown.value--;
      }
    });
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move focus to next box
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        // Last box — dismiss keyboard
        focusNodes[index].unfocus();
      }
    } else {
      // On delete, move focus to previous box
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      }
    }
  }

  String get _otpCode => otpControllers.map((c) => c.text).join();

  void _clearOtp() {
    for (final c in otpControllers) {
      c.clear();
    }
    focusNodes.first.requestFocus();
  }

  Future<void> verifyOtp() async {
    if (!formKey.currentState!.validate()) {
      CricketSnackbar.showErrorMessage(
        TranslationKeys.enterCompleteCode.tr,
      );
      return;
    }

    final otp = _otpCode;
    if (otp.length < 6) {
      CricketSnackbar.showErrorMessage(
        TranslationKeys.enterCompleteCode.tr,
      );
      return;
    }

    CricketLoaderDialog.show();

    Either<CricketResponse<VerifyOtpRes>, CricketFailure> response =
        await verifyOtpUseCase(
          params: VerifyOtpReq(
            email: _email,
            emailOtp: _otpCode,
            type: _type,
          ),
        );

    CricketLoaderDialog.hide();

    if (response.isResult) {
      if (_type == 'EMAIL_VERIFICATION') {
        Get.until((route) => route.settings.name == AppRoutes.login);
      } else if (_type == 'FORGOT_PASSWORD') {
        unawaited(
          Get.toNamed<dynamic>(
            AppRoutes.setPassword,
            arguments: {
              'email': _email,
              'resetToken': response.result.data?.resetToken ?? '',
            },
          ),
        );
        _clearOtp();
      } else {
        Get.back<dynamic>();
      }
    } else {
      _clearOtp();
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  Future<void> resendOtp() async {
    if (!isResendEnabled.value) return;

    CricketLoaderDialog.show();

    Either<CricketResponse<Map<String, dynamic>>, CricketFailure> response =
        await resendOtpUseCase(
          params: VerifyOtpReq(
            email: _email,
            emailOtp: _otpCode,
            type: _type,
          ),
        );

    CricketLoaderDialog.hide();

    if (response.isResult) {
      _clearOtp();
      _startResendCountdown();
      CricketSnackbar.showSuccessMessage(response.result.message);
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
