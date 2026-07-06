import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/string_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image.dart';
import 'package:cricket_scorer/core/global/widgets/images/cricket_image_source.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/update_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateProfileController>(
      builder: (UpdateProfileController controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Complete Profile'.translation(),
            centerTitle: true,
          ),
          body: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              padding: 20.p,
              child: Column(
                children: [
                  20.h,
                  /// Profile Image
                  Obx(()=>CricketImage(
                    source: CricketImageSource.file(
                      controller.selectedImage.value?.path ?? '',
                    ),
                    height: 120,
                    width: 120,
                    borderRadius: const BorderRadius.all(Radius.circular(180)),
                  )),

                  TextButton(
                    onPressed: controller.pickImageBottomSheet,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: CricketText(text: 'Add Profile Photo'.translation()),
                  ),

                  30.h,

                  /// Username
                  CricketTextField(
                    controller: controller.usernameController,
                    hintText: 'Enter username'.translation(),
                    labelText: 'Username'.translation(),
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: controller.validateUsername,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    isRequired: true,
                  ),

                  20.h,

                  /// Bio
                  CricketTextField(
                    controller: controller.bioController,
                    hintText: 'Tell us about yourself'.translation(),
                    labelText: 'Bio'.translation(),
                    prefixIcon: const Icon(Icons.person_outline),
                    maxLines: 4,
                    maxLength: 150,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                  ),

                  30.h,

                  CricketButton(
                    onPressed: controller.updateProfile,
                    buttonText: 'Continue'.translation(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
