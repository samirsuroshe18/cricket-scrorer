import 'package:cricket_scorer/core/constants/assets_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CricketLoaderDialog {
  static bool _isLoading = false;

  static void show() {
    if (_isLoading) return;
    if (!Get.isRegistered<GetMaterialController>() && Get.context == null) {
      return;
    }

    try {
      Get.closeAllSnackbars();
      _isLoading = true;

      Get.dialog<dynamic>(
        barrierDismissible: false,
        PopScope(
          canPop: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Lottie.asset(
                  AssetsUtil.appLoader,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ).then((_) {
        // Reset flag if dialog was closed by any external means
        _isLoading = false;
      });
    } catch (e) {
      _isLoading = false;
      debugPrint('CricketLoaderDialog.show() error: $e');
    }
  }

  static void hide() {
    if (!_isLoading) return;

    try {
      _isLoading = false;
      Get.closeAllSnackbars();

      if (Get.isDialogOpen ?? false) {
        Get.back<dynamic>();
      }
    } catch (e) {
      _isLoading = false;
      debugPrint('CricketLoaderDialog.hide() error: $e');

      try {
        Get.back<dynamic>(closeOverlays: true);
      } catch (_) {
        // Silently fail — nothing left to close
      }
    }
  }

  static void onBack() {
    Get.back<dynamic>();
  }
}
