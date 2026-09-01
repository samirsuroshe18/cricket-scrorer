import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/set_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetPasswordScreen extends GetView<SetPasswordController> {
  const SetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: 24.p,
        child: Form(
          key: controller.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                24.h,

                const Icon(
                  Icons.lock_outline_rounded,
                  size: 80,
                ),

                24.h,

                CricketText(
                  text: TranslationKeys.setNewPassword.tr,
                  style: Get.textTheme.headlineLarge,
                ),
                12.h,

                CricketText(
                  text: TranslationKeys.setNewPasswordDesc.tr,
                  style: Get.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                40.h,

                Obx(
                  () => CricketTextField(
                    controller: controller.passwordController,
                    labelText: TranslationKeys.newPassword.tr,
                    hintText: TranslationKeys.enterNewPassword.tr,
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
                    autofillHints: const [AutofillHints.newPassword],
                    isRequired: true,
                  ),
                ),

                16.h,

                Obx(
                  () => CricketTextField(
                    controller: controller.confirmPasswordController,
                    labelText: TranslationKeys.confirmNewPassword.tr,
                    hintText: TranslationKeys.enterConfirmNewPassword.tr,
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
                    autofillHints: const [AutofillHints.newPassword],
                    isRequired: true,
                  ),
                ),

                // Password strength indicator
                16.h,

                Obx(() {
                  final score = controller.passwordStrength.value;
                  if (score <= 0) return const SizedBox.shrink();

                  final strengthColor = _strengthColor(context, score);

                  return Column(
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
                                borderRadius: 2.radius,
                                color: index < score
                                    ? strengthColor
                                    : context.colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      4.h,
                      CricketText(
                        text: controller.strengthLabel.value.tr,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: strengthColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }),

                32.h,
                CricketButton(
                  buttonText: TranslationKeys.resetPassword.tr,
                  onPressed: controller.resetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Maps a password-strength score (1–4) to a themed severity color.
  Color _strengthColor(BuildContext context, int score) => switch (score) {
    1 => context.colors.statusDanger,
    2 => context.colors.statusWarning,
    3 => context.colors.statusInfo,
    _ => context.colors.statusSuccess,
  };
}
