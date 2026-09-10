import 'dart:async';

import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/global/widgets/language_picker_button.dart';
import 'package:cricket_scorer/core/global/widgets/theme_picker_button.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/login_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/watch_match_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          const ThemePickerButton(),
          const LanguagePickerButton(),
          12.w,
        ],
      ),
      body: SingleChildScrollView(
        padding: 24.p,
        child: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: AutofillGroup(
            child: Column(
              children: [
                4.rh,

                const ExcludeSemantics(
                  // Decorative — the app name right below it already
                  // conveys the same information to a screen reader.
                  child: CricketImage(
                    source: CricketImageSource.asset(
                      AssetsUtil.appLogo,
                    ),
                    height: 120,
                    width: 120,
                    borderRadius: BorderRadius.all(
                      Radius.circular(180),
                    ),
                  ),
                ),
                24.h,

                Semantics(
                  header: true,
                  child: CricketText(
                    text: TranslationKeys.cricketScorer.tr,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineLarge,
                  ),
                ),

                8.h,

                CricketText(
                  text: TranslationKeys.trackEveryBall.tr,
                  style: Get.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                40.h,

                CricketTextField(
                  controller: controller.emailController,
                  hintText: TranslationKeys.enterEmail.tr,
                  labelText: TranslationKeys.email.tr,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: controller.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  isRequired: true,
                ),

                16.h,

                Obx(
                  () => CricketTextField(
                    controller: controller.passwordController,
                    hintText: TranslationKeys.enterPassword.tr,
                    labelText: TranslationKeys.password.tr,
                    obscureText: !controller.isPasswordVisible.value,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        controller.isPasswordVisible.toggle();
                      },
                      tooltip: controller.isPasswordVisible.value
                          ? TranslationKeys.hidePassword.tr
                          : TranslationKeys.showPassword.tr,
                      // Tinted so it reads as the interactive control next
                      // to the static, neutral-colored lock icon — the same
                      // accent "Forgot password?" already uses just below.
                      color: context.colorScheme.secondary,
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    validator: controller.validatePassword,
                    autofillHints: const [AutofillHints.password],
                    isRequired: true,
                  ),
                ),
                12.h,

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.onForgotPassword,
                    child: CricketText(
                      text: TranslationKeys.forgotPassword.tr,
                    ),
                  ),
                ),

                20.h,

                CricketButton(
                  buttonText: TranslationKeys.login.tr,
                  onPressed: controller.login,
                ),

                12.h,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CricketText(
                      text: TranslationKeys.dontHaveAccount.tr,
                    ),
                    TextButton(
                      onPressed: controller.goToRegister,
                      child: CricketText(
                        text: TranslationKeys.register.tr,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                24.h,

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    12.w,
                    CricketText(
                      text: TranslationKeys.or.tr,
                      style: context.textTheme.bodySmall,
                    ),
                    12.w,
                    const Expanded(child: Divider()),
                  ],
                ),

                16.h,

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => unawaited(WatchMatchBottomSheet.show()),
                    icon: const Icon(Icons.sports_cricket_outlined),
                    label: CricketText(
                      text: TranslationKeys.watchLiveMatch.tr,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
