import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: 24.p,
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    8.rh,

                    Container(
                      height: 120,
                      width: 120,
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        AssetsUtil.appLogo,
                        fit: BoxFit.contain,
                      ),
                    ),

                    24.h,

                    CricketText(
                      text: 'Create Account',
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    8.h,

                    CricketText(
                      text: 'Join and start scoring matches',
                      style: Get.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),

                    40.h,

                    CricketTextField(
                      controller: controller.fullNameController,
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: controller.validateFullName,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                    ),

                    16.h,

                    CricketTextField(
                      controller: controller.emailController,
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: controller.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    16.h,

                    Obx(
                      () => CricketTextField(
                        controller: controller.passwordController,
                        hintText: 'Password',
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
                        hintText: 'Confirm Password',
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

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.register,
                        child: const Text('Register'),
                      ),
                    ),

                    24.h,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        GestureDetector(
                          onTap: controller.goToLogin,
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
