import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/auth/data/profile_constants.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/career_stats_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/controllers/player_stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Player.role's wire values (see docs/api.md's `PLAYER_ROLES`) — not
/// exposed as a Dart constant class elsewhere, so kept here beside the one
/// place that edits it, same as `BattingStyle`/`BowlingStyle` (which live
/// in `profile_constants.dart` because they're shared with the User-profile
/// screen; roles aren't).
const List<String> _playerRoles = [
  'batsman', 'bowler', 'allrounder', 'wicketkeeper', 'unknown',
];

const Map<String, String> _roleLabels = <String, String>{
  'batsman': TranslationKeys.roleBatsman,
  'bowler': TranslationKeys.roleBowler,
  'allrounder': TranslationKeys.roleAllrounder,
  'wicketkeeper': TranslationKeys.roleWicketkeeper,
  'unknown': TranslationKeys.roleUnknown,
};

const Map<String, String> _battingStyleLabels = <String, String>{
  BattingStyle.rightHanded: TranslationKeys.rightHanded,
  BattingStyle.leftHanded: TranslationKeys.leftHanded,
};

const Map<String, String> _bowlingStyleLabels = <String, String>{
  BowlingStyle.rightArmPace: TranslationKeys.rightArmPace,
  BowlingStyle.leftArmPace: TranslationKeys.leftArmPace,
  BowlingStyle.rightArmSpin: TranslationKeys.rightArmSpin,
  BowlingStyle.leftArmSpin: TranslationKeys.leftArmSpin,
};

/// Edits a Player's profile — reachable only from `PlayerStatsScreen`, which
/// only ever loads successfully for a Player the current scorer owns (a
/// different scorer's Player 403s before this screen renders at all), so
/// there's no separate ownership check to make here.
Future<void> showEditPlayerProfileSheet({
  required PlayerStatsController controller,
  required CareerStatsRes stats,
}) async {
  final jerseyController = TextEditingController(
    text: stats.jerseyNumber?.toString() ?? '',
  );
  final bioController = TextEditingController(text: stats.bio ?? '');
  var selectedRole = stats.role;
  var selectedBattingStyle = stats.battingStyle;
  var selectedBowlingStyle = stats.bowlingStyle;

  final updated = await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.editPlayer.tr,
    child: StatefulBuilder(
      builder: (context, setSheetState) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketText(text: TranslationKeys.role.tr),
            8.h,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _playerRoles.map((role) {
                return ChoiceChip(
                  label: CricketText(text: _roleLabels[role]!.tr),
                  selected: selectedRole == role,
                  onSelected: (_) => setSheetState(() => selectedRole = role),
                );
              }).toList(),
            ),
            16.h,
            CricketTextField(
              controller: jerseyController,
              hintText: TranslationKeys.jerseyNumber.tr,
              labelText: TranslationKeys.jerseyNumber.tr,
              prefixIcon: const Icon(Icons.tag),
              keyboardType: TextInputType.number,
              maxLength: 3,
            ),
            16.h,
            CricketTextField(
              controller: bioController,
              hintText: TranslationKeys.tellUsAboutYourself.tr,
              labelText: TranslationKeys.bio.tr,
              prefixIcon: const Icon(Icons.person_outline),
              maxLines: 4,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
            ),
            16.h,
            CricketText(text: TranslationKeys.battingStyle.tr),
            8.h,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BattingStyle.all.map((style) {
                return ChoiceChip(
                  label: CricketText(text: _battingStyleLabels[style]!.tr),
                  selected: selectedBattingStyle == style,
                  onSelected: (_) =>
                      setSheetState(() => selectedBattingStyle = style),
                );
              }).toList(),
            ),
            16.h,
            CricketText(text: TranslationKeys.bowlingStyle.tr),
            8.h,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BowlingStyle.all.map((style) {
                return ChoiceChip(
                  label: CricketText(text: _bowlingStyleLabels[style]!.tr),
                  selected: selectedBowlingStyle == style,
                  onSelected: (_) =>
                      setSheetState(() => selectedBowlingStyle = style),
                );
              }).toList(),
            ),
            20.h,
            CricketButton(
              buttonText: TranslationKeys.saveChanges.tr,
              onPressed: () async {
                final jerseyText = jerseyController.text.trim();
                final success = await controller.updateProfile(
                  role: selectedRole,
                  jerseyNumber: jerseyText.isEmpty
                      ? null
                      : int.tryParse(jerseyText),
                  bio: bioController.text.trim(),
                  battingStyle: selectedBattingStyle,
                  bowlingStyle: selectedBowlingStyle,
                );
                if (success) {
                  Get.back<bool>(result: true);
                } else {
                  CricketSnackbar.showErrorMessage(
                    TranslationKeys.somethingWentWrong.tr,
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );

  if (updated == true) {
    CricketSnackbar.showSuccessMessage(TranslationKeys.playerUpdated.tr);
  }
}
