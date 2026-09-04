import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One row of a match-history-shaped list — used by `HomePage` (the
/// scorer's own match history, [highlightTeamId] null) and
/// `TeamProfileScreen` (past results for one team, [highlightTeamId] set to
/// that team's id) since `GET /v1/team/:teamId/matches` returns the exact
/// same [MatchHistoryItem] shape as `GET /v1/match/history`.
class MatchHistoryCard extends StatelessWidget {
  const MatchHistoryCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onDelete,
    this.isDeleting,
    this.highlightTeamId,
  });

  final MatchHistoryItem item;
  final VoidCallback onTap;

  /// Null on `TeamProfileScreen`'s list — that screen offers no delete
  /// affordance, only `HomePage`'s own history does.
  final VoidCallback? onDelete;

  /// A callback rather than a plain `bool`, same reason as before: the
  /// caller's `deletingMatchIds` is reactive and this card needs to read it
  /// live without the surrounding list rebuilding on every delete. Null
  /// whenever [onDelete] is null.
  final bool Function()? isDeleting;

  /// When set to [item.teamA]'s or [item.teamB]'s id — the team whose
  /// profile is already on screen — the title shows just the opponent
  /// ("vs Chennai Super Kings") instead of "Team A vs Team B", so
  /// `TeamProfileScreen`'s own match list doesn't repeat the name already in
  /// its header. `HomePage` passes null and always gets the full title.
  final String? highlightTeamId;

  void _openTeamProfile(String teamId) {
    Get.toNamed<dynamic>(AppRoutes.teamProfilePath(teamId));
  }

  Widget _buildTitle(BuildContext context) {
    final highlight = highlightTeamId;
    final style = context.textTheme.titleSmall;

    if (highlight == item.teamA.id || highlight == item.teamB.id) {
      final opponent = highlight == item.teamA.id ? item.teamB : item.teamA;
      return GestureDetector(
        onTap: () => _openTeamProfile(opponent.id),
        child: CricketText(
          text: 'vs ${opponent.name}',
          style: style,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () => _openTeamProfile(item.teamA.id),
            child: CricketText(
              text: item.teamA.name,
              style: style,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        CricketText(text: ' vs ', style: style),
        Flexible(
          child: GestureDetector(
            onTap: () => _openTeamProfile(item.teamB.id),
            child: CricketText(
              text: item.teamB.name,
              style: style,
              maxLines: 1,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final delete = onDelete;
    final deleting = isDeleting;

    return Material(
      color: context.colorScheme.surfaceContainerHighest,
      borderRadius: 12.radius,
      child: InkWell(
        borderRadius: 12.radius,
        onTap: onTap,
        child: Padding(
          padding: 16.p,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildTitle(context)),
                  8.w,
                  _StatusBadge(status: item.status),
                  if (delete != null)
                    Obx(
                      () => (deleting?.call() ?? false)
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              tooltip: TranslationKeys.deleteMatch.tr,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: delete,
                            ),
                    ),
                ],
              ),
              6.h,
              CricketText(
                text:
                    '${item.totalOvers} ${TranslationKeys.overs.tr} · '
                    '${_formatDate(item.createdAt)}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// No `intl` dependency in this project (see pubspec.yaml) — a plain
  /// "20 Aug 2026" built from the ISO string's own fields, deliberately not
  /// locale-aware, matches every other date shown in this codebase today.
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'live' => (TranslationKeys.statusLive.tr, context.colors.statusInfo),
      'innings_break' => (
        TranslationKeys.statusInningsBreak.tr,
        context.colors.statusInfo,
      ),
      'completed' => (
        TranslationKeys.statusCompleted.tr,
        context.colors.statusSuccess,
      ),
      'abandoned' => (
        TranslationKeys.statusAbandoned.tr,
        context.colors.statusDanger,
      ),
      _ => (TranslationKeys.statusUpcoming.tr, context.colors.statusWarning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: 8.radius,
      ),
      child: CricketText(
        text: label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
