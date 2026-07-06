import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_error_widget.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_headline.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_outlined_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
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
            height: heightFactor != null
                ? Get.height * heightFactor
                : null,
            child: Container(
              width: Get.width,
              padding: 20.p,
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

  static Future<T?> womatyBottomSheet<T>({
    required Widget widget,
    required String headlineText,
    void Function()? onBackPressed,
    bool isXButtonRequired = false,
    bool isHeadlineVisible = true,
    bool isDismissible = false,
  }) {
    return Get.bottomSheet<T>(
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      SafeArea(
        top: false,
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
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
                icon: const Icon(
                  LucideIcons.circleX,
                  color: Colors.white,
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

                    const SizedBox(height: 12),

                    Flexible(
                      child: widget,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

  static Future<T?> womatyOptionsCustomBottomSheet<T>({
    required Widget widget,
    double? heightFactor,
    void Function()? onBackPressed,
  }) {
    return Get.bottomSheet<T>(
      isDismissible: false,
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            children: [
              IconButton(
                onPressed: () {
                  if (onBackPressed != null) {
                    onBackPressed();
                  } else {
                    Get.back(result: null);
                  }
                },
                style: const ButtonStyle(
                  side: WidgetStatePropertyAll(
                    BorderSide(color: Colors.transparent),
                  ),
                ),
                icon: const Icon(
                  LucideIcons.circleX,
                  color: Colors.white,
                  size: 40,
                  weight: 1.5,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          SizedBox(
            height: heightFactor != null ? Get.height * heightFactor : null,
            child: Column(
              children: [
                Container(
                  width: Get.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [const SizedBox(height: 20), widget],
                  ).paddingAll(20),
                ),
                Container(
                  height: Get.context?.mediaQueryPadding.bottom,
                  color: AppColor.white,
                ),
              ],
            ),
          ),
        ],
      ),
      isScrollControlled: true,
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
                      : Image.asset(
                          assetName,
                          height: 100,
                          width: 100,
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

  static Future<T?> womatyCustomFilterBottomSheet<T>({
    required Widget widget,
    required String headlineText,
    void Function()? onBackPressed,
  }) {
    return Get.bottomSheet<T>(
      isDismissible: false,
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              if (onBackPressed != null) {
                onBackPressed();
              } else {
                Get.back(result: null);
              }
            },
            style: const ButtonStyle(
              side: WidgetStatePropertyAll(
                BorderSide(color: Colors.transparent),
              ),
            ),
            icon: const Icon(
              LucideIcons.circleX,
              color: Colors.white,
              size: 40,
              weight: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Container(
              width: Get.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        CricketHeadline(headlineText: headlineText),
                        widget,
                      ],
                    ).paddingOnly(left: 12, right: 12, top: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      isScrollControlled: true,
    );
  }

  static Future<T?> womatyCustomCityBottomSheet<T>({
    required Widget widget,
    required String headlineText,
    ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.onDrag,
  }) {
    return Get.bottomSheet<T>(
      isDismissible: false,
      isScrollControlled: true,
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // IconButton(
          //   onPressed: () {
          //     if (onBackPressed != null) {
          //       onBackPressed();
          //     } else {
          //       Get.back(result: null);
          //     }
          //   },
          //   style: const ButtonStyle(
          //     side: WidgetStatePropertyAll(
          //       BorderSide(color: Colors.transparent),
          //     ),
          //   ),
          //   icon: const Icon(
          //     LucideIcons.circleX,
          //     color: Colors.white,
          //     size: 40,
          //     weight: 1.5,
          //   ),
          // ),
          // const SizedBox(height: 16),
          Flexible(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(Get.context!).bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                top: false,
                bottom: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  keyboardDismissBehavior: keyboardDismissBehavior,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      CricketHeadline(headlineText: headlineText),
                      const SizedBox(height: 20),
                      widget, // ensure widget itself does NOT have Expanded
                    ],
                  ).paddingAll(20),
                ),
              ),
            ),
          ),
          Container(
            height: Get.context?.mediaQueryPadding.bottom,
            color: AppColor.white,
          ),
        ],
      ),
    );
  }

  static Future<T?> womatyCommonBottomSheet<T>({
    required String title,
    required String path,
    required VoidCallback onPressed,
    void Function()? onBackPressed,
  }) {
    return Get.bottomSheet<T>(
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              if (onBackPressed != null) {
                onBackPressed();
              } else {
                Get.back(result: null);
              }
            },
            style: const ButtonStyle(
              side: WidgetStatePropertyAll(
                BorderSide(color: Colors.transparent),
              ),
            ),
            icon: const Icon(
              LucideIcons.circleX,
              color: Colors.white,
              size: 40,
              weight: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          CricketErrorWidget(title: title, path: path, onPressed: onPressed),
        ],
      ),
    );
  }

  static Future<T?> womatyReportBottomSheet<T>({
    required Widget widget,
    required String headlineText,
    void Function()? onBackPressed,
  }) {
    return Get.bottomSheet<T>(
      isDismissible: false,
      isScrollControlled: true,
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              if (onBackPressed != null) {
                onBackPressed();
              } else {
                Get.back<dynamic>();
              }
            },
            style: const ButtonStyle(
              side: WidgetStatePropertyAll(
                BorderSide(color: Colors.transparent),
              ),
            ),
            icon: const Icon(
              LucideIcons.circleX,
              color: Colors.white,
              size: 40,
              weight: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Container(
              width: Get.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  CricketHeadlineWithFixedOutline(headlineText: headlineText),
                  widget,
                ],
              ).paddingAll(20),
            ),
          ),
        ],
      ),
    );
  }
}
