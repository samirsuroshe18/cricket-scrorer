import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
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
          appBar: AppBar(
            title: const Text('Complete Profile'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                padding: 20.p,
                child: Column(
                  children: [
                    20.h,

                    /// Profile Image
                    Obx(
                      () => GestureDetector(
                        onTap: controller.pickImage,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: controller.profileImage.value != null
                              ? FileImage(
                                  controller.profileImage.value!,
                                )
                              : null,
                          child: controller.profileImage.value == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                )
                              : null,
                        ),
                      ),
                    ),

                    12.h,

                    TextButton(
                      onPressed: controller.pickImage,
                      child: const Text('Add Profile Photo'),
                    ),

                    30.h,

                    /// Username
                    CricketTextField(
                      controller: controller.usernameController,
                      hintText: 'Enter username',
                      labelText: 'Username *',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: controller.validateUsername,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                    ),

                    20.h,

                    /// Bio
                    CricketTextField(
                      controller: controller.bioController,
                      hintText: 'Tell us about yourself',
                      labelText: 'Bio',
                      prefixIcon: const Icon(Icons.person_outline),
                      maxLines: 4,
                      maxLength: 150,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                    ),

                    30.h,

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.updateProfile,
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
