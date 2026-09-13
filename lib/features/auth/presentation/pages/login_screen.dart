import 'dart:async';

import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/global/widgets/language_picker_button.dart';
import 'package:cricket_scorer/core/global/widgets/theme_picker_button.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/login_controller.dart';
import 'package:cricket_scorer/features/auth/presentation/widget/live_badge.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/watch_match_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

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
                  const _ScoreboardHeader(),
                  const _WelcomeCard(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Form(
                      key: controller.formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: AutofillGroup(
                        child: Column(
                          children: [
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
                                  color: scheme.secondary,
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

                            8.h,

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

                            const _SpectatorTile(),
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

/// The scoreboard header: ball mark, wordmark, theme/language pickers, and
/// the live indicator — replaces a plain AppBar since this screen's chrome
/// is bespoke, not a generic bar sitting above unrelated content.
class _ScoreboardHeader extends StatelessWidget {
  const _ScoreboardHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surface),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 40),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ThemePickerButton(),
                LanguagePickerButton(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const ExcludeSemantics(
                    // Decorative — the wordmark right next to it already
                    // conveys the same information to a screen reader.
                    child: CricketImage(
                      source: CricketImageSource.asset(AssetsUtil.ballMark),
                      width: 32,
                      height: 26,
                      fit: BoxFit.contain,
                    ),
                  ),
                  10.w,
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: CricketText(
                        text: TranslationKeys.cricketScorer.tr.toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const LiveBadge(pulsing: true),
                ],
              ),
            ),
            12.h,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 3,
                  width: 64,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: 2.radius,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlaps the scoreboard header by design — a deliberate layered
/// composition rather than the header and greeting sitting in separate,
/// disconnected blocks.
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

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
                text: TranslationKeys.welcomeBack.tr,
                style: context.textTheme.headlineLarge,
              ),
            ),
            6.h,
            CricketText(
              text: TranslationKeys.signInToKeepScoring.tr,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// The spectator entry point — styled as its own distinct tile rather than
/// a second button matching Log in's shape, so it reads as a genuinely
/// different path rather than a lower-priority repeat of the same control.
class _SpectatorTile extends StatelessWidget {
  const _SpectatorTile();

  @override
  Widget build(BuildContext context) {
    final live = context.colors.statusSuccess;

    return Material(
      color: live.withValues(alpha: 0.08),
      borderRadius: 14.radius,
      child: InkWell(
        borderRadius: 14.radius,
        onTap: () => unawaited(WatchMatchBottomSheet.show()),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: 14.radius,
            border: Border.all(color: live.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.sports_cricket_outlined, color: live),
              12.w,
              Expanded(
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CricketText(
                        text: TranslationKeys.watchLiveMatch.tr,
                        style: context.textTheme.titleSmall,
                      ),
                      CricketText(
                        text: TranslationKeys.noAccountNeeded.tr,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: live),
            ],
          ),
        ),
      ),
    );
  }
}

// Preview-only below. `_ScoreboardHeader` isn't previewable in isolation —
// ThemePickerButton/LanguagePickerButton resolve ThemeService/LanguageService
// and two use cases via Get.find(), which cascade into SharedPreferences and
// repository dependencies the isolated Widget Previewer can't satisfy.

@MultiPreviewBrightness(name: 'Welcome card')
Widget welcomeCardPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(child: _WelcomeCard()),
);

@MultiPreviewBrightness(name: 'Spectator tile')
Widget spectatorTilePreview() => const Padding(
  padding: EdgeInsets.all(16),
  child: _SpectatorTile(),
);

final class MultiPreviewBrightness extends MultiPreview {
  const MultiPreviewBrightness({required this.name});

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
        ..group = 'Login screen'
        ..name = '$name — ${preview.brightness!.name}'
        ..theme = () => PreviewThemeData(
          materialLight: AppTheme.lightTheme,
          materialDark: AppTheme.darkTheme,
        );
      return builder.build();
    }).toList();
  }
}
