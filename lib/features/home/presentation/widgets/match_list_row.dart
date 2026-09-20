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

const _liveStatuses = {'live', 'innings_break'};

/// One match on the Matches tab. Built to the Home dashboard's vocabulary — a
/// hairline card, a status tag, name-and-score lines — but sized for a full
/// history: completed rows lead with the result, abandoned ones stay a single
/// line, and a sync conflict is a persistent strip rather than a chip.
///
/// Assign-scorer and delete are not on the face: [onMore] (the ⋮ button, a
/// long-press, or the screen reader's custom action) opens the same actions
/// sheet Home uses, so a live row carries no destructive icon a thumb can hit
/// mid-match.
class MatchListRow extends StatelessWidget {
  const MatchListRow({
    required this.item,
    required this.currentUserId,
    required this.onTap,
    required this.onMore,
    required this.isDeleting,
    super.key,
  });

  final MatchHistoryItem item;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback onMore;

  /// A callback, not a `bool`: `deletingMatchIds` is reactive, and the row
  /// reads it live so one match's delete does not rebuild the whole list.
  final bool Function() isDeleting;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final deleting = isDeleting();
      return Opacity(
        opacity: deleting ? 0.5 : 1,
        child: IgnorePointer(
          ignoring: deleting,
          child: _RowCard(
            item: item,
            currentUserId: currentUserId,
            deleting: deleting,
            onTap: onTap,
            onMore: onMore,
          ),
        ),
      );
    });
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({
    required this.item,
    required this.currentUserId,
    required this.deleting,
    required this.onTap,
    required this.onMore,
  });

  final MatchHistoryItem item;
  final String currentUserId;
  final bool deleting;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final isLive = _liveStatuses.contains(item.status);
    final delegation = delegationLabelFor(item, currentUserId);
    final isConflict = item.syncStatus == 'conflict';
    final isSyncing = item.syncStatus == 'syncing';

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
                    if (isLive)
                      Container(width: 3, color: context.colorScheme.primary),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              start: 12,
                              end: 4,
                              bottom: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Header(
                                  item: item,
                                  deleting: deleting,
                                  onMore: onMore,
                                ),
                                _Body(item: item),
                                if (delegation != null) ...[
                                  4.h,
                                  _Meta(text: delegation),
                                ],
                                if (isSyncing && !isConflict) ...[
                                  4.h,
                                  const _SyncingLine(),
                                ],
                              ],
                            ),
                          ),
                          if (isConflict) _ConflictStrip(onTap: onTap),
                        ],
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

class _Header extends StatelessWidget {
  const _Header({
    required this.item,
    required this.deleting,
    required this.onMore,
  });

  final MatchHistoryItem item;
  final bool deleting;
  final VoidCallback onMore;

  (String, Color) _status(BuildContext context) => switch (item.status) {
    'live' => (
      TranslationKeys.statusLive.tr,
      context.colorScheme.primary,
    ),
    'innings_break' => (
      TranslationKeys.statusInningsBreak.tr,
      context.colorScheme.primary,
    ),
    'completed' => (
      TranslationKeys.statusCompleted.tr,
      context.colors.statusSuccess,
    ),
    'abandoned' => (
      TranslationKeys.statusAbandoned.tr,
      context.colors.statusDanger,
    ),
    _ => (
      TranslationKeys.statusUpcoming.tr,
      context.colors.statusWarning,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (label, dotColor) = _status(context);
    final isLive = _liveStatuses.contains(item.status);
    final length = item.totalOvers == 1
        ? TranslationKeys.matchesOverOne.tr
        : '${item.totalOvers} ${TranslationKeys.overs.tr}';
    final tag = '$label · $length';

    return Row(
      children: [
        // The status colour rides on the dot, not the text: amber and green
        // fall short of 4.5:1 as 11px text on a light card, so the words stay
        // muted (or the live red, which passes) and the dot carries the hue.
        ExcludeSemantics(
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
        ),
        6.w,
        Expanded(
          child: CricketText(
            text: tag.toUpperCase(),
            maxLines: 2,
            textOverflow: TextOverflow.ellipsis,
            style: context.homeText(
              11,
              weight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isLive ? context.homeLiveText : context.homeMuted,
            ),
          ),
        ),
        8.w,
        CricketText(
          text: matchDateLabel(item.createdAt),
          maxLines: 1,
          style: context.homeText(12, color: context.homeMuted),
        ),
        SizedBox(
          width: 44,
          height: 44,
          child: deleting
              ? const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  tooltip: TranslationKeys.matchActions.tr,
                  onPressed: onMore,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: context.homeMuted,
                  ),
                ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.item});

  final MatchHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item.status) {
      'live' || 'innings_break' => _LiveBody(item: item),
      'completed' => _CompletedBody(item: item),
      'abandoned' => Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: CricketText(
          text: '${item.teamA.name} vs ${item.teamB.name}',
          maxLines: 2,
          textOverflow: TextOverflow.ellipsis,
          style: context.homeText(14, color: context.homeMuted),
        ),
      ),
      _ => _TeamsBody(item: item),
    };
  }
}

