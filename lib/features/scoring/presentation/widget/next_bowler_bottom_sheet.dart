import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/domain/bowler_ref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Who bowls the next over. Opens the moment an over ends and blocks until it
/// is answered — the server refuses every delivery with `BOWLER_NOT_SELECTED`
/// meanwhile, so there is nothing useful behind it to return to.
///
/// **The previous over's bowler is shown and greyed, not hidden.** Law 17.6
/// says he cannot bowl two overs running, and the server enforces that with
/// `BOWLER_CANNOT_BOWL_CONSECUTIVE_OVERS`. Hiding him would leave a scorer
/// hunting for a name that ought to be there; greying him with a reason answers
/// the question before it is asked. This mirrors how the wicket sheet treats
/// dismissal types that are impossible off the armed delivery.
///
/// **The name field is not a convenience — it is what stops this being a dead
/// end.** Nothing but `start-innings` and `select-bowler` ever creates a Player
/// on the bowling side, so there is no roster to list: [knownBowlers] holds
/// only bowlers seen this innings, and on a fresh app launch mid-match that can
/// be a single name — the greyed one. The field is always present and always
/// enabled.
class NextBowlerBottomSheet extends StatefulWidget {
  const NextBowlerBottomSheet({
    required this.excludedBowlerName,
    required this.knownBowlers,
    required this.isSubmitting,
    required this.onSubmit,
    required this.canUndo,
    required this.isUndoing,
    required this.onUndo,
    super.key,
  });

  /// Whom the server will refuse, straight from `nextBowler.excludedBowlerName`.
  /// Null only if the server sent no exclusion, in which case nothing is greyed.
  final String? excludedBowlerName;

  /// Bowlers seen this innings. A shortcut, not a roster — see the class doc.
  final List<BowlerRef> knownBowlers;

  /// Button-level loading, owned by the controller.
  final RxBool isSubmitting;

  /// Returns true once the server accepts the bowler. While it returns false
  /// the sheet stays up with the typed name intact, so a rejected name is
  /// corrected rather than retyped.
  ///
  /// [bowlerId] is what tells the server this is a known bowler returning,
  /// not a new player who happens to share a name — see [BowlerRef]. Sent
  /// only when the text still reads exactly as picked; see [_submit].
  final Future<bool> Function(String bowlerName, {String? bowlerId}) onSubmit;

  /// Whether there is a delivery to take back. False on a resumed match, where
  /// the console never saw an ack for the ball that ended the over.
  final bool Function() canUndo;

  /// In-flight flag for [onUndo], owned by the controller.
  final RxBool isUndoing;

  /// Takes back the delivery that ended the over. Returns true once the server
  /// has accepted it, at which point the sheet closes itself — the over is
  /// unfinished again and nobody is owed.
  final Future<bool> Function() onUndo;

  static Future<void> show({
    required String? excludedBowlerName,
    required List<BowlerRef> knownBowlers,
    required RxBool isSubmitting,
    required Future<bool> Function(String bowlerName, {String? bowlerId})
    onSubmit,
    required bool Function() canUndo,
    required RxBool isUndoing,
    required Future<bool> Function() onUndo,
  }) {
    return CustomBottomSheet.cricketCustomBottomSheet<void>(
      headlineText: TranslationKeys.selectBowler.tr,
      isXButtonRequired: false,
      isDismissible: false,
      heightFactor: 0.6,
      child: NextBowlerBottomSheet(
        excludedBowlerName: excludedBowlerName,
        knownBowlers: knownBowlers,
        isSubmitting: isSubmitting,
        onSubmit: onSubmit,
        canUndo: canUndo,
        isUndoing: isUndoing,
        onUndo: onUndo,
      ),
    );
  }

  @override
  State<NextBowlerBottomSheet> createState() => _NextBowlerBottomSheetState();
}

