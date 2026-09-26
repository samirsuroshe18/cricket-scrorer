import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/roster_role_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Player.name's own limit (`Player.name` maxlength on the backend).
const int _maxPlayerNameLength = 50;

/// Adds a player to the team's roster by name. Typing a name the scorer has
/// used before adds that same player rather than a duplicate — see
/// `POST /v1/team/:teamId/players` in docs/api.md.
Future<void> showAddPlayerSheet({
  required TeamProfileController controller,
}) async {
  await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.addPlayer.tr,
    child: AddPlayerForm(
      controller: controller,
      onAdded: () => Get.back<bool>(result: true),
    ),
  );
}

class AddPlayerForm extends StatefulWidget {
  const AddPlayerForm({
    required this.controller,
    required this.onAdded,
    super.key,
  });

  final TeamProfileController controller;
  final VoidCallback onAdded;

  @override
  State<AddPlayerForm> createState() => _AddPlayerFormState();
}

class _AddPlayerFormState extends State<AddPlayerForm> {
  final _name = TextEditingController();
  final _jersey = TextEditingController();

  String? _role;
  String? _nameError;
  String? _jerseyError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _jersey.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;

    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = TranslationKeys.playerNameRequired.tr);
      return;
    }
    final jersey = parseJerseyNumber(_jersey.text);
    if (!jersey.valid) {
      setState(() => _jerseyError = TranslationKeys.jerseyNumberInvalid.tr);
      return;
    }

    setState(() {
      _busy = true;
      _nameError = null;
      _jerseyError = null;
    });

    final added = await widget.controller.addPlayer(
      name: name,
      role: _role,
      jerseyNumber: jersey.value,
    );

    if (!mounted) return;
    if (added) {
      widget.onAdded();
    } else {
      setState(() => _busy = false);
    }
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
          CricketTextField(
            controller: _name,
            hintText: TranslationKeys.playerName.tr,
            labelText: TranslationKeys.playerName.tr,
            prefixIcon: const Icon(Icons.person_outline),
            maxLength: _maxPlayerNameLength,
            isRequired: true,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          if (_nameError != null) ...[
            4.h,
            CricketText(text: _nameError!, style: errorStyle),
          ],
          12.h,
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
          20.h,
          CricketButton(
            buttonText: TranslationKeys.addPlayer.tr,
            isDisabled: _busy,
            prefixIcon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
