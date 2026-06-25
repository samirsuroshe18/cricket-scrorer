import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'cricket_text.dart';

class CricketErrorWidget extends StatelessWidget {
  final String title;
  final String path;
  final VoidCallback? onPressed;
  final Color? color;

  const CricketErrorWidget({
    super.key,
    required this.title,
    required this.path,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Get.theme.colorScheme.surface,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(10),
        topLeft: Radius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                path,
                height: 200,
                width: 200,
              ),

              const SizedBox(height: 20),

              CricketText(
                text: title,
                style: context.textTheme.headlineMedium,
              ),

              const SizedBox(height: 24),

              CricketButton(
                buttonTextStyle: context.textTheme.headlineMedium?.copyWith(
                  color: Get.theme.colorScheme.error,
                ),
                buttonStyle: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Get.theme.colorScheme.surface,
                  ),
                  side: WidgetStatePropertyAll(
                    BorderSide(
                      color: Get.theme.colorScheme.error,
                    ),
                  ),
                ),
                buttonText: TranslationKeys.retry.tr,
                onPressed: onPressed,
              ),
            ],
          ).paddingSymmetric(
            vertical: 30,
            horizontal: 20,
          ),
    );
  }
}
