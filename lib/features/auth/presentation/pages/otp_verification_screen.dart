import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/string_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/otp_verification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpVerificationController>(
      builder: (controller) {
        return Scaffold(
          appBar: const CustomAppBar(),
          body: SingleChildScrollView(
            padding: 24.p,
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  24.h,

                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                  ),

                  24.h,

                  CricketText(
                    text: 'Verify Your Account'.translation(),
                    style: Get.textTheme.headlineLarge,
                  ),

                  12.h,

                  Obx(
                    () => CricketText(
                      text:
                          'We sent a 6-digit code to\n${controller.maskedTarget.value}'
                              .translation(),
                      style: Get.textTheme.bodyMedium,
                    ),
                  ),

                  40.h,

                  // OTP input boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      6,
                      (index) => _OtpBox(
                        controller: controller.otpControllers[index],
                        focusNode: controller.focusNodes[index],
                        onChanged: (value) =>
                            controller.onOtpChanged(value, index),
                      ),
                    ),
                  ),

                  32.h,

                  CricketButton(
                    buttonText: 'Verify'.translation(),
                    onPressed: controller.verifyOtp,
                  ),

                  24.h,
                  Obx(
                    () => controller.isResendEnabled.value
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CricketText(
                                text: "Didn't receive the code?  "
                                    .translation(),
                              ),
                              TextButton(
                                onPressed: controller.resendOtp,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: CricketText(
                                  text: 'Resend'.translation(),
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: context.colorScheme.primary,
                                      ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CricketText(
                                text: 'Resend code in  '.translation(),
                              ),
                              Obx(
                                () => CricketText(
                                  text: '${controller.resendCountdown.value}s'
                                      .translation(),
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: context.colorScheme.primary,
                                      ),
                                ),
                              ),
                            ],
                          ),
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

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) return '';
          return null;
        },
      ),
    );
  }
}
