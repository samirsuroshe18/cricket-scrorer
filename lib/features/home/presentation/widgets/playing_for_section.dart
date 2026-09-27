import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_entity_avatar.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_grouped_card.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_section_header.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/playing_for_teams_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The Teams tab's "Teams I play for": teams run by someone else where the
/// caller is on the roster through a linked player. Read-only, so unlike My
/// teams it has no create action. Draws nothing when the caller plays for no
/// such team, so an empty header never sits over an empty card.
class PlayingForSection extends StatelessWidget {
  const PlayingForSection({
    required this.teams,
    required this.onTap,
    super.key,
  });

  final List<PlayingForTeam> teams;

  /// Called with the tapped team's id.
  final void Function(String teamId) onTap;

  @override
  Widget build(BuildContext context) {
    if (teams.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeSectionHeader(
            title: TranslationKeys.teamsIPlayFor.tr,
            count: teams.length,
          ),
          4.h,
          CricketGroupedCard(
            children: [
              for (final team in teams)
                _PlayingForRow(team: team, onTap: () => onTap(team.id)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayingForRow extends StatelessWidget {
  const _PlayingForRow({required this.team, required this.onTap});

  final PlayingForTeam team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
                    2.h,
                    CricketText(
                      text: TranslationKeys.playingAs.trParams({
                        'player': team.myPlayerName,
                      }),
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      style: context.homeText(12, color: context.homeMuted),
                    ),
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
