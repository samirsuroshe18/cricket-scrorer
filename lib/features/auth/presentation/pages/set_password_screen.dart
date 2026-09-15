import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/auth_scoreboard_header.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/set_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';

class SetPasswordScreen extends GetView<SetPasswordController> {
  const SetPasswordScreen({super.key});

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
                  const _SetPasswordCard(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Form(
                      key: controller.formKey,
                      child: AutofillGroup(
                        child: Column(
                          children: [
                            Obx(
                              () => CricketTextField(
                                controller: controller.passwordController,
                                labelText: TranslationKeys.newPassword.tr,
                                hintText: TranslationKeys.enterNewPassword.tr,
                                obscureText:
                                    !controller.isPasswordVisible.value,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed:
                                      controller.togglePasswordVisibility,
                                  tooltip: controller.isPasswordVisible.value
                                      ? TranslationKeys.hidePassword.tr
                                      : TranslationKeys.showPassword.tr,
                                  color: scheme.secondary,
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                validator: controller.validatePassword,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                isRequired: true,
                              ),
                            ),

                            16.h,

                            Obx(
                              () => CricketTextField(
                                controller: controller.confirmPasswordController,
                                labelText: TranslationKeys.confirmNewPassword.tr,
                                hintText: TranslationKeys
                                    .enterConfirmNewPassword
                                    .tr,
                                obscureText:
                                    !controller.isConfirmPasswordVisible.value,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: controller
                                      .toggleConfirmPasswordVisibility,
                                  tooltip:
                                      controller.isConfirmPasswordVisible.value
                                      ? TranslationKeys.hidePassword.tr
                                      : TranslationKeys.showPassword.tr,
                                  color: scheme.secondary,
                                  icon: Icon(
                                    controller.isConfirmPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                                validator: controller.validateConfirmPassword,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                isRequired: true,
                              ),
                            ),

                            16.h,

                            Obx(() {
                              final score = controller.passwordStrength.value;
                              return AnimatedSize(
                                duration: Durations.short3,
                                curve: Easing.standard,
                                alignment: Alignment.topCenter,
                                child: score <= 0
                                    ? const SizedBox(width: double.infinity)
                                    : _PasswordStrengthMeter(
                                        score: score,
                                        label: controller.strengthLabel.value
                                            .tr,
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlaps the scoreboard header by design, mirroring the other auth
/// screens' welcome card.
class _SetPasswordCard extends StatelessWidget {
  const _SetPasswordCard();

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
                Icons.password_rounded,
                color: scheme.primary,
                size: 26,
              ),
            ),
            14.h,
            Semantics(
              header: true,
              child: CricketText(
                text: TranslationKeys.setNewPassword.tr,
                style: context.textTheme.headlineLarge,
              ),
            ),
            6.h,
            CricketText(
              text: TranslationKeys.setNewPasswordDesc.tr,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// The 4-segment strength meter plus its label. Segments animate color as
/// [score] changes so the feedback reads as a response to typing rather
/// than a jump cut.
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.score, required this.label});

  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    final strengthColor = _strengthColor(context, score);

    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 4 : 0),
                  child: AnimatedContainer(
                    duration: Durations.short3,
                    curve: Easing.standard,
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
          ),
          4.h,
          CricketText(
            text: label,
            style: context.textTheme.bodySmall?.copyWith(
              color: strengthColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

// Preview-only below. The full screen isn't previewable in isolation —
// ThemePickerButton/LanguagePickerButton resolve ThemeService/LanguageService
// via Get.find(), which cascade into SharedPreferences and repository
// dependencies the isolated Widget Previewer can't satisfy. The strength
// meter is the screen's one interactive/functional addition, so it's
// previewed on its own at each score.

@_MultiPreviewBrightness(name: 'Set password card')
Widget setPasswordCardPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(child: _SetPasswordCard()),
);

@_MultiPreviewBrightness(name: 'Strength meter — weak')
Widget strengthMeterWeakPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: _PasswordStrengthMeter(score: 1, label: 'Weak'),
    ),
  ),
);

@_MultiPreviewBrightness(name: 'Strength meter — strong')
Widget strengthMeterStrongPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: _PasswordStrengthMeter(score: 4, label: 'Strong'),
    ),
  ),
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
        ..group = 'Set password screen'
        ..name = '$name — ${preview.brightness!.name}'
        ..theme = () => PreviewThemeData(
          materialLight: AppTheme.lightTheme,
          materialDark: AppTheme.darkTheme,
        );
      return builder.build();
    }).toList();
  }
}