class _NextBowlerBottomSheetState extends State<NextBowlerBottomSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// The chip most recently tapped, if the field still reads exactly as it
  /// left it — see [_submit]. Cleared implicitly by comparison, not by a
  /// text listener: editing the field away from the picked name doesn't
  /// need its own handler, `_submit` simply stops finding a match.
  BowlerRef? _picked;

  bool _isExcluded(String name) {
    final excluded = widget.excludedBowlerName?.trim().toLowerCase();
    if (excluded == null || excluded.isEmpty) return false;
    return name.trim().toLowerCase() == excluded;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.bowlerNameRequired.tr;
    }
    return null;
  }

  /// Tapping a chip fills the field rather than submitting, so the chips and
  /// the field are one input with one confirm — a scorer can pick a name and
  /// still correct a typo in it before sending.
  void _pick(BowlerRef bowler) {
    setState(() {
      _controller.text = bowler.name;
      _controller.selection = TextSelection.collapsed(
        offset: bowler.name.length,
      );
      _picked = bowler;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _controller.text.trim();

    // The same rule the server applies, checked here so the scorer sees it
    // without a round trip. The server rejects it independently — this is a
    // shortcut, never the enforcement.
    if (_isExcluded(name)) {
      CricketSnackbar.showAlertMessage(
        TranslationKeys.cannotBowlConsecutiveOvers.tr,
      );
      return;
    }

    // Only sent when the field still reads exactly as the tap left it — a
    // scorer who picks a chip and then edits the name is typing someone
    // else, and that must reach the server as a bare name, not the chip's
    // id. This is what tells the server "this exact returning bowler" apart
    // from "a new player who happens to share a name".
    final picked = _picked;
    final bowlerId = (picked != null && picked.name == name)
        ? picked.id
        : null;

    // Navigator.pop rather than Get.back() — see _undo()'s comment below for
    // why: GetX's `back()` closes an open snackbar instead of this sheet
    // whenever one happens to be showing.
    if (await widget.onSubmit(name, bowlerId: bowlerId) && mounted) {
      Navigator.of(context).pop();
    }
  }

  /// The way out of a mis-tapped last ball.
  ///
  /// This sheet is deliberately undismissable — the server refuses every
  /// delivery until a bowler is named, so there is nothing useful behind it.
  /// But that also means a scorer who ended the over by accident cannot reach
  /// the console's undo control, which sits in the app bar behind this. Without
  /// this button the only way out would be to name a bowler you did not want,
  /// bowl a ball you did not want, and then undo twice.
  ///
  /// Closing on success rather than waiting for the controller: undo restores
  /// the bowler the over already had, so nobody is owed and this sheet has
  /// nothing left to ask.
  Future<void> _undo() async {
    // Navigator.pop, not Get.back(): GetX's `back()` special-cases an open
    // snackbar and closes that instead of popping, unconditionally, before
    // it ever looks at the navigator — see extension_navigation.dart's
    // `back<T>()`. Offline, the "Live connection lost" snackbar
    // (score_ball_controller.dart) can be showing at exactly this moment on
    // every failed reconnect attempt, which made this sheet stay open with
    // stale over/bowler state even though the undo had already succeeded.
    // Popping this sheet's own route directly sidesteps that entirely.
    if (await widget.onUndo() && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final excluded = widget.excludedBowlerName;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CricketText(
              text: TranslationKeys.chooseBowler.tr,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),

            if (widget.knownBowlers.isNotEmpty) ...[
              16.h,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.knownBowlers.map((BowlerRef bowler) {
                  final blocked = _isExcluded(bowler.name);
                  return ChoiceChip(
                    label: CricketText(text: bowler.name),
                    selected: _controller.text.trim() == bowler.name,
                    // Greyed, not removed. `onSelected: null` is what disables a
                    // chip in Material; the reason line below says why.
                    onSelected: blocked ? null : (_) => _pick(bowler),
                  );
                }).toList(),
              ),
            ],

            if (excluded != null && excluded.isNotEmpty) ...[
              8.h,
              CricketText(
                text: TranslationKeys.cannotBowlConsecutiveOvers.tr,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            16.h,
            CricketTextField(
              controller: _controller,
              labelText: TranslationKeys.bowlerName.tr,
              hintText: TranslationKeys.enterBowlerName.tr,
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
              isRequired: true,
              validator: _validateName,
            ),

            24.h,
            Obx(
              () => CricketButton(
                buttonText: TranslationKeys.selectBowler.tr,
                isDisabled: widget.isSubmitting.value,
                onPressed: () => unawaited(_submit()),
              ),
            ),

            // A single Obx around both the visibility check and the button
            // itself — `canUndo()` reads Rx state internally (queue/ledger
            // counts), so evaluating it inside build() only, outside any
            // Obx, left this link's visibility stale if that state changed
            // while the (undismissable) sheet was already open.
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
