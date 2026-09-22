import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_entity_avatar.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One team in the Teams tab's "My teams" list: logo or monogram, the full
/// name, and the organization it belongs to when it has one. Tapping opens
/// the team's profile. Sits inside a `CricketGroupedCard`, which supplies the
/// surface the tap ripple paints on.
class TeamRow extends StatelessWidget {
  const TeamRow({required this.team, this.onReturn, super.key});

  final TeamSummary team;

  /// Called after returning from this team's profile screen — a rename or
  /// delete there doesn't otherwise propagate back to this row's cached
  /// list. Optional: a caller with nothing to refresh passes nothing.
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final organization = team.organization;

    return InkWell(
      onTap: () async {
        await Get.toNamed<dynamic>(AppRoutes.teamProfilePath(team.id));
        onReturn?.call();
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CricketEntityAvatar(name: team.name, logoUrl: team.logoUrl),
              12.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketText(
                      text: team.name,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      style: context.homeText(15, weight: FontWeight.w600),
                    ),
                    if (organization != null) ...[
                      2.h,
                      CricketText(
                        text: organization.name,
                        maxLines: 1,
                        textOverflow: TextOverflow.ellipsis,
                        style: context.homeText(12, color: context.homeMuted),
                      ),
                    ],
                  ],
                ),
              ),
              8.w,
              Icon(Icons.chevron_right, size: 18, color: context.homeMuted),
            ],
          ),
        ),
      ),
    );
  }
}
