import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/snackbars/cricket_snackbar.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/player_invite_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_player_invite.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/respond_to_player_invite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The invitee's side of a player invite: a scorer added them to a roster and
/// asked them to link that player to their account. Opened from a
/// `player_invite` notification (push in any app state, or an inbox row) via
/// `navigateForNotificationData`.
///
/// The invite is fetched fresh rather than read from the notification payload,
/// which is frozen at send time — it may already have been answered from
/// another device.
///
/// [reportResult] receives the server's own localized message once the sheet
/// has closed; it defaults to a snackbar and exists so a test can observe it,
/// since GetX doesn't render snackbars under test.
Future<void> showPlayerInviteSheet(
  String inviteId, {
  void Function(bool success, String? message)? reportResult,
}) async {
  await CustomBottomSheet.wrapBottomSheet<void>(
    headlineText: TranslationKeys.playerInviteTitle.tr,
    isDismissible: true,
    child: PlayerInviteSheetBody(
      inviteId: inviteId,
      reportResult: reportResult,
    ),
  );
}

void _showSnackbar(bool success, String? message) => success
    ? CricketSnackbar.showSuccessMessage(message)
    : CricketSnackbar.showErrorMessage(message);

class PlayerInviteSheetBody extends StatefulWidget {
  const PlayerInviteSheetBody({
    required this.inviteId,
    this.reportResult,
    super.key,
  });

  final String inviteId;
  final void Function(bool success, String? message)? reportResult;

  @override
  State<PlayerInviteSheetBody> createState() => _PlayerInviteSheetBodyState();
}

class _PlayerInviteSheetBodyState extends State<PlayerInviteSheetBody> {
  PlayerInviteRes? _invite;
  String? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final response = await Get.find<GetPlayerInviteUseCase>()(
      params: GetPlayerInviteParams(inviteId: widget.inviteId),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (response.isResult) {
        _invite = response.result.data;
      } else {
        _error = response.fallback.message;
      }
    });
  }

  Future<void> _respond({required bool accept}) async {
    if (_busy) return;
    setState(() => _busy = true);

    final response = await Get.find<RespondToPlayerInviteUseCase>()(
      params: RespondToPlayerInviteParams(
        inviteId: widget.inviteId,
        accept: accept,
      ),
    );

    if (!mounted) return;
    // Close the sheet before the snackbar: a GetX snackbar is a route, so a
    // `Get.back()` issued while one is showing would close the snackbar
    // instead. The message is the server's own, localized (e.g. a lost claim
    // race says the player was already claimed).
    Get.back<void>();
    (widget.reportResult ?? _showSnackbar)(
      response.isResult,
      response.isResult ? response.result.message : response.fallback.message,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final error = _error;
    if (error != null) {
      return CricketText(
        text: error,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.error,
        ),
      );
    }

    final invite = _invite!;
    if (!invite.isPending) {
      return CricketText(
        text: invite.status == 'accepted'
            ? TranslationKeys.inviteAlreadyAccepted.tr
            : TranslationKeys.inviteAlreadyDeclined.tr,
        textAlign: TextAlign.center,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CricketText(
          text: TranslationKeys.playerInviteMessage.trParams({
            'inviter': invite.invitedByName ?? '',
            'team': invite.teamName,
            'player': invite.playerName ?? '',
          }),
          textAlign: TextAlign.center,
        ),
        24.h,
        CricketButton(
          buttonText: TranslationKeys.acceptInvite.tr,
          isDisabled: _busy,
          onPressed: () => _respond(accept: true),
        ),
        12.h,
        OutlinedButton(
          onPressed: _busy ? null : () => _respond(accept: false),
          child: CricketText(text: TranslationKeys.declineInvite.tr),
        ),
      ],
    );
  }
}
