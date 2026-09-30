import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/domain/squad_rules.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/squad_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/utils/xi_range.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/invitations_section.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/invite_by_email_panel.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/leader_picker_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/squad_player_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shown right after Create Match, and reachable from the scoring console: build
/// each side's squad, mark the captain, vice-captain and wicketkeeper, split it
/// into the Playing XI and the Bench, and invite registered players by email.
/// Save & continue is the only way forward — there is no Skip button — and the
/// AppBar back arrow (and OS swipe-back) run the same Playing XI range check
/// via `SquadController.blockedFromLeaving`, rather than leaving silently. Once
/// the innings has started only the XI / Bench moves and the invitations are
/// offered.
class SquadScreen extends GetView<SquadController> {
  const SquadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final error = controller.blockedFromLeaving();
        if (error != null) {
          controller.showError(error);
          return;
        }
        Get.back<void>();
      },
      child: Scaffold(
        appBar: CustomAppBar(title: TranslationKeys.squadTitle.tr),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SideToggle(controller: controller),
              12.h,
              Expanded(child: _SquadBody(controller: controller)),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Obx(
              () => CricketButton(
                key: const Key('squad_save'),
                buttonText: TranslationKeys.saveAndContinue.tr,
                isDisabled: controller.isSaving.value,
                onPressed: controller.saveAndContinue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideToggle extends StatelessWidget {
  const _SideToggle({required this.controller});

  final SquadController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          for (final (side, name, color) in [
            (
              SquadController.sideA,
              controller.match.teamA.name,
              context.colors.teamA,
            ),
            (
              SquadController.sideB,
              controller.match.teamB.name,
              context.colors.teamB,
            ),
          ])
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: side == SquadController.sideA ? 8 : 0,
                ),
                child: ChoiceChip(
                  key: Key('squad_side_$side'),
                  selectedColor: color.withValues(alpha: 0.2),
                  side: BorderSide(color: color),
                  label: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _xiBadge(context, side),
                      ],
                    ),
                  ),
                  selected: controller.side.value == side,
                  onSelected: (_) => controller.selectSide(side),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// A count next to the team name once its Playing XI is non-empty. Below
  /// the minimum it is a plain outlined number — no denominator, because
  /// there is nothing to divide by: any count up to the maximum is just as
  /// valid as the minimum itself. At or above the minimum it becomes a
  /// filled "done" badge instead of a running total, since reaching the
  /// maximum is never required. Over the maximum it turns into a warning.
  Widget _xiBadge(BuildContext context, String forSide) {
    final draft = forSide == SquadController.sideA
        ? controller.teamA.value
        : controller.teamB.value;
    final range = XiRange.of(
      draft.xiRows.length,
      controller.match.minPlayingXi,
      controller.match.maxPlayingXi,
    );
    if (range.status == XiRangeStatus.hidden ||
        range.status == XiRangeStatus.empty) {
      return const SizedBox.shrink();
    }

    final Color accent;
    final IconData? icon;
    switch (range.status) {
      case XiRangeStatus.belowMin:
        accent = context.colors.statusWarning;
        icon = null;
      case XiRangeStatus.aboveMax:
        accent = context.colors.statusDanger;
        icon = Icons.priority_high;
      case XiRangeStatus.ready:
        accent = context.colors.statusSuccess;
        icon = Icons.check;
      case XiRangeStatus.hidden:
      case XiRangeStatus.empty:
        accent = context.colorScheme.onSurfaceVariant;
        icon = null;
    }

    // The count itself stays in the theme's normal text colour — `accent`
    // drives only the border and icon (UI graphics, held to a 3:1 contrast
    // floor) since `statusWarning` alone falls just short of the 4.5:1
    // normal-text floor on a light surface.
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Container(
        key: Key('squad_xi_badge_$forSide'),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: range.status == XiRangeStatus.ready
              ? context.colors.successCard
              : Colors.transparent,
          border: range.status == XiRangeStatus.ready
              ? null
              : Border.all(color: accent),
          borderRadius: 10.radius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 11, color: accent),
            if (icon != null) 2.w,
            Text(
              '${range.count}',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The status line under the tabs, describing the active side's Playing XI
/// against the match's configured range. Hidden entirely when the match
/// carries no range (an older match reopened from history): the server-side
/// save stays the backstop, same as before this existed.
class _XiStatusCaption extends StatelessWidget {
  const _XiStatusCaption({required this.range});

  final XiRange range;

  @override
  Widget build(BuildContext context) {
    if (range.status == XiRangeStatus.hidden) return const SizedBox.shrink();

    final String text;
    final IconData? icon;
    final Color? accent;
    switch (range.status) {
      case XiRangeStatus.empty:
        text = TranslationKeys.squadPlayingXiSizeHint.trParams({
          'min': '${range.min}',
          'max': '${range.max}',
        });
        icon = null;
        accent = null;
      case XiRangeStatus.belowMin:
        text = TranslationKeys.squadXiBelowMinHint.trParams({
          'count': '${range.count}',
          'more': '${range.short}',
          'min': '${range.min}',
        });
        icon = Icons.info_outline;
        accent = context.colors.statusWarning;
      case XiRangeStatus.ready:
        text = TranslationKeys.squadXiReadyHint.trParams({
          'count': '${range.count}',
        });
        icon = Icons.check_circle_outline;
        accent = context.colors.statusSuccess;
      case XiRangeStatus.aboveMax:
        text = TranslationKeys.squadXiAboveMaxHint.trParams({
          'count': '${range.count}',
          'over': '${range.over}',
          'max': '${range.max}',
        });
        icon = Icons.error_outline;
        accent = context.colors.statusDanger;
      case XiRangeStatus.hidden:
        text = '';
        icon = null;
        accent = null;
    }

    // The colour is carried by the icon (a UI graphic, held to a 3:1
    // contrast floor) rather than the text itself: `statusWarning` reads
    // fine as an accent but falls short of the 4.5:1 normal-text floor on a
    // light surface, and the sentence needs to stay readable regardless of
    // which state it is.
    return Padding(
      key: const Key('squad_xi_caption'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: accent),
            6.w,
          ],
          Expanded(
            child: CricketText(
              text: text,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A thin bar showing progress toward the minimum, not toward the maximum:
/// the tick marks the minimum, and reaching it is what colours the fill
/// green. Filling past the tick toward the maximum is optional headroom, not
/// a second target.
class _XiProgressBar extends StatelessWidget {
  const _XiProgressBar({required this.range});

  final XiRange range;

  @override
  Widget build(BuildContext context) {
    final fillColor = switch (range.status) {
      XiRangeStatus.aboveMax => context.colors.statusDanger,
      XiRangeStatus.ready => context.colors.statusSuccess,
      _ => context.colors.statusWarning,
    };
    final fraction = range.max == 0
        ? 0.0
        : (range.count / range.max).clamp(0.0, 1.0);
    final minFraction = range.max == 0
        ? 0.0
        : (range.min / range.max).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final tickInset = width > 2 ? width - 2 : 0.0;
          return SizedBox(
            height: 8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: 4.radius,
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: context.colorScheme.outlineVariant,
                    valueColor: AlwaysStoppedAnimation(fillColor),
                  ),
                ),
                Positioned(
                  left: (width * minFraction).clamp(0.0, tickInset),
                  child: Container(
                    width: 2,
                    height: 8,
                    color: context.colorScheme.onSurface.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Captain / vice-captain / keeper, each a tap target opening a picker over
/// the Playing XI. Disabled (with no picker) while the XI is empty — there is
/// no one to choose from yet.
class _LeaderStrip extends StatelessWidget {
  const _LeaderStrip({required this.controller, required this.draft});

  final SquadController controller;
  final SquadDraft draft;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _chip(
            context,
            keyName: 'squad_leader_captain',
            shortLabel: TranslationKeys.captainShort.tr,
            name: draft.captain,
            sheetTitle: TranslationKeys.chooseCaptain.tr,
            clearLabel: TranslationKeys.removeCaptain.tr,
            onPick: controller.toggleCaptain,
          ),
        ),
        8.w,
        Expanded(
          child: _chip(
            context,
            keyName: 'squad_leader_vc',
            shortLabel: TranslationKeys.viceCaptainShort.tr,
            name: draft.viceCaptain,
            sheetTitle: TranslationKeys.chooseViceCaptain.tr,
            clearLabel: TranslationKeys.removeViceCaptain.tr,
            onPick: controller.toggleViceCaptain,
          ),
        ),
        8.w,
        Expanded(
          child: _chip(
            context,
            keyName: 'squad_leader_wk',
            shortLabel: TranslationKeys.wicketkeeperShort.tr,
            name: draft.keeper,
            sheetTitle: TranslationKeys.chooseKeeper.tr,
            clearLabel: TranslationKeys.removeKeeper.tr,
            onPick: controller.toggleKeeper,
          ),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context, {
    required String keyName,
    required String shortLabel,
    required String? name,
    required String sheetTitle,
    required String clearLabel,
    required void Function(String name) onPick,
  }) {
    final chosen = name != null;
    final enabled = draft.xiRows.isNotEmpty;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: InkWell(
        key: Key(keyName),
        borderRadius: 19.radius,
        onTap: !enabled
            ? null
            : () => unawaited(
                showLeaderPickerSheet(
                  title: sheetTitle,
                  clearLabel: clearLabel,
                  candidates: draft.xiRows,
                  current: name,
                  onPick: onPick,
                ),
              ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          child: CustomPaint(
            painter: chosen
                ? null
                : _DashedBorderPainter(
                    color: context.colorScheme.outline,
                    radius: 19,
                  ),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: 19.radius,
                border: chosen
                    ? Border.all(color: context.colorScheme.outline)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: context.colors.chipBackground,
                    child: Text(
                      shortLabel,
                      style: context.textTheme.labelSmall,
                    ),
                  ),
                  6.w,
                  Flexible(
                    child: CricketText(
                      text: chosen
                          ? name
                          : TranslationKeys.squadChoosePlaceholder.tr,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: chosen ? null : context.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const gapWidth = 3.0;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0.0, metric.length)),
          paint,
        );
        distance = next + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}

/// Icon, headline and body only — the Add-player and Invite rows that follow
/// it live at a fixed spot in `_SquadBody`'s list instead of nested here, so
/// neither one gets rebuilt from scratch (and loses its open/focused state)
/// the moment the first player turns this empty state into a real list.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: context.colors.chipBackground,
            child: Icon(
              Icons.groups_outlined,
              size: 36,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          16.h,
          CricketText(
            text: TranslationKeys.squadEmptyTitle.tr,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          4.h,
          CricketText(
            text: TranslationKeys.squadEmptyHint.tr,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InviteRow extends StatelessWidget {
  const _InviteRow({required this.controller});

  final SquadController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('squad_inviteButton'),
      borderRadius: 12.radius,
      onTap: () => unawaited(
        showInviteByEmailSheet(
          lookup: controller.lookupUserByEmail,
          invite: controller.inviteUser,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.mail_outline,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            12.w,
            CricketText(text: TranslationKeys.inviteByEmail.tr),
          ],
        ),
      ),
    );
  }
}

/// The name field for typing a new player, before the innings only — nothing
/// but the XI can be saved after it. Idle, it is a plain tappable row; tapping
/// it swaps in an autofocused field that stays open after each add, so the
/// scorer can keep typing names without reopening it.
class _AddPlayerListItem extends StatefulWidget {
  const _AddPlayerListItem({required this.controller})
    : super(key: const ValueKey('squad_add_player_item'));

  final SquadController controller;

  @override
  State<_AddPlayerListItem> createState() => _AddPlayerListItemState();
}

class _AddPlayerListItemState extends State<_AddPlayerListItem> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  bool _adding = false;

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add() {
    if (_text.text.trim().isEmpty) return;
    widget.controller.addPlayer(_text.text);
    _text.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (!_adding) {
      return InkWell(
        key: const Key('squad_addPlayerRow'),
        borderRadius: 12.radius,
        onTap: () => setState(() => _adding = true),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.add, color: context.colorScheme.secondary),
              ),
              12.w,
              CricketText(
                text: TranslationKeys.addPlayer.tr,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('squad_nameField'),
              controller: _text,
              focusNode: _focus,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              onSubmitted: (_) => _add(),
              decoration: InputDecoration(
                hintText: TranslationKeys.playerName.tr,
                counterText: '',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          8.w,
          IconButton.filled(
            key: const Key('squad_addButton'),
            tooltip: TranslationKeys.addPlayer.tr,
            icon: const Icon(Icons.add),
            onPressed: _add,
          ),
        ],
      ),
    );
  }
}

class _SquadBody extends StatelessWidget {
  const _SquadBody({required this.controller});

  final SquadController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Read both drafts so the list rebuilds on either side changing, then
      // show the selected one.
      final draft = controller.side.value == SquadController.sideA
          ? controller.teamA.value
          : controller.teamB.value;
      final invites = controller.currentInvites.toList();
      final compact = controller.midMatch.value;
      final range = XiRange.of(
        draft.xiRows.length,
        controller.match.minPlayingXi,
        controller.match.maxPlayingXi,
      );

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.refreshFromServer,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (range.status != XiRangeStatus.hidden)
              _XiStatusCaption(range: range),
            if (range.status != XiRangeStatus.hidden && draft.rows.isNotEmpty)
              _XiProgressBar(range: range),
            if (!compact && draft.rows.isNotEmpty) ...[
              _LeaderStrip(controller: controller, draft: draft),
              12.h,
            ],
            if (draft.rows.isEmpty)
              const _EmptyState()
            else ...[
              for (final row in draft.xiRows)
                _row(draft, row, inXi: true, compact: compact),
              for (final row in draft.benchRows)
                _row(draft, row, inXi: false, compact: compact),
              8.h,
            ],
            // Fixed position regardless of whether the squad is empty, so
            // neither widget is rebuilt from scratch — and loses its
            // open/focused state — the moment the first player is added.
            if (!compact) _AddPlayerListItem(controller: controller),
            _InviteRow(controller: controller),
            KeyedSubtree(
              key: const Key('squad_section_invites'),
              child: InvitationsSection(
                invites: invites,
                onCancel: (invite) =>
                    unawaited(controller.cancelInvite(invite)),
                onInviteAgain: (invite) =>
                    unawaited(controller.inviteAgain(invite)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _row(
    SquadDraft draft,
    SquadRow row, {
    required bool inXi,
    required bool compact,
  }) => SquadPlayerRow(
    row: row,
    isCaptain: _is(draft.captain, row),
    isViceCaptain: _is(draft.viceCaptain, row),
    isKeeper: _is(draft.keeper, row),
    inXi: inXi,
    compact: compact,
    onMove: () =>
        inXi ? controller.moveToBench(row.name) : controller.moveToXi(row.name),
    onRole: (role) => controller.setRole(row.name, role),
    onRemove: () => controller.removePlayer(row.name),
  );

  bool _is(String? held, SquadRow row) =>
      held != null && held.toLowerCase() == row.name.toLowerCase();
}
