import 'dart:io';
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/constants/assets_util.dart';
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
    this.fallback = AssetsUtil.person,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enablePreview = false,
    this.color,
  });

  final CricketImageSource source;
  final String fallback;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enablePreview;
  final Color? color;

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
          color: color,
          errorBuilder: (context, error, stackTrace) => errorPlaceholder(),
        );
        break;

      case CricketImageType.network:
        image = CachedNetworkImage(
          imageUrl: source.path,
          width: width,
          height: height,
          fit: fit,
          color: color,
          placeholder: (_, _) =>
          const Center(child: CircularProgressIndicator()),
          errorWidget: (_, _, _) => errorPlaceholder(),
        );
        break;

      case CricketImageType.svg:
        image = SvgPicture.asset(
          source.path,
          width: width,
          height: height,
          fit: fit,
          colorFilter: ColorFilter.mode(
            color ?? Theme.of(context).colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
          placeholderBuilder: (context) => errorPlaceholder(),
        );
        break;

      case CricketImageType.file:
        image = Image.file(
          File(source.path),
          width: width,
          height: height,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) => errorPlaceholder(),
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

  Widget errorPlaceholder() {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        fallback,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}