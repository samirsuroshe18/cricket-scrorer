import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/roster_role_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Edits one rostered player from the team profile: role, jersey number, and
/// whether they are the team's captain or vice-captain. Goes through
/// `PATCH /v1/team/:teamId/players/:playerId`, so an organization owner can
/// manage a roster whose players another account created.
Future<void> showEditRosterPlayerSheet({
  required TeamProfileController controller,
  required TeamRosterPlayer player,
}) async {
  await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.editPlayer.tr,
    child: EditRosterPlayerForm(
      controller: controller,
      player: player,
      onDone: () => Get.back<bool>(result: true),
    ),
  );
}

class EditRosterPlayerForm extends StatefulWidget {
  const EditRosterPlayerForm({
    required this.controller,
    required this.player,
    required this.onDone,
    super.key,
  });

  final TeamProfileController controller;
  final TeamRosterPlayer player;
  final VoidCallback onDone;

  @override
  State<EditRosterPlayerForm> createState() => _EditRosterPlayerFormState();
}

class _EditRosterPlayerFormState extends State<EditRosterPlayerForm> {
  late final _jersey = TextEditingController(
    text: widget.player.jerseyNumber?.toString() ?? '',
  );

  // An unset role starts with no chip selected, and stays unsent unless the
  // scorer picks one.
  late String? _role = widget.player.role == 'unknown'
      ? null
      : widget.player.role;
  String? _jerseyError;
  String? _serverError;
  bool _busy = false;

  @override
  void dispose() {
    _jersey.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final jersey = parseJerseyNumber(_jersey.text);
    if (!jersey.valid) {
      setState(() => _jerseyError = TranslationKeys.jerseyNumberInvalid.tr);
      return;
    }

    setState(() {
      _busy = true;
      _jerseyError = null;
      _serverError = null;
    });
    final error = await widget.controller.updatePlayer(
      playerId: widget.player.playerId,
      role: _role,
      jerseyNumber: jersey.value,
      // An emptied field on a player who had a number means "remove it" — a
      // bare null would be read as "leave unchanged" and silently do nothing.
      clearJerseyNumber:
          jersey.value == null && widget.player.jerseyNumber != null,
    );
    _finish(error);
  }

  void _finish(String? error) {
    if (!mounted) return;
    if (error == null) {
      widget.onDone();
    } else {
      setState(() {
        _busy = false;
        _serverError = error;
      });
    }
  }

  Future<void> _toggleLeader({
    required bool viceCaptain,
    required bool isCurrent,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _serverError = null;
    });
    final error = isCurrent
        ? await widget.controller.clearLeader(viceCaptain: viceCaptain)
        : await widget.controller.setLeader(
            playerId: widget.player.playerId,
            viceCaptain: viceCaptain,
          );
    _finish(error);
  }

  @override
  Widget build(BuildContext context) {
    final errorStyle = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.error,
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CricketText(
            text: widget.player.playerName,
            style: context.textTheme.titleMedium,
          ),
          16.h,
          CricketText(text: TranslationKeys.role.tr),
          8.h,
          RosterRolePicker(
            selected: _role,
            onChanged: (role) => setState(() => _role = role),
          ),
          16.h,
          CricketTextField(
            controller: _jersey,
            hintText: TranslationKeys.jerseyNumber.tr,
            labelText: TranslationKeys.jerseyNumber.tr,
            prefixIcon: const Icon(Icons.tag),
            keyboardType: TextInputType.number,
            maxLength: 3,
            onChanged: (_) {
              if (_jerseyError != null) setState(() => _jerseyError = null);
            },
          ),
          if (_jerseyError != null) ...[
            4.h,
            CricketText(text: _jerseyError!, style: errorStyle),
          ],
          if (_serverError != null) ...[
            12.h,
            CricketText(text: _serverError!, style: errorStyle),
          ],
          20.h,
          CricketButton(
            buttonText: TranslationKeys.saveChanges.tr,
            isDisabled: _busy,
            onPressed: _save,
          ),
          12.h,
          Obx(() {
            final profile = widget.controller.profile.value;
            final id = widget.player.playerId;
            final isCaptain = profile?.captainId == id;
            final isViceCaptain = profile?.viceCaptainId == id;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _toggleLeader(
                          viceCaptain: false,
                          isCurrent: isCaptain,
                        ),
                  child: CricketText(
                    text:
                        (isCaptain
                                ? TranslationKeys.removeCaptain
                                : TranslationKeys.makeCaptain)
                            .tr,
                  ),
                ),
                8.h,
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _toggleLeader(
                          viceCaptain: true,
                          isCurrent: isViceCaptain,
                        ),
                  child: CricketText(
                    text:
                        (isViceCaptain
                                ? TranslationKeys.removeViceCaptain
                                : TranslationKeys.makeViceCaptain)
                            .tr,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
