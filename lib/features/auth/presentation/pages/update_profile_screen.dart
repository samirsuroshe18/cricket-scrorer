import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/data/profile_constants.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/update_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Display label per wire value. Kept beside the screen rather than on
/// [BattingStyle]/[BowlingStyle], which hold wire values only and must not
/// carry UI strings — same split as `wicket_bottom_sheet.dart`'s
/// `_wicketLabels`.
const Map<String, String> _battingStyleLabels = <String, String>{
  BattingStyle.rightHanded: TranslationKeys.rightHanded,
  BattingStyle.leftHanded: TranslationKeys.leftHanded,
};

const Map<String, String> _bowlingStyleLabels = <String, String>{
  BowlingStyle.rightArmPace: TranslationKeys.rightArmPace,
  BowlingStyle.leftArmPace: TranslationKeys.leftArmPace,
  BowlingStyle.rightArmSpin: TranslationKeys.rightArmSpin,
  BowlingStyle.leftArmSpin: TranslationKeys.leftArmSpin,
};

class UpdateProfileScreen extends GetView<UpdateProfileController> {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            (controller.isEditing
                    ? TranslationKeys.myProfile
                    : TranslationKeys.completeProfile)
                .tr,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingProfile.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return _UpdateProfileForm(controller: controller);
      }),
    );
  }
}

class _UpdateProfileForm extends StatelessWidget {
  const _UpdateProfileForm({required this.controller});

  final UpdateProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: 20.p,
        child: Column(
          children: [
            20.h,

            /// Profile Image
            Obx(() {
              final localFile = controller.selectedImage.value;
              final networkUrl = controller.existingPhotoUrl.value;
              final source = localFile != null
                  ? CricketImageSource.file(localFile.path)
                  : (networkUrl != null && networkUrl.isNotEmpty)
                  ? CricketImageSource.network(networkUrl)
                  : const CricketImageSource.file('');
              return CricketImage(
                source: source,
                height: 120,
                width: 120,
                borderRadius: const BorderRadius.all(Radius.circular(180)),
              );
            }),

            TextButton(
              onPressed: controller.pickImageBottomSheet,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: CricketText(text: TranslationKeys.addProfilePhoto.tr),
            ),

            30.h,

            /// Username
            CricketTextField(
              controller: controller.usernameController,
              hintText: TranslationKeys.enterUsername.tr,
              labelText: TranslationKeys.username.tr,
              prefixIcon: const Icon(Icons.person_outline),
              validator: controller.validateUsername,
              keyboardType: TextInputType.name,
              isRequired: true,
            ),

            20.h,

            /// Bio
            CricketTextField(
              controller: controller.bioController,
              hintText: TranslationKeys.tellUsAboutYourself.tr,
              labelText: TranslationKeys.bio.tr,
              prefixIcon: const Icon(Icons.person_outline),
              maxLines: 4,
              maxLength: 150,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
            ),

            20.h,

            /// Batting style
            Align(
              alignment: Alignment.centerLeft,
              child: _Label(text: TranslationKeys.battingStyle.tr),
            ),
            8.h,
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BattingStyle.all.map((String style) {
                  return ChoiceChip(
                    label: CricketText(text: _battingStyleLabels[style]!.tr),
                    selected: controller.battingStyle.value == style,
                    onSelected: (_) => controller.toggleBattingStyle(style),
                  );
                }).toList(),
              ),
            ),

            20.h,

            /// Bowling style
            Align(
              alignment: Alignment.centerLeft,
              child: _Label(text: TranslationKeys.bowlingStyle.tr),
            ),
            8.h,
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BowlingStyle.all.map((String style) {
                  return ChoiceChip(
                    label: CricketText(text: _bowlingStyleLabels[style]!.tr),
                    selected: controller.bowlingStyle.value == style,
                    onSelected: (_) => controller.toggleBowlingStyle(style),
                  );
                }).toList(),
              ),
            ),

            30.h,

            CricketButton(
              onPressed: controller.updateProfile,
              buttonText:
                  (controller.isEditing
                          ? TranslationKeys.saveChanges
                          : TranslationKeys.continueText)
                      .tr,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return CricketText(text: text, style: context.textTheme.titleSmall);
  }
}
