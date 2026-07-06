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
import 'package:cricket_scorer/features/auth/presentation/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
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

                  const CricketImage(
                    source: CricketImageSource.asset(AssetsUtil.appLogo),
                    height: 120,
                    width: 120,
                    borderRadius: BorderRadius.all(Radius.circular(180)),
                  ),

                  24.h,

                  CricketText(
                    text: 'Create Account'.translation(),
                    style: Get.textTheme.headlineLarge,
                  ),

                  8.h,

                  CricketText(
                    text: 'Join and start scoring matches'.translation(),
                    style: Get.textTheme.bodyMedium,
                  ),

                  40.h,

                  CricketTextField(
                    controller: controller.fullNameController,
                    labelText: 'Full Name'.translation(),
                    hintText: 'Enter Full Name'.translation(),
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: controller.validateFullName,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    isRequired: true,
                  ),

                  16.h,

                  CricketTextField(
                    controller: controller.emailController,
                    labelText: 'Email'.translation(),
                    hintText: 'Enter email'.translation(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: controller.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  16.h,

                  Obx(
                    () => CricketTextField(
                      controller: controller.passwordController,
                      labelText: 'Password'.translation(),
                      hintText: 'Enter Password'.translation(),
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
                      isRequired: true,
                    ),
                  ),

                  16.h,

                  Obx(
                    () => CricketTextField(
                      controller: controller.confirmPasswordController,
                      labelText: 'Confirm Password'.translation(),
                      hintText: 'Enter Confirm Password'.translation(),
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

                  24.h,

                  CricketButton(
                    buttonText: 'Register'.translation(),
                    onPressed: controller.register,
                  ),

                  18.h,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CricketText(
                        text: 'Already have an account? '.translation(),
                      ),
                      TextButton(
                        onPressed: controller.goToLogin,
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
