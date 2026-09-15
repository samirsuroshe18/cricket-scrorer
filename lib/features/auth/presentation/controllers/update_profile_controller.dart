import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/shared_pref_key.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/wigets/choose_photo_option.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/compression_service.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/update_profile_req.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/get_user.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileController extends GetxController {
  final UpdateProfileUseCase updateProfileUseCase;
  final GetUserUseCase getUserUseCase;

  UpdateProfileController({
    required this.updateProfileUseCase,
    required this.getUserUseCase,
  });

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final jerseyNumberController = TextEditingController();

  final selectedImage = Rx<File?>(null);
  final existingPhotoUrl = Rx<String?>(null);

  // All optional, no default — mirrors the backend contract exactly.
  final battingStyle = Rx<String?>(null);
  final bowlingStyle = Rx<String?>(null);
  final playingRole = Rx<String?>(null);

  void toggleBattingStyle(String style) =>
      battingStyle.value = battingStyle.value == style ? null : style;

  void toggleBowlingStyle(String style) =>
      bowlingStyle.value = bowlingStyle.value == style ? null : style;

  void togglePlayingRole(String role) =>
      playingRole.value = playingRole.value == role ? null : role;

  // Set once from the route arguments the home screen's Profile entry point
  // passes; the three onboarding call sites (login/splash/onboarding
  // controllers) navigate with no arguments, so this stays false there and
  // the screen renders exactly as it did before this field existed.
  late final bool isEditing;
  final isLoadingProfile = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    isEditing = (Get.arguments as Map?)?['isEditing'] == true;
    if (isEditing) {
      unawaited(_loadExistingProfile());
    }
  }

  Future<void> _loadExistingProfile() async {
    isLoadingProfile.value = true;
    final response = await getUserUseCase();
    if (response.isResult) {
      final user = response.result.data;
      usernameController.text = user?.userName ?? '';
      bioController.text = user?.bio ?? '';
      battingStyle.value = user?.battingStyle;
      bowlingStyle.value = user?.bowlingStyle;
      playingRole.value = user?.playingRole;
      jerseyNumberController.text = user?.jerseyNumber?.toString() ?? '';
      existingPhotoUrl.value = user?.photoUrl;
    }
    isLoadingProfile.value = false;
  }

  Future<XFile?> pickImage({
    required ImageSource imageSource,
  }) async {
    try {
      return await _picker.pickImage(
        source: imageSource,
        requestFullMetadata: true,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 100,
      );
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrintStack(stackTrace: stackTrace);
      CricketSnackbar.showErrorMessage(TranslationKeys.somethingWentWrong.tr);
      return null;
    }
  }

  Future<void> compressImage(XFile image) async {
    CricketLoaderDialog.show();
    Either<File, CricketFailure> response = await Get.find<CompressionService>()
        .imageCompression(
          inputPath: image.path,
        );
    CricketLoaderDialog.hide();
    if (response.isResult) {
      selectedImage.value = response.result;
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  void pickImageBottomSheet() async {
    await CustomBottomSheet.wrapBottomSheet<dynamic>(
      headlineText: TranslationKeys.addProfilePhoto.tr,
      child: ChoosePhotoOption(
        onCameraCallback: () async {
          Get.back<dynamic>();
          XFile? value = await pickImage(imageSource: ImageSource.camera);
          if (value != null) {
            unawaited(compressImage(value));
          }
        },
        onGalleryCallback: () async {
          Get.back<dynamic>();
          XFile? value = await pickImage(imageSource: ImageSource.gallery);
          if (value != null) {
            unawaited(compressImage(value));
          }
        },
      ),
    );
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    CricketLoaderDialog.show();

    final jerseyNumberText = jerseyNumberController.text.trim();

    Either<CricketResponse<void>, CricketFailure> response =
        await updateProfileUseCase(
          params: UpdateProfileReq(
            userName: usernameController.text,
            bio: bioController.text,
            battingStyle: battingStyle.value,
            bowlingStyle: bowlingStyle.value,
            playingRole: playingRole.value,
            jerseyNumber: jerseyNumberText.isEmpty
                ? null
                : int.tryParse(jerseyNumberText),
          ),
          file: selectedImage.value,
        );

    if (response.isResult) {
      // The save call itself returns no user data — refreshing the locally
      // cached profile here (the same cache `login_controller.dart` first
      // writes) is what lets the Home app bar's avatar/name reflect this
      // save immediately, instead of showing whatever login last cached.
      await _refreshCachedProfile();
    }

    CricketLoaderDialog.hide();

    if (response.isResult) {
      CricketSnackbar.showSuccessMessage(response.result.message);
      unawaited(Get.offAllNamed(AppRoutes.home));
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  Future<void> _refreshCachedProfile() async {
    final response = await getUserUseCase();
    if (response.isResult) {
      await SharedPreferenceService.sharedPrefService.set(
        SharedPrefKey.userDetails,
        jsonEncode(response.result.data?.toJson()),
      );
    }
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.usernameRequired.tr;
    }

    if (value.trim().length < 3) {
      return TranslationKeys.usernameTooShort.tr;
    }

    return null;
  }

  String? validateJerseyNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final number = int.tryParse(value.trim());
    if (number == null || number < 0 || number > 999) {
      return TranslationKeys.jerseyNumberInvalid.tr;
    }

    return null;
  }

  @override
  void onClose() {
    usernameController.dispose();
    bioController.dispose();
    jerseyNumberController.dispose();
    super.onClose();
  }
}
