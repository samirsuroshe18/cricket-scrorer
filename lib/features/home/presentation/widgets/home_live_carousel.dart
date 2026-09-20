import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/utils/home_match_view.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';

/// Other live matches as a sideways row of compact cards, so "what's on right
/// now" takes one row of the screen however many there are.
class HomeLiveCarousel extends StatelessWidget {
  const HomeLiveCarousel({
    required this.items,
    required this.onOpen,
    required this.onShare,
    required this.onMore,
    super.key,
  });

  final List<MatchHistoryItem> items;
  final ValueChanged<MatchHistoryItem> onOpen;
  final ValueChanged<MatchHistoryItem> onShare;
  final ValueChanged<MatchHistoryItem> onMore;

  @override
  Widget build(BuildContext context) {
    // A Row inside an IntrinsicHeight, not a ListView: the cards' height comes
    // from their content (so larger text sizes grow the row instead of
    // clipping), and a page never holds more than a handful of live matches.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) 10.w,
              SizedBox(
                width: 230,
                child: HomeLiveCard(
                  item: items[i],
                  onTap: () => onOpen(items[i]),
                  onShare: () => onShare(items[i]),
                  onMore: () => onMore(items[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeLiveCard extends StatelessWidget {
  const HomeLiveCard({
    required this.item,
    required this.onTap,
    required this.onShare,
    required this.onMore,
    super.key,
  });

  final MatchHistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onMore;

  String _tag() {
    if (item.status == 'innings_break') {
      return TranslationKeys.statusInningsBreak.tr.toUpperCase();
    }
    final tag = item.totalOvers == 1
        ? TranslationKeys.homeLiveTagOne.tr
        : TranslationKeys.homeLiveTag.trParams({'n': '${item.totalOvers}'});
    return tag.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final innings = item.currentInnings;
    final batting = battingTeamName(item) ?? item.teamA.name;
    final other = bowlingTeamName(item) ?? item.teamB.name;
    final isBreak = item.status == 'innings_break';
    final muted = context.homeMuted;

    final score = innings == null
        ? null
        : '${innings.totalRuns}/${innings.wickets}';
    final overs = (innings == null || isBreak) ? null : '(${innings.overs})';

    final otherSub = isBreak
        ? (innings == null
              ? null
              : TranslationKeys.homeTarget.trParams({
                  'n': '${innings.totalRuns + 1}',
                }))
        : (innings?.target != null
              ? TranslationKeys.homeTarget.trParams({'n': '${innings!.target}'})
              : TranslationKeys.homeYetToBat.tr);

    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: TranslationKeys.matchActions.tr): onMore,
      },
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: context.homeCardDecoration(radius: 14),
          child: InkWell(
            onTap: onTap,
            onLongPress: onMore,
            borderRadius: 14.radius,
            child: ClipRRect(
              borderRadius: 14.radius,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 3, color: context.colorScheme.primary),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 4, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CricketText(
                              text: _tag(),
                              maxLines: 1,
                              textOverflow: TextOverflow.ellipsis,
                              style: context.homeText(
                                11,
                                weight: FontWeight.w600,
                                color: context.homeLiveText,
                              ),
                            ),
                            8.h,
                            _Row(
                              name: batting,
                              trailing: score == null
                                  ? null
                                  : Text.rich(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      TextSpan(
                                        text: score,
                                        children: [
                                          if (overs != null)
                                            TextSpan(
                                              text: ' $overs',
                                              style: context.homeText(
                                                14,
                                                color: muted,
                                                tabular: true,
                                              ),
                                            ),
                                        ],
                                      ),
                                      style: context.homeText(
                                        14,
                                        weight: FontWeight.w600,
                                        tabular: true,
                                      ),
                                    ),
                            ),
                            4.h,
                            _Row(
                              name: other,
                              muted: true,
                              trailing: otherSub == null
                                  ? null
                                  : CricketText(
                                      text: otherSub,
                                      maxLines: 1,
                                      textOverflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.end,
                                      style: context.homeText(
                                        14,
                                        color: muted,
                                        tabular: true,
                                      ),
                                    ),
                            ),
                            _ShareRow(
                              enabled: item.joinCode != null,
                              onShare: onShare,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.name, this.trailing, this.muted = false});

  final String name;
  final Widget? trailing;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CricketText(
              text: name,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
              style: context.homeText(
                14,
                color: muted ? context.homeMuted : null,
              ),
            ),
          ),
          if (trailing != null) ...[
            8.w,
            // Capped so a long score or a large text size shortens the
            // trailing text rather than pushing the row past the card.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: trailing,
            ),
          ],
        ],
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.enabled, required this.onShare});

  final bool enabled;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    // Matches created before share codes existed have nothing to share; keep
    // the row's height so cards in one carousel stay the same size.
    if (!enabled) return const SizedBox(height: 10 + 44 - 28);

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: InkWell(
        onTap: onShare,
        borderRadius: 8.radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.only(top: 6, right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.ios_share_rounded,
                    size: 14,
                    color: context.homeMuted,
                  ),
                ),
                6.w,
                Flexible(
                  child: CricketText(
                    text: TranslationKeys.homeShareLink.tr,
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                    style: context.homeText(12, color: context.homeMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
