import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The two opening batsmen **and the opening bowler**. Blocking and
/// undismissable: the server rejects every delivery with `INNINGS_NOT_STARTED`
/// until this succeeds, so there is nothing useful behind it to return to.
///
/// The bowler is collected here rather than through the next-bowler sheet
/// because `start-innings` now requires him — which also means the openers
/// prompt and the bowler prompt can never compete to open at the start of an
/// innings. Law 17.6 excludes nobody from over 1, so this field has no greyed
/// state; the exclusion only exists from over 2 onward.
///
/// Driven by the server reporting no strike rather than by which screen the
/// scorer arrived from, so it also covers resuming a match whose innings was
/// never opened.
///
/// **Each opener role can be picked from a roster, not just typed** — the same
/// chip-plus-text-field pattern `NextBowlerBottomSheet` already uses for a
/// returning bowler. [battingRoster] backs the striker and non-striker
/// pickers, [bowlingRoster] backs the opening-bowler picker; either can be
/// empty (a brand-new team, or a best-effort fetch that failed), in which
/// case that section falls back to a bare text field exactly as before —
/// nothing here is ever a closed or mandatory list.
class OpenersBottomSheet extends StatefulWidget {
  const OpenersBottomSheet({
    required this.onSubmit,
    required this.isSubmitting,
    required this.canUndo,
    required this.isUndoing,
    required this.onUndo,
    this.battingRoster = const [],
    this.bowlingRoster = const [],
    this.lockToRoster = false,
    this.previousInningsRuns,
    this.previousInningsWickets,
    this.previousInningsOvers,
    super.key,
  });

  /// Returns true once the innings is open. While it returns false the sheet
  /// stays up with the entered names intact, so a rejected name is corrected
  /// rather than retyped.
  ///
  /// Each `*Id` is what tells the server "this exact rostered player" apart
  /// from "a new player who happens to share a name" — see [battingRoster]/
  /// [bowlingRoster]. Sent only when the corresponding field still reads
  /// exactly as picked; see `_submit`.
  final Future<bool> Function(
    String strikerName,
    String nonStrikerName,
    String bowlerName, {
    String? strikerId,
    String? nonStrikerId,
    String? bowlerId,
  })
  onSubmit;

  /// Button-level loading, owned by the controller.
  final RxBool isSubmitting;

  /// The batting side's roster, for the striker and non-striker pickers.
  final List<TeamRosterPlayer> battingRoster;

  /// The bowling side's roster, for the opening-bowler picker.
  final List<TeamRosterPlayer> bowlingRoster;

  /// True when a Playing XI is set for the side(s): the rosters above are then
  /// the XI, the server refuses anyone else, and the name fields stop taking
  /// typing so a chip is the only way to fill them.
  final bool lockToRoster;

  /// Innings 1's final score, shown above the form so a mis-tapped last ball
  /// is visible before the scorer commits to opening innings 2 — the point at
  /// which undoing it stops being reachable from here (see [canUndo]/
  /// [onUndo]). Null for the very first innings, where there is nothing to
  /// show; all three are supplied together or not at all.
  final int? previousInningsRuns;
  final int? previousInningsWickets;
  final String? previousInningsOvers;

  /// Whether there is a delivery to take back. Same signature as
  /// [NextBowlerBottomSheet]'s, and false for exactly the same reason on a
  /// fresh first innings: nothing has been scored yet.
  final bool Function() canUndo;

  /// In-flight flag for [onUndo], owned by the controller.
  final RxBool isUndoing;

  /// Takes back the most recent delivery. For innings 1's final ball this is
  /// the only way out — see the class doc.
  final Future<bool> Function() onUndo;

  static Future<void> show({
    required Future<bool> Function(
      String,
      String,
      String, {
      String? strikerId,
      String? nonStrikerId,
      String? bowlerId,
    })
    onSubmit,
    required RxBool isSubmitting,
    required bool Function() canUndo,
    required RxBool isUndoing,
    required Future<bool> Function() onUndo,
    List<TeamRosterPlayer> battingRoster = const [],
    List<TeamRosterPlayer> bowlingRoster = const [],
    bool lockToRoster = false,
    int? previousInningsRuns,
    int? previousInningsWickets,
    String? previousInningsOvers,
  }) {
    return CustomBottomSheet.cricketCustomBottomSheet<void>(
      headlineText: TranslationKeys.openingPlayers.tr,
      isXButtonRequired: false,
      isDismissible: false,
      heightFactor: 0.7,
      child: OpenersBottomSheet(
        onSubmit: onSubmit,
        isSubmitting: isSubmitting,
        canUndo: canUndo,
        isUndoing: isUndoing,
        onUndo: onUndo,
        battingRoster: battingRoster,
        bowlingRoster: bowlingRoster,
        lockToRoster: lockToRoster,
        previousInningsRuns: previousInningsRuns,
        previousInningsWickets: previousInningsWickets,
        previousInningsOvers: previousInningsOvers,
      ),
    );
  }

