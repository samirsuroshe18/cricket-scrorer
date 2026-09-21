import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_teams_controller.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Longest team name / short name the backend accepts (`Team` schema).
///
/// The backend counts UTF-16 code units (`String.length`), while a text
/// field's counter and formatter count user-perceived characters, so a
/// Devanagari or emoji value can look under the limit and still be over it on
/// the wire. The form therefore checks `String.length` itself before sending.
const _maxTeamNameLength = 50;
const _maxShortNameLength = 5;

/// Opens the create-team sheet. When the team is created under an
/// organization, that organization's team count changed too, so [orgs] is
/// reloaded; [teams] reloads itself inside `MyTeamsController.createTeam`.
Future<void> showCreateTeamSheet({
  required MyTeamsController teams,
  required OrganizationsListController orgs,
}) async {
  final owned = orgs.organizations.where((o) => o.myRole == 'owner').toList();

  final created = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.createTeam.tr,
    child: CreateTeamForm(
      teams: teams,
      ownedOrganizations: owned,
      // Reloads the organizations (its team count changed) even if the sheet
      // was closed before the request finished; the sheet itself closes only
      // if it is still open.
      onOrganizationTeamCreated: (_) => unawaited(orgs.loadOrganizations()),
      onCreated: (_) => Get.back<bool>(result: true),
    ),
  );

  if (created == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.teamCreated.tr);
  }
}

/// The form inside the sheet. Validation and server errors are shown next to
/// the fields rather than as a snackbar: a GetX snackbar is a route, so a
/// `Get.back()` after one would close the snackbar instead of this sheet.
class CreateTeamForm extends StatefulWidget {
  const CreateTeamForm({
    required this.teams,
    required this.ownedOrganizations,
    required this.onCreated,
    this.onOrganizationTeamCreated,
    super.key,
  });

  final MyTeamsController teams;

  /// Organizations the caller owns — the only ones a team can be created
  /// under. Empty hides the "Belongs to" choice.
  final List<OrganizationSummaryRes> ownedOrganizations;

  /// Called once the team exists, with the organization id it was created
  /// under (null for an independent team). Not called if the form was
  /// disposed while the request ran.
  final void Function(String? organizationId) onCreated;

  /// Called with the organization id whenever a team was created under one,
  /// even if the sheet was closed while the request ran.
  final void Function(String organizationId)? onOrganizationTeamCreated;

  @override
  State<CreateTeamForm> createState() => _CreateTeamFormState();
}

class _CreateTeamFormState extends State<CreateTeamForm> {
  final _name = TextEditingController();
  final _shortName = TextEditingController();

  String? _organizationId;
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

  String? get _selectedOrganizationName {
    for (final org in widget.ownedOrganizations) {
      if (org.id == _organizationId) return org.name;
    }
    return null;
  }

  Future<void> _submit() async {
    if (_busy) return;

    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = TranslationKeys.teamNameRequired.tr);
      return;
    }
    if (name.length > _maxTeamNameLength) {
      setState(() => _nameError = TranslationKeys.teamNameTooLong.tr);
      return;
    }
    final shortName = _shortName.text.trim();
    if (shortName.length > _maxShortNameLength) {
      setState(
        () => _shortNameError = TranslationKeys.teamShortNameTooLong.tr,
      );
      return;
    }
    final taken = widget.teams.teams.any(
      (team) => team.name.trim().toLowerCase() == name.toLowerCase(),
    );
    if (taken) {
      setState(
        () => _nameError = TranslationKeys.teamNameExists.trParams({
          'name': name,
        }),
      );
      return;
    }

    setState(() {
      _busy = true;
      _nameError = null;
      _shortNameError = null;
      _serverError = null;
    });

    final organizationId = _organizationId;
    final error = await widget.teams.createTeam(
      name: name,
      shortName: shortName.isEmpty ? null : shortName,
      organizationId: organizationId,
      organizationName: _selectedOrganizationName,
    );

    // The organization's team count changed whether or not the sheet is still
    // open, so this runs before the mounted check.
    if (error == null && organizationId != null) {
      widget.onOrganizationTeamCreated?.call(organizationId);
    }

    // The sheet may have been closed while the request ran; touching it or
    // popping a route now would act on whatever is on screen instead.
    if (!mounted) return;

    if (error == null) {
      widget.onCreated(organizationId);
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

    // Scrolls so that, with the keyboard up on a short phone, the sheet
    // shrinks around the form instead of overflowing and clipping Create.
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
            maxLength: _maxTeamNameLength,
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
            maxLength: _maxShortNameLength,
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
          if (widget.ownedOrganizations.isNotEmpty) ...[
            16.h,
            CricketText(
              text: TranslationKeys.teamBelongsTo.tr,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            8.h,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: CricketText(text: TranslationKeys.teamIndependent.tr),
                  selected: _organizationId == null,
                  onSelected: (_) => setState(() {
                    _organizationId = null;
                    _serverError = null;
                  }),
                ),
                for (final org in widget.ownedOrganizations)
                  ChoiceChip(
                    label: CricketText(text: org.name),
                    selected: _organizationId == org.id,
                    onSelected: (_) => setState(() {
                      _organizationId = org.id;
                      _serverError = null;
                    }),
                  ),
              ],
            ),
          ],
          if (_serverError != null) ...[
            12.h,
            CricketText(text: _serverError!, style: errorStyle),
          ],
          20.h,
          CricketButton(
            buttonText: TranslationKeys.createTeam.tr,
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
