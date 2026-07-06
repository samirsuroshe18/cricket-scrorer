import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/string_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChoosePhotoOption extends StatelessWidget {
  const ChoosePhotoOption({
    super.key,
    this.onCameraCallback,
    this.onGalleryCallback,
  });

  final dynamic Function()? onCameraCallback, onGalleryCallback;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          32.h,
          CricketButton(
            onPressed: onCameraCallback,
            buttonText: 'Camera'.translation(),
            prefixIcon: const Icon(
              LucideIcons.camera,
            ),
          ),
          20.h,
          CricketButton(
            onPressed: onGalleryCallback,
            buttonText: 'Gallery'.translation(),
            prefixIcon: const Icon(
              LucideIcons.image,
            ),
          ),
          32.h,
        ],
      ),
    );
  }
}
