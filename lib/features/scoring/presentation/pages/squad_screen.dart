import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/domain/squad_rules.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/squad_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/invitations_section.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/invite_by_email_panel.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/squad_player_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shown right after Create Match, and reachable from the scoring console: build
/// each side's squad, mark the captain, vice-captain and wicketkeeper, split it
/// into the Playing XI and the Bench, and invite registered players by email.
/// Entirely optional — Skip goes straight on to scoring. Once the innings has
/// started only the XI / Bench moves and the invitations are offered.
class SquadScreen extends GetView<SquadController> {
  const SquadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: TranslationKeys.squadTitle.tr),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SideToggle(controller: controller),
            12.h,
            _AddRow(controller: controller),
            12.h,
            Expanded(child: _SquadBody(controller: controller)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              TextButton(
                key: const Key('squad_skip'),
                onPressed: controller.skip,
                child: Text(TranslationKeys.skip.tr),
              ),
              12.w,
              Expanded(
                child: Obx(
                  () => CricketButton(
                    key: const Key('squad_save'),
                    buttonText: TranslationKeys.saveAndContinue.tr,
                    isDisabled: controller.isSaving.value,
                    onPressed: controller.saveAndContinue,
                  ),
                ),
              ),
            ],
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
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}

class _AddPlayerField extends StatefulWidget {
  const _AddPlayerField({required this.controller});

  final SquadController controller;

  @override
  State<_AddPlayerField> createState() => _AddPlayerFieldState();
}

class _AddPlayerFieldState extends State<_AddPlayerField> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _add() {
    widget.controller.addPlayer(_text.text);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('squad_nameField'),
            controller: _text,
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
    );
  }
}

/// The name field for typing a new player (before the innings only — nothing
/// but the XI can be saved after it) and the invite-by-email button.
class _AddRow extends StatelessWidget {
  const _AddRow({required this.controller});

  final SquadController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => controller.midMatch.value
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AddPlayerField(controller: controller),
                ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const Key('squad_inviteButton'),
            onPressed: () => unawaited(
              showInviteByEmailSheet(
                lookup: controller.lookupUserByEmail,
                invite: controller.inviteUser,
              ),
            ),
            icon: const Icon(Icons.mail_outline, size: 18),
            label: Text(TranslationKeys.inviteByEmail.tr),
          ),
        ),
      ],
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

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: controller.refreshFromServer,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (draft.rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: CricketText(
                  text: TranslationKeys.squadEmptyHint.tr,
                  style: context.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              _SectionHeader(
                sectionKey: const Key('squad_section_xi'),
                label: TranslationKeys.squadPlayingXi.tr,
                count: draft.xiRows.length,
              ),
              for (final row in draft.xiRows)
                _row(draft, row, inXi: true, compact: compact),
              _SectionHeader(
                sectionKey: const Key('squad_section_bench'),
                label: TranslationKeys.squadBench.tr,
                count: draft.benchRows.length,
              ),
              for (final row in draft.benchRows)
                _row(draft, row, inXi: false, compact: compact),
            ],
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
    onCaptain: () => controller.toggleCaptain(row.name),
    onViceCaptain: () => controller.toggleViceCaptain(row.name),
    onKeeper: () => controller.toggleKeeper(row.name),
    onRemove: () => controller.removePlayer(row.name),
  );

  bool _is(String? held, SquadRow row) =>
      held != null && held.toLowerCase() == row.name.toLowerCase();
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.sectionKey,
    required this.label,
    required this.count,
  });

  final Key sectionKey;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: sectionKey,
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: CricketText(
        text: '$label ($count)',
        style: context.textTheme.titleSmall,
      ),
    );
  }
}
