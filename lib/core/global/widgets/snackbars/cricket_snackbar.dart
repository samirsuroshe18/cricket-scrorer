import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:cricket_scorer/core/constants/error_string_constants.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CricketSnackbar {
  CricketSnackbar._();

  static void showSuccessMessage(
    String? message, {
    String title = 'Success',
    Duration snackDuration = const Duration(seconds: 3),
  }) {
    final context = Get.theme;

    final successColor = Get.context?.colors.scorePositive ?? AppColor.white;
    final bgColor = context.colorScheme.surface;
    final textColor = context.colorScheme.onSurfaceVariant;

    Get.showSnackbar(
      GetSnackBar(
        borderRadius: 12,
        backgroundColor: bgColor,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        boxShadows: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
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
                        style: Get.textTheme.titleMedium?.copyWith(
                          color: successColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CricketText(
                        text: message ?? 'Success',
                        style: Get.textTheme.labelSmall?.copyWith(
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
    final context = Get.theme;

    final errorColor = Get.context?.colors.scoreNegative ?? AppColor.white;
    final bgColor = context.colorScheme.surface;
    final textColor = context.colorScheme.onSurfaceVariant;

    Get.showSnackbar(
      GetSnackBar(
        borderRadius: 12,
        backgroundColor: bgColor,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        boxShadows: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
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
                        style: context.textTheme.titleMedium?.copyWith(
                          color: errorColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CricketText(
                        text:
                            message ??
                            ErrorStringConstants.genericErrorMessage.tr,
                        style: context.textTheme.labelSmall?.copyWith(
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
    final context = Get.theme;

    final warningColor = context.colorScheme.tertiary;
    final bgColor = context.colorScheme.surface;
    final textColor = context.colorScheme.onSurfaceVariant;

    Get.showSnackbar(
      GetSnackBar(
        borderRadius: 12,
        backgroundColor: bgColor,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        boxShadows: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
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
                        style: context.textTheme.titleMedium?.copyWith(
                          color: warningColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CricketText(
                        text:
                            message ??
                            ErrorStringConstants.genericAlertMessage.tr,
                        style: context.textTheme.labelSmall?.copyWith(
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