  @override
  State<OpenersBottomSheet> createState() => _OpenersBottomSheetState();
}

class _OpenersBottomSheetState extends State<OpenersBottomSheet> {
  final _strikerController = TextEditingController();
  final _nonStrikerController = TextEditingController();
  final _bowlerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// The chip most recently tapped for each role, if that role's field still
  /// reads exactly as it left it — see `_submit`. Cleared implicitly by
  /// comparison, not by a text listener, same as `NextBowlerBottomSheet`'s
  /// `_picked`.
  TeamRosterPlayer? _strikerPicked;
  TeamRosterPlayer? _nonStrikerPicked;
  TeamRosterPlayer? _bowlerPicked;

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.batsmanNameRequired.tr;
    }
    return null;
  }

  String? _validateBowler(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.bowlerNameRequired.tr;
    }
    return null;
  }

  void _pickStriker(TeamRosterPlayer player) {
    setState(() {
      _strikerController.text = player.playerName;
      _strikerController.selection = TextSelection.collapsed(
        offset: player.playerName.length,
      );
      _strikerPicked = player;
    });
  }

  void _pickNonStriker(TeamRosterPlayer player) {
    setState(() {
      _nonStrikerController.text = player.playerName;
      _nonStrikerController.selection = TextSelection.collapsed(
        offset: player.playerName.length,
      );
      _nonStrikerPicked = player;
    });
  }

  void _pickBowler(TeamRosterPlayer player) {
    setState(() {
      _bowlerController.text = player.playerName;
      _bowlerController.selection = TextSelection.collapsed(
        offset: player.playerName.length,
      );
      _bowlerPicked = player;
    });
  }

  /// Only sent when the field still reads exactly as the tap left it — a
  /// scorer who picks a chip and then edits the name is typing someone else,
  /// and that must reach the server as a bare name, not the chip's id. Same
  /// reasoning as `NextBowlerBottomSheet._submit`.
  String? _idFor(TeamRosterPlayer? picked, String currentText) =>
      (picked != null && picked.playerName == currentText)
      ? picked.playerId
      : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final striker = _strikerController.text.trim();
    final nonStriker = _nonStrikerController.text.trim();
    final bowler = _bowlerController.text.trim();

    // Same rule the server applies to openers, checked here so the scorer sees
    // it without a round trip. The bowler is on the other side, so no
    // must-differ check applies to him — a shared name there is two different
    // Player documents, one per team.
    if (striker.toLowerCase() == nonStriker.toLowerCase()) {
      CricketSnackbar.showAlertMessage(TranslationKeys.batsmenMustDiffer.tr);
      return;
    }

    // Navigator.pop rather than Get.back(): GetX's `back()` treats an open
    // snackbar as higher priority than the pop itself — if the "Live
    // connection lost" snackbar (score_ball_controller.dart) happens to be
    // showing at this exact moment, which it routinely is immediately after
    // completing an innings offline, `Get.back()` closes only the snackbar
    // and returns, leaving this sheet stuck open even though the innings
    // had already opened successfully (online or via the offline branch).
    // Popping this sheet's own route directly is unaffected by any overlay
    // elsewhere. See wicket_bottom_sheet.dart/next_bowler_bottom_sheet.dart
    // for the same fix applied earlier.
    final success = await widget.onSubmit(
      striker,
      nonStriker,
      bowler,
      strikerId: _idFor(_strikerPicked, striker),
      nonStrikerId: _idFor(_nonStrikerPicked, nonStriker),
      bowlerId: _idFor(_bowlerPicked, bowler),
    );
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  /// The way out of a mis-tapped final ball of the previous innings.
  ///
  /// This sheet is undismissable, so once it is up — meaning innings 1 has
  /// already completed — the console's own undo control is unreachable
  /// behind it — see next_bowler_bottom_sheet.dart's identical `_undo` for
  /// the same reasoning applied to the over boundary.
  Future<void> _undo() async {
    // Navigator.pop, not Get.back() — same snackbar hazard as `_submit`.
    if (await widget.onUndo() && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _strikerController.dispose();
    _nonStrikerController.dispose();
    _bowlerController.dispose();
    super.dispose();
  }

  /// One picker section: an optional hint + chip row drawn from [roster]
  /// (nothing rendered when it's empty, so an unfetched/empty roster falls
  /// back to a bare text field exactly as before), followed by the text
  /// field itself. [isBlocked] greys a chip that's already picked for the
  /// other opener role — never applied to the bowler picker, which has no
  /// must-differ rule against the openers.
  Widget _pickerSection({
    required Key key,
    required List<TeamRosterPlayer> roster,
    required TextEditingController controller,
    required void Function(TeamRosterPlayer) onPick,
    required String labelText,
    required String hintText,
    required String? Function(String?) validator,
    bool Function(TeamRosterPlayer) isBlocked = _neverBlocked,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (roster.isNotEmpty) ...[
          CricketText(
            text: TranslationKeys.pickPlayerOrTypeNew.tr,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          8.h,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roster.map((player) {
              final blocked = isBlocked(player);
              return ChoiceChip(
                label: CricketText(text: player.playerName),
                selected: controller.text.trim() == player.playerName,
                onSelected: blocked ? null : (_) => onPick(player),
              );
            }).toList(),
          ),
          8.h,
        ],
        CricketTextField(
          controller: controller,
          labelText: labelText,
          hintText: hintText,
          textCapitalization: TextCapitalization.words,
          maxLength: 50,
          isRequired: true,
          readOnly: widget.lockToRoster,
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final runs = widget.previousInningsRuns;
    final wickets = widget.previousInningsWickets;
    final overs = widget.previousInningsOvers;
    final hasPreviousInnings = runs != null && wickets != null && overs != null;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (hasPreviousInnings) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: context.colors.statusInfo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CricketText(
                  text:
                      '${TranslationKeys.inningsOneComplete.tr}: '
                      '$runs/$wickets ($overs ${TranslationKeys.overs.tr})',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.colors.statusInfo,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              16.h,
            ],
            _pickerSection(
              key: const ValueKey('opener-picker-striker'),
              roster: widget.battingRoster,
              controller: _strikerController,
              onPick: _pickStriker,
              labelText: TranslationKeys.striker.tr,
              hintText: TranslationKeys.enterStrikerName.tr,
              validator: _validateName,
              isBlocked: (player) =>
                  player.playerName == _nonStrikerController.text.trim(),
            ),
            16.h,
            _pickerSection(
              key: const ValueKey('opener-picker-non-striker'),
              roster: widget.battingRoster,
              controller: _nonStrikerController,
              onPick: _pickNonStriker,
              labelText: TranslationKeys.nonStriker.tr,
              hintText: TranslationKeys.enterNonStrikerName.tr,
              validator: _validateName,
              isBlocked: (player) =>
                  player.playerName == _strikerController.text.trim(),
            ),
            16.h,
            _pickerSection(
              key: const ValueKey('opener-picker-bowler'),
              roster: widget.bowlingRoster,
              controller: _bowlerController,
              onPick: _pickBowler,
              labelText: TranslationKeys.openingBowler.tr,
              hintText: TranslationKeys.enterBowlerName.tr,
              validator: _validateBowler,
            ),
            24.h,
            Obx(
              () => CricketButton(
                buttonText: TranslationKeys.startInnings.tr,
                isDisabled: widget.isSubmitting.value,
                onPressed: () => unawaited(_submit()),
              ),
            ),

            // Same reasoning and the same Obx-around-both-checks structure as
            // next_bowler_bottom_sheet.dart's identical block: `canUndo()`
            // reads Rx state internally, so it needs to live inside the Obx
            // too or this link's visibility goes stale while the
            // (undismissable) sheet is open.
            Obx(
              () => widget.canUndo()
                  ? Column(
                      children: [
                        8.h,
                        Center(
                          child: TextButton(
                            onPressed: widget.isUndoing.value
                                ? null
                                : () => unawaited(_undo()),
                            child: CricketText(
                              text: TranslationKeys.undoLastBall.tr,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            16.h,
          ],
        ),
      ),
    );
  }
}

bool _neverBlocked(TeamRosterPlayer player) => false;
