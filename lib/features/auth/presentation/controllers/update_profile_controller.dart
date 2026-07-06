import 'dart:async';
import 'dart:io';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/error_string_constants.dart';
import 'package:cricket_scorer/core/error/cricket_failure.dart';
import 'package:cricket_scorer/core/extensions/string_extension.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/wigets/choose_photo_option.dart';
import 'package:cricket_scorer/core/global/widgets/dialogue/custom_dialog.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/network/models/cricket_response.dart';
import 'package:cricket_scorer/core/services/compression_service.dart';
import 'package:cricket_scorer/core/utils/either_util.dart';
import 'package:cricket_scorer/features/auth/data/models/request/update_profile_req.dart';
import 'package:cricket_scorer/features/auth/domain/usecases/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileController extends GetxController {
  final UpdateProfileUseCase updateProfileUseCase;

  UpdateProfileController({required this.updateProfileUseCase});

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();

  final selectedImage = Rx<File?>(null);
  final isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

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
      CricketSnackbar.showErrorMessage(ErrorStringConstants.somethingWentWrong.tr);
      return null;
    }
  }

  Future<void> compressImage(XFile image) async {
    CricketLoaderDialog.show();
    Either<File, CricketFailure> response = await Get.find<CompressionService>().imageCompression(
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
      headlineText: 'Add Profile Photo'.translation(),
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

    Either<CricketResponse<void>, CricketFailure> response =
        await updateProfileUseCase(
          params: UpdateProfileReq(
            userName: usernameController.text,
            bio: bioController.text,
          ),
          file: selectedImage.value,
        );

    CricketLoaderDialog.hide();

    if (response.isResult) {
      CricketSnackbar.showSuccessMessage(response.result.message);
      unawaited(Get.offAllNamed(AppRoutes.home));
    } else {
      CricketSnackbar.showErrorMessage(response.fallback.message);
    }
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }

    return null;
  }

  @override
  void onClose() {
    usernameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
