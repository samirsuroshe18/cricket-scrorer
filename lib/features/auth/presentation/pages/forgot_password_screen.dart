import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/string_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(
      builder: (controller) {
        return Scaffold(
          appBar: const CustomAppBar(),
          body: SingleChildScrollView(
            padding: 24.p,
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  4.rh,
                  const Icon(
                    Icons.lock_reset_rounded,
                    size: 80,
                  ),

                  24.h,

                  CricketText(
                    text: 'Forgot Password?'.translation(),
                    style: Get.textTheme.headlineLarge,
                  ),

                  12.h,

                  CricketText(
                    text:
                        'Enter your registered email and we\'ll send\nyou a reset code.'
                            .translation(),
                    style: Get.textTheme.bodyMedium,
                  ),

                  40.h,

                  CricketTextField(
                    controller: controller.emailController,
                    hintText: 'Email'.translation(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: controller.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  24.h,

                  CricketButton(
                    buttonText: 'Send Reset Code'.translation(),
                    onPressed: controller.sendResetCode,
                  ),

                  18.h,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CricketText(
                        text: 'Remembered your password? '.translation(),
                      ),
                      TextButton(
                        onPressed: () => Get.back<dynamic>(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: CricketText(
                          text: 'Login'.translation(),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
