import 'dart:io';
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/enums/cricket_image_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import 'cricket_image_source.dart';

class CricketImage extends StatelessWidget {
  const CricketImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enablePreview = false,
  });

  final CricketImageSource source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enablePreview;

  @override
  Widget build(BuildContext context) {
    Widget image;

    switch (source.type) {
      case CricketImageType.asset:
        image = Image.asset(
          source.path,
          width: width,
          height: height,
          fit: fit,
        );
        break;

      case CricketImageType.network:
        image = CachedNetworkImage(
          imageUrl: source.path,
          width: width,
          height: height,
          fit: fit,
          placeholder: (_, _) =>
          const Center(child: CircularProgressIndicator()),
          errorWidget: (_, _, _) => const Icon(Icons.broken_image),
        );
        break;

      case CricketImageType.svg:
        image = SvgPicture.asset(
          source.path,
          width: width,
          height: height,
          fit: fit,
        );
        break;

      case CricketImageType.file:
        image = Image.file(
          File(source.path),
          width: width,
          height: height,
          fit: fit,
        );
        break;
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: enablePreview
          ? GestureDetector(
        onTap: () => Get.toNamed<dynamic>(
          AppRoutes.imagePreview,
          arguments: source,
        ),
        child: image,
      )
          : image,
    );
  }
}