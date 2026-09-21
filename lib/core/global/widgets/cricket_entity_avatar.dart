import 'package:cached_network_image/cached_network_image.dart';
import 'package:cricket_scorer/core/constants/app_color.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A team's or organization's uploaded logo, or its monogram (the initials of
/// the first two words of its name) when it has none — and while the logo
/// loads or fails to load. Decorative: the name always sits beside it.
///
/// The monogram is red text on the chip fill. The brand red alone is 2.6:1
/// there in dark mode, so dark mode uses the lighter red (4.7:1).
class CricketEntityAvatar extends StatelessWidget {
  const CricketEntityAvatar({
    required this.name,
    this.logoUrl,
    this.size = 44,
    super.key,
  });

  final String name;
  final String? logoUrl;
  final double size;

  String _monogram() {
    final words = name.trim().split(RegExp(r'\s+'));
    final letters = words.take(2).map((w) => w.isEmpty ? '' : w[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final monogram = CricketText(
      text: _monogram(),
      style: context.textTheme.titleSmall?.copyWith(
        color: context.isDark ? AppColor.softRed : context.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
    final url = logoUrl;

    return ExcludeSemantics(
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: context.colors.chipBackground,
        child: (url == null || url.isEmpty)
            ? monogram
            : ClipOval(
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Center(child: monogram),
                  errorWidget: (_, _, _) => Center(child: monogram),
                ),
              ),
      ),
    );
  }
}
