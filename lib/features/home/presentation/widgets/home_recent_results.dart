import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/utils/home_match_view.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_style.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';

/// Finished matches as flat rows — a result line and a date, not a full card.
/// Bordered rows rather than cards: this is a dense list, and a stack of
/// rounded rectangles would out-shout the live matches above it.
class HomeRecentResults extends StatelessWidget {
  const HomeRecentResults({
    required this.items,
    required this.onOpen,
    required this.onMore,
    super.key,
  });

  final List<MatchHistoryItem> items;
  final ValueChanged<MatchHistoryItem> onOpen;
  final ValueChanged<MatchHistoryItem> onMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          _ResultRow(
            item: items[i],
            isLast: i == items.length - 1,
            onTap: () => onOpen(items[i]),
            onMore: () => onMore(items[i]),
          ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.item,
    required this.isLast,
    required this.onTap,
    required this.onMore,
  });

  final MatchHistoryItem item;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final result = resultLine(item);
    final subtitle = [
      ?result,
      shortDate(item.createdAt),
    ].join(' · ');

    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: TranslationKeys.matchActions.tr): onMore,
      },
      child: InkWell(
        onTap: onTap,
        onLongPress: onMore,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: context.homeLine)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CricketText(
                      text: '${item.teamA.name} vs ${item.teamB.name}',
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      style: context.homeText(14),
                    ),
                    CricketText(
                      text: subtitle,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      style: context.homeText(12, color: context.homeMuted),
                    ),
                  ],
                ),
              ),
              ExcludeSemantics(
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: context.homeMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
