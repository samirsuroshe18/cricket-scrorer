import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Section title with an optional "See all". Replaces
/// `DashboardSectionHeader`, whose 14px title and `TextButton` padding read
/// heavier than the spec — this one is a 15px title and a 12px muted link
/// that still gets a full 44px-tall tap area.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({required this.title, this.onSeeAll, super.key});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: CricketText(
              text: title,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              style: context.homeText(15, weight: FontWeight.w600),
            ),
          ),
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: CricketText(
                    text: TranslationKeys.seeAll.tr,
                    style: context.homeText(12, color: context.homeMuted),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
