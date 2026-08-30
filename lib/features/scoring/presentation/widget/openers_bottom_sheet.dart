import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
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
class OpenersBottomSheet extends StatefulWidget {
  const OpenersBottomSheet({
    required this.onSubmit,
    required this.isSubmitting,
    super.key,
  });

  /// Returns true once the innings is open. While it returns false the sheet
  /// stays up with the entered names intact, so a rejected name is corrected
  /// rather than retyped.
  final Future<bool> Function(
    String strikerName,
    String nonStrikerName,
    String bowlerName,
  )
  onSubmit;

  /// Button-level loading, owned by the controller.
  final RxBool isSubmitting;

  static Future<void> show({
    required Future<bool> Function(String, String, String) onSubmit,
    required RxBool isSubmitting,
  }) {
    return CustomBottomSheet.cricketCustomBottomSheet<void>(
      headlineText: TranslationKeys.openingPlayers.tr,
      isXButtonRequired: false,
      isDismissible: false,
      heightFactor: 0.7,
      child: OpenersBottomSheet(onSubmit: onSubmit, isSubmitting: isSubmitting),
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
    if (await widget.onSubmit(striker, nonStriker, bowler) && mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            CricketTextField(
              controller: _strikerController,
              labelText: TranslationKeys.striker.tr,
              hintText: TranslationKeys.enterStrikerName.tr,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              isRequired: true,
              validator: _validateName,
            ),
            16.h,
            CricketTextField(
              controller: _nonStrikerController,
              labelText: TranslationKeys.nonStriker.tr,
              hintText: TranslationKeys.enterNonStrikerName.tr,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              isRequired: true,
              validator: _validateName,
            ),
            16.h,
            CricketTextField(
              controller: _bowlerController,
              labelText: TranslationKeys.openingBowler.tr,
              hintText: TranslationKeys.enterBowlerName.tr,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              isRequired: true,
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
          ],
        ),
      ),
    );
  }
}
