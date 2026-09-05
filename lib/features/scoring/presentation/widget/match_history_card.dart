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
    required this.currentUserId,
    this.onDelete,
    this.onAssignScorer,
    this.isDeleting,
    this.highlightTeamId,
  });

  final MatchHistoryItem item;
  final VoidCallback onTap;

  /// Needed to tell "assigned by someone else" apart from "assigned by me"
  /// for [_delegationLabel] — see docs/api.md's delegated-scoring contract.
  final String currentUserId;

  /// Null on `TeamProfileScreen`'s list — that screen offers no delete
  /// affordance, only `HomePage`'s own history does.
  final VoidCallback? onDelete;

  /// Null hides the assign-scorer icon entirely — neither screen that uses
  /// this card should pass null in practice (both wire it up), but keeping
  /// it optional matches [onDelete]'s own nullable shape rather than
  /// forcing every future caller of this widget to have an opinion.
  final VoidCallback? onAssignScorer;

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

  // A team name that opens its profile reads as a link — the app's own
  // interactive-blue, not the neutral onSurface every other label on this
  // card uses — wrapped in an InkWell (not a bare GestureDetector) so the
  // tap gets the same ripple feedback as the card's own outer InkWell.
  Widget _teamNameLink(BuildContext context, String teamId, String label) {
    return InkWell(
      onTap: () => _openTeamProfile(teamId),
      borderRadius: 4.radius,
      child: CricketText(
        text: label,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colorScheme.secondary,
        ),
        maxLines: 1,
        textOverflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final highlight = highlightTeamId;

    if (highlight == item.teamA.id || highlight == item.teamB.id) {
      final opponent = highlight == item.teamA.id ? item.teamB : item.teamA;
      return _teamNameLink(context, opponent.id, 'vs ${opponent.name}');
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: _teamNameLink(context, item.teamA.id, item.teamA.name)),
        CricketText(text: ' vs ', style: context.textTheme.titleSmall),
        Flexible(child: _teamNameLink(context, item.teamB.id, item.teamB.name)),
      ],
    );
  }

  String? _delegationLabel() {
    final creator = item.createdBy;
    if (creator != null && creator.id != currentUserId) {
      return TranslationKeys.assignedByName.trParams({'name': creator.name});
    }
    final scorer = item.assignedScorer;
    if (scorer != null) {
      return TranslationKeys.assignedToName.trParams({'name': scorer.name});
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final delete = onDelete;
    final deleting = isDeleting;
    final delegationLabel = _delegationLabel();

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
                  if (onAssignScorer != null)
                    IconButton(
                      tooltip: TranslationKeys.assignScorer.tr,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.person_add_alt,
                        size: 20,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: onAssignScorer,
                    ),
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
              if (delegationLabel != null) ...[
                4.h,
                CricketText(
                  text: delegationLabel,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
