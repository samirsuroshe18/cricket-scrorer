import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:cricket_scorer/core/constants/error_string_constants.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CricketSnackbar {
  CricketSnackbar._();

  // Helper method to dynamically switch colors based on theme mode
  static Color _getThemeColor({required Color light, required Color dark}) {
    return Get.isDarkMode ? dark : light;
  }

  static void showSuccessMessage(
    String? message, {
    String title = 'Success',
    Duration snackDuration = const Duration(seconds: 3),
  }) {
    final successColor = _getThemeColor(
      light: AppColor.lightSuccess,
      dark: AppColor.darkSuccess,
    );
    final bgColor = _getThemeColor(
      light: AppColor.lightCard,
      dark: AppColor.darkCardBg,
    );
    final textColor = _getThemeColor(
      light: AppColor.lightTextSecondary,
      dark: AppColor.darkTextMuted,
    );

    Get.showSnackbar(
      GetSnackBar(
        borderRadius: 12,
        backgroundColor: bgColor,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        boxShadows: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
        padding: EdgeInsets.zero,
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        duration: snackDuration,
        animationDuration: const Duration(milliseconds: 500),
        messageText: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                SizedBox(
                  width: 3,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 3,
                        height: 40,
                        decoration: BoxDecoration(
                          color: successColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: snackDuration,
                        builder: (context, value, child) {
                          return Container(
                            width: 3,
                            height: 40 * value,
                            decoration: BoxDecoration(
                              color: successColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: successColor.withValues(alpha: 0.05),
                  ),
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Icon(LucideIcons.circleCheckBig, color: successColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CricketText(
                        text: title,
                        style: Get.context!.textTheme.titleMedium?.copyWith(
                          color: successColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CricketText(
                        text: message ?? 'Success',
                        style: Get.context!.textTheme.labelSmall?.copyWith(
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).marginAll(12),
          ],
        ),
      ),
    );
  }

  static void showErrorMessage(
    String? message, {
    String title = 'Error Occurred',
    Duration snackDuration = const Duration(seconds: 3),
  }) {
    final errorColor = _getThemeColor(
      light: AppColor.lightRedDark,
      dark: AppColor.darkError,
    );
    final bgColor = _getThemeColor(
      light: AppColor.lightCard,
      dark: AppColor.darkCardBg,
    );
    final textColor = _getThemeColor(
      light: AppColor.lightTextSecondary,
      dark: AppColor.darkTextMuted,
    );

    Get.showSnackbar(
      GetSnackBar(
        borderRadius: 12,
        backgroundColor: bgColor,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        boxShadows: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
        padding: EdgeInsets.zero,
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        duration: snackDuration,
        animationDuration: const Duration(milliseconds: 500),
        messageText: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                SizedBox(
                  width: 3,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 3,
                        height: 40,
                        decoration: BoxDecoration(
                          color: errorColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: snackDuration,
                        builder: (context, value, child) {
                          return Container(
                            width: 3,
                            height: 40 * value,
                            decoration: BoxDecoration(
                              color: errorColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: errorColor.withValues(alpha: 0.05),
                  ),
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Icon(LucideIcons.circleX, color: errorColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CricketText(
                        text: title,
                        style: Get.context!.textTheme.titleMedium?.copyWith(
                          color: errorColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CricketText(
                        text:
                            message ??
                            ErrorStringConstants.genericErrorMessage.tr,
                        style: Get.context!.textTheme.labelSmall?.copyWith(
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).marginAll(12),
          ],
        ),
      ),
    );
  }

  static void showAlertMessage(
    String? message, {
    String? title,
    Duration snackDuration = const Duration(seconds: 3),
  }) {
    final warningColor = _getThemeColor(
      light: AppColor.lightWarning,
      dark: AppColor.darkWarning,
    );
    final bgColor = _getThemeColor(
      light: AppColor.lightCard,
      dark: AppColor.darkCardBg,
    );
    final textColor = _getThemeColor(
      light: AppColor.lightTextSecondary,
      dark: AppColor.darkTextMuted,
    );

    Get.showSnackbar(
      GetSnackBar(
        borderRadius: 12,
        backgroundColor: bgColor,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        boxShadows: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
        padding: EdgeInsets.zero,
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        duration: snackDuration,
        animationDuration: const Duration(milliseconds: 500),
        messageText: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                SizedBox(
                  width: 3,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 3,
                        height: 40,
                        decoration: BoxDecoration(
                          color: warningColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: snackDuration,
                        builder: (context, value, child) {
                          return Container(
                            width: 3,
                            height: 40 * value,
                            decoration: BoxDecoration(
                              color: warningColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: warningColor.withValues(alpha: 0.05),
                  ),
                  padding: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Icon(LucideIcons.circleAlert, color: warningColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CricketText(
                        text: title ?? 'Alert',
                        style: Get.context!.textTheme.titleMedium?.copyWith(
                          color: warningColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CricketText(
                        text:
                            message ??
                            ErrorStringConstants.genericAlertMessage.tr,
                        style: Get.context!.textTheme.labelSmall?.copyWith(
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).marginAll(12),
          ],
        ),
      ),
    );
  }
}
