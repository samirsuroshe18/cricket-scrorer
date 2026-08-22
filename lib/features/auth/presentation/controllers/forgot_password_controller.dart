import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/core/utils/validators.dart';
import 'package:cricket_scorer/features/auth/data/models/request/forgot_pass_req.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final ForgotPasswordUseCase forgotPasswordUseCase;

  ForgotPasswordController({required this.forgotPasswordUseCase});

  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? validateEmail(String? value) => Validators.email(value);

  Future<void> sendResetCode() async {
    if (!formKey.currentState!.validate()) return;

    CricketLoaderDialog.show();

    Either<CricketResponse<void>, CricketFailure> response =
        await forgotPasswordUseCase(
          params: ForgotPassReq(
            email: emailController.text.trim().toLowerCase(),
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
            'type': 'FORGOT_PASSWORD',
          },
        ),
      );
      emailController.clear();
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
