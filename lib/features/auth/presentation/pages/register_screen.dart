import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/auth_scoreboard_header.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

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
                  const _AccountCard(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Form(
                      key: controller.formKey,
                      child: AutofillGroup(
                        child: Column(
                          children: [
                            CricketTextField(
                              controller: controller.fullNameController,
                              labelText: TranslationKeys.fullName.tr,
                              hintText: TranslationKeys.enterFullName.tr,
                              prefixIcon: const Icon(Icons.person_outline),
                              validator: controller.validateFullName,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              autofillHints: const [AutofillHints.name],
                              isRequired: true,
                            ),

                            16.h,

                            CricketTextField(
                              controller: controller.emailController,
                              labelText: TranslationKeys.email.tr,
                              hintText: TranslationKeys.enterEmail.tr,
                              prefixIcon: const Icon(Icons.email_outlined),
                              validator: controller.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [
                                AutofillHints.email,
                                AutofillHints.newUsername,
                              ],
                              isRequired: true,
                            ),

                            16.h,

                            AnimatedBuilder(
                              animation: controller.passwordController,
                              builder: (context, _) {
                                final password =
                                    controller.passwordController.text;
                                return Obx(
                                  () => Column(
                                    children: [
                                      CricketTextField(
                                        controller:
                                            controller.passwordController,
                                        labelText:
                                            TranslationKeys.password.tr,
                                        hintText:
                                            TranslationKeys.enterPassword.tr,
                                        obscureText: !controller
                                            .isPasswordVisible
                                            .value,
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed:
                                              controller
                                                  .togglePasswordVisibility,
                                          tooltip:
                                              controller
                                                  .isPasswordVisible
                                                  .value
                                              ? TranslationKeys
                                                    .hidePassword
                                                    .tr
                                              : TranslationKeys
                                                    .showPassword
                                                    .tr,
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
                                      8.h,
                                      _PasswordStrengthMeter(
                                        password: password,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            16.h,

                            AnimatedBuilder(
                              animation: Listenable.merge([
                                controller.passwordController,
                                controller.confirmPasswordController,
                              ]),
                              builder: (context, _) {
                                final matches =
                                    controller
                                        .confirmPasswordController
                                        .text
                                        .isNotEmpty &&
                                    controller.confirmPasswordController.text ==
                                        controller.passwordController.text;
                                return Obx(
                                  () => CricketTextField(
                                    controller:
                                        controller.confirmPasswordController,
                                    labelText:
                                        TranslationKeys.confirmPassword.tr,
                                    hintText: TranslationKeys
                                        .enterConfirmPassword
                                        .tr,
                                    obscureText: !controller
                                        .isConfirmPasswordVisible
                                        .value,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ExcludeSemantics(
                                          excluding: !matches,
                                          child: Semantics(
                                            label:
                                                TranslationKeys
                                                    .passwordsMatch
                                                    .tr,
                                            liveRegion: true,
                                            child: AnimatedScale(
                                              scale: matches ? 1 : 0.6,
                                              duration: Durations.short3,
                                              curve: Easing.standard,
                                              child: AnimatedOpacity(
                                                opacity: matches ? 1 : 0,
                                                duration: Durations.short3,
                                                curve: Easing.standard,
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: context
                                                      .colors
                                                      .statusSuccess,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: controller
                                              .toggleConfirmPasswordVisibility,
                                          tooltip:
                                              controller
                                                  .isConfirmPasswordVisible
                                                  .value
                                              ? TranslationKeys
                                                    .hidePassword
                                                    .tr
                                              : TranslationKeys
                                                    .showPassword
                                                    .tr,
                                          icon: Icon(
                                            controller
                                                    .isConfirmPasswordVisible
                                                    .value
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                        ),
                                      ],
                                    ),
                                    validator:
                                        controller.validateConfirmPassword,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    isRequired: true,
                                  ),
                                );
                              },
                            ),

                            24.h,

                            CricketButton(
                              buttonText: TranslationKeys.register.tr,
                              onPressed: controller.register,
                            ),

                            12.h,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CricketText(
                                  text: TranslationKeys.alreadyHaveAccount.tr,
                                ),
                                TextButton(
                                  onPressed: controller.goToLogin,
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

/// Overlaps the scoreboard header by design, mirroring the login screen's
/// welcome card — a layered composition rather than the header and greeting
/// sitting in separate, disconnected blocks.
class _AccountCard extends StatelessWidget {
  const _AccountCard();

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
            Semantics(
              header: true,
              child: CricketText(
                text: TranslationKeys.createAccount.tr,
                style: context.textTheme.headlineLarge,
              ),
            ),
            6.h,
            CricketText(
              text: TranslationKeys.joinAndStartScoring.tr,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// A three-segment bar that fills in as the password gets longer, colored
/// against the app's real minimum-length rule (see `Validators.password`)
/// rather than an arbitrary heuristic — red genuinely means "too short to
/// submit".
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.password});

  final String password;

  /// Mirrors `Validators.password`'s minimum length requirement.
  static const int _minLength = 8;

  @override
  Widget build(BuildContext context) {
    final length = password.trim().length;
    final int filledSegments;
    if (length == 0) {
      filledSegments = 0;
    } else if (length < _minLength) {
      filledSegments = 1;
    } else if (length < _minLength + 6) {
      filledSegments = 2;
    } else {
      filledSegments = 3;
    }

    final colors = context.colors;
    final segmentColors = [
      colors.statusDanger,
      colors.statusWarning,
      colors.statusSuccess,
    ];
    final label = switch (filledSegments) {
      1 => TranslationKeys.passwordStrengthWeak.tr,
      2 => TranslationKeys.passwordStrengthFair.tr,
      3 => TranslationKeys.passwordStrengthStrong.tr,
      _ => null,
    };

    return Semantics(
      label: TranslationKeys.passwordStrength.tr,
      value: label,
      liveRegion: true,
      excludeSemantics: true,
      child: Row(
        children: List.generate(3, (index) {
          final isFilled = index < filledSegments;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < 2 ? 4 : 0),
              child: AnimatedContainer(
                duration: Durations.short3,
                curve: Easing.standard,
                height: 4,
                decoration: BoxDecoration(
                  color: isFilled
                      ? segmentColors[filledSegments - 1]
                      : context.colorScheme.outline,
                  borderRadius: 2.radius,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Preview-only below. The full screen isn't previewable in isolation —
// ThemePickerButton/LanguagePickerButton resolve ThemeService/LanguageService
// via Get.find(), which cascade into SharedPreferences and repository
// dependencies the isolated Widget Previewer can't satisfy.

@_MultiPreviewBrightness(name: 'Account card')
Widget accountCardPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(child: _AccountCard()),
);

@_MultiPreviewBrightness(name: 'Password strength — empty')
Widget passwordStrengthEmptyPreview() => const Padding(
  padding: EdgeInsets.all(16),
  child: _PasswordStrengthMeter(password: ''),
);

@_MultiPreviewBrightness(name: 'Password strength — weak')
Widget passwordStrengthWeakPreview() => const Padding(
  padding: EdgeInsets.all(16),
  child: _PasswordStrengthMeter(password: 'abc'),
);

@_MultiPreviewBrightness(name: 'Password strength — fair')
Widget passwordStrengthFairPreview() => const Padding(
  padding: EdgeInsets.all(16),
  child: _PasswordStrengthMeter(password: 'abcdefgh'),
);

@_MultiPreviewBrightness(name: 'Password strength — strong')
Widget passwordStrengthStrongPreview() => const Padding(
  padding: EdgeInsets.all(16),
  child: _PasswordStrengthMeter(password: 'abcdefghijklmno'),
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
        ..group = 'Register screen'
        ..name = '$name — ${preview.brightness!.name}'
        ..theme = () => PreviewThemeData(
          materialLight: AppTheme.lightTheme,
          materialDark: AppTheme.darkTheme,
        );
      return builder.build();
    }).toList();
  }
}
