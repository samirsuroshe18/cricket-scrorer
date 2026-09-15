import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/auth_scoreboard_header.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/otp_verification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:get/get.dart';

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
                          // TEMP DEBUG: autofillHints removed entirely to
                          // test whether iOS groups these by pattern alone.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              6,
                              (index) => _OtpBox(
                                controller: controller.otpControllers[index],
                                focusNode: controller.focusNodes[index],
                                onChanged: (value) =>
                                    controller.onOtpChanged(value, index),
                                autofillHints: null,
                                semanticLabel: TranslationKeys.otpDigitLabel
                                    .trParams({'position': '${index + 1}'}),
                              ),
                            ),
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

/// A single digit box. The border animates between [ColorScheme.outline]
/// and [ColorScheme.primary] as focus moves across the row.
class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.semanticLabel,
    this.autofillHints,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final String semanticLabel;
  final List<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
        // TEMP DEBUG: plain Container (no animation) to test whether
        // AnimatedContainer's decoration tween is causing the ghost border.
        return Container(
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: 12.radius,
            border: Border.all(
              color: isFocused ? scheme.primary : scheme.outline,
              width: isFocused ? 2 : 1,
            ),
          ),
          child: child,
        );
      },
      child: Semantics(
        label: semanticLabel,
        textField: true,
        // Caps scaling for this single boxed glyph at 200% (WCAG 1.4.4's
        // required minimum) so iOS's larger accessibility sizes (up to
        // ~3.1x) can't clip it against the fixed 48x56 box — the rest of
        // the screen keeps the device's full text-scale setting.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 2,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            // TEMP DEBUG: was TextInputType.number — testing whether the
            // numeric keypad is what triggers iOS's verification-code UI.
            keyboardType: TextInputType.visiblePassword,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofillHints: autofillHints,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) return '';
              return null;
            },
          ),
        ),
      ),
    );
  }
}

// Preview-only below. The full screen isn't previewable in isolation —
// ThemePickerButton/LanguagePickerButton resolve ThemeService/LanguageService
// via Get.find(), which cascade into SharedPreferences and repository
// dependencies the isolated Widget Previewer can't satisfy. The pin-box row
// is the screen's one interactive/functional addition, so it's previewed on
// its own with local controllers instead.

@_MultiPreviewBrightness(name: 'OTP boxes')
Widget otpBoxesPreview() => const ColoredBox(
  color: Colors.black12,
  child: Center(child: _OtpBoxRowPreview()),
);

class _OtpBoxRowPreview extends StatefulWidget {
  const _OtpBoxRowPreview();

  @override
  State<_OtpBoxRowPreview> createState() => _OtpBoxRowPreviewState();
}

class _OtpBoxRowPreviewState extends State<_OtpBoxRowPreview> {
  late final List<TextEditingController> _controllers = List.generate(
    6,
    (i) => TextEditingController(text: i < 3 ? '${i + 1}' : ''),
  );
  late final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AutofillGroup(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _OtpBox(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                onChanged: (_) {},
                semanticLabel: 'Digit ${index + 1} of 6',
              ),
            ),
          ),
        ),
      ),
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
