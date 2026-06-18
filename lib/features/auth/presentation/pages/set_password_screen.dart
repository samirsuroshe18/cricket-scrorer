import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/set_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetPasswordScreen extends StatelessWidget {
  const SetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SetPasswordController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back<dynamic>(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
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
                        Icons.lock_outline_rounded,
                        size: 40,
                        color: Get.theme.primaryColor,
                      ),
                    ),

                    24.h,

                    CricketText(
                      text: 'Set New Password',
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    12.h,

                    CricketText(
                      text:
                          'Your new password must be different\nfrom your previous password.',
                      style: Get.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),

                    40.h,

                    Obx(
                      () => CricketTextField(
                        controller: controller.passwordController,
                        hintText: 'New Password',
                        obscureText: !controller.isPasswordVisible.value,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: controller.togglePasswordVisibility,
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        validator: controller.validatePassword,
                      ),
                    ),

                    16.h,

                    Obx(
                      () => CricketTextField(
                        controller: controller.confirmPasswordController,
                        hintText: 'Confirm New Password',
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: controller.toggleConfirmPasswordVisibility,
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        validator: controller.validateConfirmPassword,
                      ),
                    ),

                    // Password strength indicator
                    16.h,

                    Obx(
                      () => controller.passwordStrength.value > 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    4,
                                    (index) => Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          right: index < 3 ? 4 : 0,
                                        ),
                                        height: 4,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          color:
                                              index <
                                                  controller
                                                      .passwordStrength
                                                      .value
                                              ? controller.strengthColor.value
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                4.h,
                                CricketText(
                                  text: controller.strengthLabel.value,
                                  style: Get.textTheme.bodySmall?.copyWith(
                                    color: controller.strengthColor.value,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    32.h,

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.resetPassword,
                        child: const Text('Reset Password'),
                      ),
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
