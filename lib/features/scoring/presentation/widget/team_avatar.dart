import 'package:cached_network_image/cached_network_image.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A team-colored circle: the team's uploaded logo when it has one, its
/// derived initials otherwise (and while the logo loads or fails to load). The
/// team name next to it already reads out the full name, so this is excluded
/// from the semantics tree rather than announced twice.
class TeamAvatar extends StatelessWidget {
  const TeamAvatar({
    required this.name,
    required this.color,
    this.logoUrl,
    this.radius = 12,
    super.key,
  });

  final String name;
  final Color color;
  final String? logoUrl;
  final double radius;

  String get _initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length > 1 ? 2 : 1)
          .toUpperCase();
    }
    return (words.first[0] + words.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = CricketText(
      text: _initials,
      style: context.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
      ),
    );
    final url = logoUrl;

    return ExcludeSemantics(
      child: CircleAvatar(
        radius: radius,
        backgroundColor: color.withValues(alpha: 0.16),
        child: (url == null || url.isEmpty)
            ? initials
            : ClipOval(
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => initials,
                  errorWidget: (_, _, _) => initials,
                ),
              ),
      ),
    );
  }
}
