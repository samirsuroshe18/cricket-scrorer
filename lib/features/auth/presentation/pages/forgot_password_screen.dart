import 'package:cricket_scorer/core/extensions/space_extension.dart';
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
          appBar: const CustomAppBar(
            title: '',
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: 24.p,
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    24.h,

                    Container(
                      height: 80,
                      width: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 40,
                        color: Get.theme.primaryColor,
                      ),
                    ),

                    24.h,

                    CricketText(
                      text: 'Forgot Password?',
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    12.h,

                    CricketText(
                      text:
                          'Enter your registered email and we\'ll send\nyou a reset code.',
                      style: Get.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),

                    40.h,

                    CricketTextField(
                      controller: controller.emailController,
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: controller.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    24.h,

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.sendResetCode,
                        child: const Text('Send Reset Code'),
                      ),
                    ),

                    24.h,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Remembered your password? '),
                        GestureDetector(
                          onTap: () => Get.back<dynamic>(),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
