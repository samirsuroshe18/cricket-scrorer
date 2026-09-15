import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/global/widgets/language_picker_button.dart';
import 'package:cricket_scorer/core/global/widgets/theme_picker_button.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The scoreboard header: ball mark, wordmark, theme/language pickers, and
/// the accent bar — shared chrome across the auth screens (login, register,
/// forgot password, OTP verification, set password) so they read as one
/// system.
class AuthScoreboardHeader extends StatelessWidget {
  const AuthScoreboardHeader({super.key, this.trailing});

  /// Shown after the wordmark, e.g. the login screen's live indicator.
  /// Omitted on the other auth screens.
  final Widget? trailing;

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
                  ?trailing,
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
