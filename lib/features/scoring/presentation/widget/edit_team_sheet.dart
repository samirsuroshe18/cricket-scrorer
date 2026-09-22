import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/domain/team_field_limits.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/team_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Opens the edit-team sheet, prefilled with the team's current name and
/// short name. Renaming changes the name everywhere it's shown, including
/// past matches — see `docs/api.md`'s `PATCH /v1/team/:teamId`.
Future<void> showEditTeamSheet({
  required TeamProfileController controller,
  required String currentName,
  String? currentShortName,
}) async {
  final updated = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.editTeam.tr,
    child: EditTeamForm(
      controller: controller,
      initialName: currentName,
      initialShortName: currentShortName,
      onUpdated: () => Get.back<bool>(result: true),
    ),
  );

  if (updated == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.teamUpdated.tr);
  }
}

/// Field-level validation only — this form does not repeat
/// `CreateTeamForm`'s duplicate-name check against the caller's other
/// teams: the backend allows duplicate names by design, and this screen
/// has no dependency on the Teams tab's cached team list.
class EditTeamForm extends StatefulWidget {
  const EditTeamForm({
    required this.controller,
    required this.initialName,
    required this.onUpdated,
    this.initialShortName,
    super.key,
  });

  final TeamProfileController controller;
  final String initialName;
  final String? initialShortName;
  final VoidCallback onUpdated;

  @override
  State<EditTeamForm> createState() => _EditTeamFormState();
}

class _EditTeamFormState extends State<EditTeamForm> {
  late final _name = TextEditingController(text: widget.initialName);
  late final _shortName = TextEditingController(
    text: widget.initialShortName ?? '',
  );

  String? _nameError;
  String? _shortNameError;
  String? _serverError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _shortName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;

    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = TranslationKeys.teamNameRequired.tr);
      return;
    }
    if (name.length > maxTeamNameLength) {
      setState(() => _nameError = TranslationKeys.teamNameTooLong.tr);
      return;
    }
    final shortName = _shortName.text.trim();
    if (shortName.length > maxShortNameLength) {
      setState(
        () => _shortNameError = TranslationKeys.teamShortNameTooLong.tr,
      );
      return;
    }

    setState(() {
      _busy = true;
      _nameError = null;
      _shortNameError = null;
      _serverError = null;
    });

    final error = await widget.controller.updateTeam(
      name: name,
      shortName: shortName.isEmpty ? null : shortName,
    );

    if (!mounted) return;

    if (error == null) {
      widget.onUpdated();
      return;
    }
    setState(() {
      _busy = false;
      _serverError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final errorStyle = context.textTheme.bodySmall?.copyWith(
      color: scheme.error,
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CricketTextField(
            controller: _name,
            hintText: TranslationKeys.teamName.tr,
            labelText: TranslationKeys.teamName.tr,
            prefixIcon: const Icon(Icons.shield_outlined),
            maxLength: maxTeamNameLength,
            isRequired: true,
            onChanged: (_) {
              if (_nameError != null || _serverError != null) {
                setState(() {
                  _nameError = null;
                  _serverError = null;
                });
              }
            },
          ),
          if (_nameError != null) ...[
            4.h,
            CricketText(text: _nameError!, style: errorStyle),
          ],
          12.h,
          CricketTextField(
            controller: _shortName,
            hintText: TranslationKeys.teamShortName.tr,
            labelText: TranslationKeys.teamShortName.tr,
            prefixIcon: const Icon(Icons.short_text),
            maxLength: maxShortNameLength,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) {
              if (_shortNameError != null || _serverError != null) {
                setState(() {
                  _shortNameError = null;
                  _serverError = null;
                });
              }
            },
          ),
          if (_shortNameError != null) ...[
            4.h,
            CricketText(text: _shortNameError!, style: errorStyle),
          ],
          if (_serverError != null) ...[
            12.h,
            CricketText(text: _serverError!, style: errorStyle),
          ],
          20.h,
          CricketButton(
            buttonText: TranslationKeys.editTeam.tr,
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
