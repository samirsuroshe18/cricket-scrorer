import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/auth_scoreboard_header.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  const AuthScoreboardHeader(),
                  const _ResetCard(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Form(
                      key: controller.formKey,
                      child: AutofillGroup(
                        child: Column(
                          children: [
                            AnimatedBuilder(
                              animation: controller.emailController,
                              builder: (context, _) {
                                final isValid = GetUtils.isEmail(
                                  controller.emailController.text.trim(),
                                );
                                return CricketTextField(
                                  controller: controller.emailController,
                                  labelText: TranslationKeys.email.tr,
                                  hintText: TranslationKeys.enterEmail.tr,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  suffixIcon: ExcludeSemantics(
                                    excluding: !isValid,
                                    child: Semantics(
                                      label: TranslationKeys.validEmail.tr,
                                      liveRegion: true,
                                      child: AnimatedScale(
                                        scale: isValid ? 1 : 0.6,
                                        duration: Durations.short3,
                                        curve: Easing.standard,
                                        child: AnimatedOpacity(
                                          opacity: isValid ? 1 : 0,
                                          duration: Durations.short3,
                                          curve: Easing.standard,
                                          child: Icon(
                                            Icons.check_circle,
                                            color:
                                                context.colors.statusSuccess,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  validator: controller.validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  isRequired: true,
                                );
                              },
                            ),

                            24.h,

                            CricketButton(
                              buttonText: TranslationKeys.sendResetCode.tr,
                              onPressed: controller.sendResetCode,
                            ),

                            12.h,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CricketText(
                                  text: TranslationKeys.rememberedPassword.tr,
                                ),
                                TextButton(
                                  onPressed: () => Get.back<dynamic>(),
                                  child: CricketText(
                                    text: TranslationKeys.login.tr,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlaps the scoreboard header by design, mirroring the login/register
/// screens' welcome card. The icon badge is the one added anchor this
/// screen needs — a bare text-only card would feel empty next to its
/// denser siblings.
class _ResetCard extends StatelessWidget {
  const _ResetCard();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Transform.translate(
      offset: const Offset(0, -28),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: 16.radius,
          border: Border.all(color: scheme.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                color: scheme.primary,
                size: 26,
              ),
            ),
            14.h,
            Semantics(
              header: true,
              child: CricketText(
                text: TranslationKeys.forgotPassword.tr,
                style: context.textTheme.headlineLarge,
              ),
            ),
            6.h,
            CricketText(
              text: TranslationKeys.forgotPasswordDesc.tr,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// Preview-only below. The full screen isn't previewable in isolation —
// ThemePickerButton/LanguagePickerButton resolve ThemeService/LanguageService
// via Get.find(), which cascade into SharedPreferences and repository
// dependencies the isolated Widget Previewer can't satisfy.

@_MultiPreviewBrightness(name: 'Reset card')
Widget resetCardPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(child: _ResetCard()),
);

final class _MultiPreviewBrightness extends MultiPreview {
  const _MultiPreviewBrightness({required this.name});

  final String name;

  @override
  List<Preview> get previews => const [
    Preview(brightness: Brightness.light),
    Preview(brightness: Brightness.dark),
  ];

  @override
  List<Preview> transform() {
    return super.transform().map((preview) {
      final builder = preview.toBuilder()
        ..group = 'Forgot password screen'
        ..name = '$name — ${preview.brightness!.name}'
        ..theme = () => PreviewThemeData(
          materialLight: AppTheme.lightTheme,
          materialDark: AppTheme.darkTheme,
        );
      return builder.build();
    }).toList();
  }
}
