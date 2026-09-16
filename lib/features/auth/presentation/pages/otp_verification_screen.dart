import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/auth_scoreboard_header.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/otp_verification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen extends GetView<OtpVerificationController> {
  const OtpVerificationScreen({super.key});

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
                  const _VerifyCard(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          _OtpPinput(
                            controller: controller.otpController,
                            focusNode: controller.focusNode,
                          ),

                          24.h,

                          CricketButton(
                            buttonText: TranslationKeys.verify.tr,
                            onPressed: controller.verifyOtp,
                          ),

                          16.h,

                          Obx(
                            () => Semantics(
                              liveRegion: true,
                              child: AnimatedSwitcher(
                                duration: Durations.short3,
                                switchInCurve: Easing.standard,
                                switchOutCurve: Easing.standard,
                                child: controller.isResendEnabled.value
                                    ? Row(
                                        key: const ValueKey('resend-enabled'),
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CricketText(
                                            text: TranslationKeys
                                                .didNotReceiveCode
                                                .tr,
                                          ),
                                          TextButton(
                                            onPressed: controller.resendOtp,
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: CricketText(
                                              text: TranslationKeys.resend.tr,
                                              style: context
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: scheme.primary,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        key: const ValueKey(
                                          'resend-countdown',
                                        ),
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CricketText(
                                            text: TranslationKeys
                                                .resendCodeIn
                                                .tr,
                                          ),
                                          4.w,
                                          CricketText(
                                            text:
                                                '${controller.resendCountdown.value}s',
                                            style: context
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: scheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
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
/// screens' welcome card. Reads [OtpVerificationController.maskedTarget]
/// directly since it needs the masked email in its subtitle.
class _VerifyCard extends GetView<OtpVerificationController> {
  const _VerifyCard();

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
                Icons.mark_email_read_outlined,
                color: scheme.primary,
                size: 26,
              ),
            ),
            14.h,
            Semantics(
              header: true,
              child: CricketText(
                text: TranslationKeys.verifyYourAccount.tr,
                style: context.textTheme.headlineLarge,
              ),
            ),
            6.h,
            Obx(
              () => Semantics(
                liveRegion: true,
                child: CricketText(
                  text: TranslationKeys.otpVerificationDesc.trParams({
                    'target': controller.maskedTarget.value,
                  }),
                  style: context.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The 6-digit code entry, built on the `pinput` package rather than a
/// hand-rolled row of text fields — it owns SMS/clipboard autofill, paste
/// distribution across boxes, and the focused/default decoration swap
/// (animated implicitly by [PinTheme]) that this screen previously had to
/// reimplement itself.
class _OtpPinput extends StatelessWidget {
  const _OtpPinput({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: 12.radius,
        border: Border.all(color: scheme.outline),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: scheme.primary, width: 2),
      ),
    );

    // Caps scaling for these boxed glyphs at 200% (WCAG 1.4.4's required
    // minimum) so iOS's larger accessibility sizes (up to ~3.1x) can't clip
    // them against the fixed 48x56 boxes — the rest of the screen keeps the
    // device's full text-scale setting.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 2,
      child: Semantics(
        label: TranslationKeys.otpFieldLabel.tr,
        textField: true,
        child: Pinput(
          length: 6,
          controller: controller,
          focusNode: focusNode,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: defaultPinTheme,
          animationCurve: Easing.standard,
          animationDuration: Durations.short2,
        ),
      ),
    );
  }
}

// Preview-only below. The full screen isn't previewable in isolation —
// ThemePickerButton/LanguagePickerButton resolve ThemeService/LanguageService
// via Get.find(), which cascade into SharedPreferences and repository
// dependencies the isolated Widget Previewer can't satisfy. The pin field
// is the screen's one interactive/functional addition, so it's previewed on
// its own with a local controller instead.

@_MultiPreviewBrightness(name: 'OTP field')
Widget otpFieldPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(child: _OtpPinputPreview()),
);

class _OtpPinputPreview extends StatefulWidget {
  const _OtpPinputPreview();

  @override
  State<_OtpPinputPreview> createState() => _OtpPinputPreviewState();
}

class _OtpPinputPreviewState extends State<_OtpPinputPreview> {
  final _controller = TextEditingController(text: '123');
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _OtpPinput(controller: _controller, focusNode: _focusNode),
    );
  }
}

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
        ..group = 'Otp verification screen'
        ..name = '$name — ${preview.brightness!.name}'
        ..theme = () => PreviewThemeData(
          materialLight: AppTheme.lightTheme,
          materialDark: AppTheme.darkTheme,
        );
      return builder.build();
    }).toList();
  }
}
