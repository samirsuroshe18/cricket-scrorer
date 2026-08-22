import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/api_client_service.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/secure_storages_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/logout_req.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/logout.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final LogoutUseCase logoutUseCase;

  HomeController({required this.logoutUseCase});

  Future<void> logout() async {
    try {
      CricketLoaderDialog.show();

      String? refreshToken = await SecureStorageService.secure.get(
        SharedPrefKey.refreshToken,
      );

      Either<CricketResponse<Map<String, dynamic>>, CricketFailure> response =
          await logoutUseCase(
            params: LogoutReq(refreshToken: refreshToken),
          );

      CricketLoaderDialog.hide();

      if (response.isResult) {
        await SharedPreferenceService.sharedPrefService.clearForLogout();
        await SecureStorageService.secure.clearForLogout();
        ApiClient.cancelAllRequests();

        unawaited(
          Get.offAllNamed(
            AppRoutes.login,
          ),
        );
        CricketSnackbar.showSuccessMessage(response.result.message);
      } else {
        CricketSnackbar.showErrorMessage(response.fallback.message);
      }
    } catch (_) {
      CricketSnackbar.showErrorMessage(
        TranslationKeys.failedToLogout.tr,
      );
    }
  }
}
