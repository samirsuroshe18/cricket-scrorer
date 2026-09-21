import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// What a tab shows when its open search matches nothing: one line saying so
/// and a way back to the full list. The caller supplies the sentence, since
/// what "nothing" means differs per tab (matches, or teams and
/// organizations).
class HomeSearchEmptyState extends StatelessWidget {
  const HomeSearchEmptyState({
    required this.message,
    required this.onClear,
    super.key,
  });

  final String message;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 24.p,
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: context.colorScheme.onSurfaceVariant,
          ),
          16.h,
          CricketText(
            text: message,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          8.h,
          TextButton(
            onPressed: onClear,
            child: CricketText(
              text: TranslationKeys.clearSearch.tr,
              style: context
                  .homeText(14, weight: FontWeight.w600)
                  .copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }
}
