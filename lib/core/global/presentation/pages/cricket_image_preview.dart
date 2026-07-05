import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cricket_scorer/core/enums/cricket_image_type.dart';
import 'package:cricket_scorer/core/global/presentation/controllers/image_preview_controller.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CricketImagePreview extends StatelessWidget {
  const CricketImagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: GetBuilder<ImagePreviewController>(
        builder: (controller) {
          switch (controller.source.type) {
            case CricketImageType.network:
              return imagePreview(
                child: CachedNetworkImage(
                  imageUrl: controller.source.path,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => loader(),
                  errorWidget: (context, url, error) => errorPlaceholder(),
                ),
              );
            case CricketImageType.asset:
              return imagePreview(
                child: Image.asset(
                  controller.source.path,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => errorPlaceholder(),
                ),
              );
            case CricketImageType.svg:
              return imagePreview(child: SvgPicture.asset(
                controller.source.path,
                fit: BoxFit.contain,
                placeholderBuilder: (context) => loader(),
              ));
            case CricketImageType.file:
              final file = File(controller.source.path);
              if (!file.existsSync()) return errorPlaceholder();
              return imagePreview(
                child: Image.file(
                  File(controller.source.path),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => errorPlaceholder(),
                ),
              );
          }
        },
      ),
    );
  }

  Widget imagePreview({required Widget child}) {
    return Center(
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        clipBehavior: Clip.none,
        child: child,
      ),
    );
  }

  Widget loader() {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget errorPlaceholder() {
    return const Center(
      child: Icon(Icons.broken_image_outlined, size: 40),
    );
  }
}