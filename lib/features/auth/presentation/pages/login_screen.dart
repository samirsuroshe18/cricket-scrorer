import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/string_extension.dart';
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      builder: (controller) {
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
              child: Column(
                children: [
                  4.rh,

                  const CricketImage(
                    source: CricketImageSource.asset(AssetsUtil.appLogo),
                    height: 120,
                    width: 120,
                    borderRadius: BorderRadius.all(Radius.circular(180)),
                  ),
                  24.h,

                  CricketText(
                    text: 'Cricket Scorer'.translation(),
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineLarge,
                  ),

                  8.h,

                  CricketText(
                    text: 'Track every ball, every run'.translation(),
                    style: Get.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  40.h,

                  CricketTextField(
                    controller: controller.emailController,
                    hintText: 'Email'.translation(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: controller.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  16.h,

                  Obx(
                    () => CricketTextField(
                      controller: controller.passwordController,
                      hintText: 'Password'.translation(),
                      obscureText: !controller.isPasswordVisible.value,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.isPasswordVisible.toggle();
                        },
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      validator: controller.validatePassword,
                    ),
                  ),
                  12.h,

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: controller.onForgotPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: CricketText(
                        text: 'Forgot Password?'.translation(),
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
                        text: "Don't have an account? ".translation(),
                      ),
                      TextButton(
                        onPressed: controller.goToRegister,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: CricketText(
                          text: 'Register'.translation(),
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
