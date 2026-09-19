import 'package:cached_network_image/cached_network_image.dart';
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One team in the Teams tab's "My Teams" row: its uploaded logo when it has
/// one, its monogram otherwise (and while the logo loads or fails to load).
/// Tapping opens the team's profile.
class TeamChip extends StatelessWidget {
  const TeamChip({required this.team, super.key});

  final TeamSummary team;

  String _monogram() {
    final words = team.name.trim().split(RegExp(r'\s+'));
    final letters = words.take(2).map((w) => w.isEmpty ? '' : w[0]).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final monogram = CricketText(
      text: _monogram(),
      style: context.textTheme.labelLarge?.copyWith(
        color: context.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
    final logoUrl = team.logoUrl;

    return InkWell(
      borderRadius: 12.radius,
      onTap: () => Get.toNamed<dynamic>(AppRoutes.teamProfilePath(team.id)),
      child: Container(
        width: 84,
        padding: 8.p,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: 12.radius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: context.colors.chipBackground,
              child: (logoUrl == null || logoUrl.isEmpty)
                  ? monogram
                  : ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: logoUrl,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Center(child: monogram),
                        errorWidget: (_, _, _) => Center(child: monogram),
                      ),
                    ),
            ),
            6.h,
            CricketText(
              text: team.shortName ?? team.name,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
