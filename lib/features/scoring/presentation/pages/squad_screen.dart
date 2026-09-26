import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/custom_app_bar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/domain/squad_rules.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/squad_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/squad_player_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shown right after Create Match: build each side's squad and mark the
/// captain, vice-captain and wicketkeeper. Entirely optional — Skip goes
/// straight on to scoring.
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
            _AddPlayerField(controller: controller),
            12.h,
            Expanded(child: _PlayerList(controller: controller)),
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

class _PlayerList extends StatelessWidget {
  const _PlayerList({required this.controller});

  final SquadController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Read both drafts so the list rebuilds on either side changing, then
      // show the selected one.
      final draft = controller.side.value == SquadController.sideA
          ? controller.teamA.value
          : controller.teamB.value;

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (draft.rows.isEmpty) {
        return Center(
          child: CricketText(
            text: TranslationKeys.squadEmptyHint.tr,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        );
      }
      return ListView(
        children: [
          for (final row in draft.rows)
            SquadPlayerRow(
              row: row,
              isCaptain: _is(draft.captain, row),
              isViceCaptain: _is(draft.viceCaptain, row),
              isKeeper: _is(draft.keeper, row),
              onRole: (role) => controller.setRole(row.name, role),
              onCaptain: () => controller.toggleCaptain(row.name),
              onViceCaptain: () => controller.toggleViceCaptain(row.name),
              onKeeper: () => controller.toggleKeeper(row.name),
              onRemove: () => controller.removePlayer(row.name),
            ),
        ],
      );
    });
  }

  bool _is(String? held, SquadRow row) =>
      held != null && held.toLowerCase() == row.name.toLowerCase();
}
