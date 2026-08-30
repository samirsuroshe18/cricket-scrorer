import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_headline.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_outlined_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomBottomSheet {
  const CustomBottomSheet._();

  static Future<T?> cricketCustomBottomSheet<T>({
    required Widget child,
    required String headlineText,
    bool isXButtonRequired = true,
    double? heightFactor = 0.75,
    bool isDismissible = false,
    VoidCallback? onBackPressed,
  }) {
    final context = Get.context;

    return Get.bottomSheet<T>(
      isDismissible: isDismissible,
      isScrollControlled: true,
      enableDrag: false,
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isXButtonRequired)
            IconButton(
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed();
                } else {
                  Get.back(result: null);
                }
              },
              style: IconButton.styleFrom(
                side: BorderSide.none,
              ),
              icon: Icon(
                LucideIcons.circleX,
                color: Get.theme.colorScheme.onPrimary,
                size: 40,
                weight: 1.5,
              ),
            ),
          20.h,

          SizedBox(
            height: heightFactor != null ? Get.height * heightFactor : null,
            child: Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: context?.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),

              child: Column(
                children: [
                  20.h,
                  CricketHeadlineWithFixedOutline(
                    headlineText: headlineText,
                  ),

                  Expanded(child: child),
                ],
              ).paddingAll(20),
            ),
          ),
          20.h,
        ],
      ),
    );
  }

  static Future<T?> wrapBottomSheet<T>({
    required Widget child,
    required String headlineText,
    bool isXButtonRequired = true,
    bool isHeadlineVisible = true,
    bool isDismissible = false,
    VoidCallback? onBackPressed,
  }) {
    return Get.bottomSheet<T>(
      isDismissible: isDismissible,
      isScrollControlled: true,
      enableDrag: false,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isXButtonRequired)
            IconButton(
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed();
                } else {
                  Get.back(result: null);
                }
              },
              style: IconButton.styleFrom(
                side: BorderSide.none,
              ),
              icon: Icon(
                LucideIcons.circleX,
                color: Get.theme.colorScheme.onPrimary,
                size: 40,
                weight: 1.5,
              ),
            ),

          20.h,

          Flexible(
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  20.h,
                  if (isHeadlineVisible) ...[
                    CricketHeadlineWithFixedOutline(
                      headlineText: headlineText,
                    ),
                  ] else ...[
                    Container(
                      height: 4,
                      width: 65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Get.theme.colorScheme.outline.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                  ],

                  Flexible(
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<T?> warningBottomSheet<T>({
    required String title,
    required String message,
    required String confirmButtonName,
    String? cancelButtonName,
    String? assetName,
    Color confirmButtonColor = AppColor.primaryRed,
    bool hideCancelButton = false,
    bool isDismissible = true,
  }) {
    return Get.bottomSheet<T>(
      SafeArea(
        bottom: false,
        child: PopScope(
          canPop: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),

                if (assetName != null && assetName.isNotEmpty) ...[
                  assetName.endsWith('.json')
                      ? Lottie.asset(
                          assetName,
                          height: 100,
                          width: 100,
                        )
                      : CricketImage(
                          source: CricketImageSource.asset(assetName),
                          height: 100,
                          width: 100,
                          fit: BoxFit.scaleDown,
                          color: Get.theme.colorScheme.onSurface,
                        ),
                  const SizedBox(height: 24),
                ],

                CricketText(
                  text: title,
                  style: Get.context?.textTheme.displayMedium,
                ),

                const SizedBox(height: 8),

                CricketText(
                  text: message,
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  style: Get.context?.textTheme.headlineSmall,
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  spacing: 14,
                  children: [
                    if (!hideCancelButton)
                      Expanded(
                        child: CricketOutlinedButton(
                          buttonName:
                              cancelButtonName ?? TranslationKeys.cancel.tr,
                          onPressed: () => Get.back(result: false),
                        ),
                      ),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        onPressed: () => Get.back(result: true),
                        child: CricketText(
                          text: confirmButtonName,
                          style: Get.context?.textTheme.titleLarge?.copyWith(
                            color: Get.theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  height: 20 + Get.mediaQuery.viewPadding.bottom,
                  color: Get.theme.colorScheme.surface,
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
    );
  }
}