/// Upcoming: two names, nothing to score yet.
class _TeamsBody extends StatelessWidget {
  const _TeamsBody({required this.item});

  final MatchHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TeamLine(name: item.teamA.name),
        4.h,
        _TeamLine(name: item.teamB.name),
      ],
    );
  }
}

/// Batting side with its score, the other side with the target or "yet to
/// bat" — the same reading Home's live card gives.
class _LiveBody extends StatelessWidget {
  const _LiveBody({required this.item});

  final MatchHistoryItem item;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TeamLine(
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
        _TeamLine(
          name: other,
          muted: true,
          trailing: otherSub == null
              ? null
              : CricketText(
                  text: otherSub,
                  maxLines: 1,
                  textOverflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: context.homeText(14, color: muted, tabular: true),
                ),
        ),
      ],
    );
  }
}

/// The winner in bold, the other side quiet, and the result sentence under
/// them. A tie or a missing result leaves both names at the same weight.
class _CompletedBody extends StatelessWidget {
  const _CompletedBody({required this.item});

  final MatchHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final winner = item.result?.winner;
    final result = resultLine(item);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TeamLine(
          name: item.teamA.name,
          bold: winner == 'teamA',
          muted: winner == 'teamB',
        ),
        4.h,
        _TeamLine(
          name: item.teamB.name,
          bold: winner == 'teamB',
          muted: winner == 'teamA',
        ),
        if (result != null) ...[
          8.h,
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.emoji_events_outlined,
                    size: 16,
                    color: context.colors.statusSuccess,
                  ),
                ),
                6.w,
                Expanded(
                  child: CricketText(
                    text: result,
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                    style: context.homeText(13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TeamLine extends StatelessWidget {
  const _TeamLine({
    required this.name,
    this.trailing,
    this.muted = false,
    this.bold = false,
  });

  final String name;
  final Widget? trailing;
  final bool muted;
  final bool bold;

  /// Past this many logical pixels for a 14-point line, name and score no
  /// longer fit side by side without clipping one of them.
  static const _stackAbove = 20.0;

  @override
  Widget build(BuildContext context) {
    final nameText = CricketText(
      text: name,
      maxLines: 2,
      textOverflow: TextOverflow.ellipsis,
      style: context.homeText(
        14,
        weight: bold ? FontWeight.w600 : FontWeight.w400,
        color: muted ? context.homeMuted : null,
      ),
    );
    final trailing = this.trailing;
    final stacked =
        trailing != null &&
        MediaQuery.textScalerOf(context).scale(14) > _stackAbove;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: stacked
          // Large text: the score drops under the name instead of both being
          // squeezed onto one line and clipped.
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [nameText, 2.h, trailing],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: nameText),
                if (trailing != null) ...[
                  8.w,
                  // Capped so a long score shortens the trailing text rather
                  // than pushing the row past the card.
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

class _Meta extends StatelessWidget {
  const _Meta({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return CricketText(
      text: text,
      maxLines: 1,
      textOverflow: TextOverflow.ellipsis,
      style: context.homeText(12, color: context.homeMuted),
    );
  }
}

/// The info colour rides on the icon only: it is 4.3:1 on a white card, short
/// of the 4.5:1 12px text needs, so the words stay muted.
class _SyncingLine extends StatelessWidget {
  const _SyncingLine();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExcludeSemantics(
          child: Icon(
            Icons.sync_rounded,
            size: 14,
            color: context.colors.statusInfo,
          ),
        ),
        6.w,
        _Meta(text: TranslationKeys.syncingNow.tr),
      ],
    );
  }
}

/// A conflict is data at risk, so it is a persistent, full-width, tappable
/// strip inside the card — not a chip. No tinted fill: the message stays in
/// body ink on the card surface, and only the icon and the top rule are red.
class _ConflictStrip extends StatelessWidget {
  const _ConflictStrip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final danger = context.colors.statusDanger;
    final label = TranslationKeys.syncConflictTitle.tr;
    final action = TranslationKeys.homeStripReview.tr;

    return Semantics(
      button: true,
      label: '$label. $action',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: danger)),
          ),
          child: Row(
            children: [
              Icon(Icons.sync_problem_rounded, size: 16, color: danger),
              8.w,
              Expanded(
                child: CricketText(
                  text: label,
                  maxLines: 2,
                  textOverflow: TextOverflow.ellipsis,
                  style: context.homeText(13),
                ),
              ),
              8.w,
              CricketText(
                text: action,
                style: context
                    .homeText(13)
                    .copyWith(decoration: TextDecoration.underline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
