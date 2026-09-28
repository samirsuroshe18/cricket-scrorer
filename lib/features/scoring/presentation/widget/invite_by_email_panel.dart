import 'dart:async';

import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/bootom_sheets/custom_bottomsheet.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/looked_up_user_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Loose shape check that only gates the Find button; the server does the real
/// validation and answers the same `USER_NOT_FOUND` for anything it can't match.
final RegExp _looksLikeEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Opens [InviteByEmailPanel] in a bottom sheet, closing it once an invite has
/// been sent.
Future<void> showInviteByEmailSheet({
  required Future<(LookedUpUserRes?, String?)> Function(String email) lookup,
  required Future<String?> Function(String userId) invite,
}) async {
  await CustomBottomSheet.wrapBottomSheet<bool>(
    headlineText: TranslationKeys.inviteByEmail.tr,
    child: InviteByEmailPanel(
      lookup: lookup,
      invite: invite,
      onDone: () => Get.back<bool>(result: true),
    ),
  );
}

/// Find a registered app user by exact email, confirm who they are, then send
/// them a team invite. Shared by the Team Profile add-player sheet and the
/// Squad screen; it knows nothing about either controller — both hand it
/// [lookup] / [invite] callbacks.
///
/// Server errors are shown inline, never as a snackbar: a GetX snackbar is a
/// route, so `Get.back()` after one would close the snackbar instead of the
/// sheet. [lookup] returns `(user, null)` or `(null, message)`; [invite]
/// returns null on success or the server's own message.
class InviteByEmailPanel extends StatefulWidget {
  const InviteByEmailPanel({
    required this.lookup,
    required this.invite,
    required this.onDone,
    super.key,
  });

  final Future<(LookedUpUserRes?, String?)> Function(String email) lookup;
  final Future<String?> Function(String userId) invite;

  /// Called once an invite has been sent; closes the sheet.
  final VoidCallback onDone;

  @override
  State<InviteByEmailPanel> createState() => _InviteByEmailPanelState();
}

class _InviteByEmailPanelState extends State<InviteByEmailPanel> {
  final _email = TextEditingController();

  LookedUpUserRes? _found;
  String? _lookupError;
  bool _lookingUp = false;

  /// Bumped whenever the email is edited or a lookup starts. A lookup only
  /// applies if it is still the latest, so an answer for an address the scorer
  /// has since changed can never surface a card — and an Invite button — for
  /// someone they did not ask about.
  int _lookupGeneration = 0;
  bool _inviting = false;
  String? _inviteError;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    if (_lookingUp) return;
    final generation = ++_lookupGeneration;
    setState(() {
      _lookingUp = true;
      _found = null;
      _lookupError = null;
      _inviteError = null;
    });

    final (user, error) = await widget.lookup(_email.text.trim());

    if (!mounted || generation != _lookupGeneration) return;
    setState(() {
      _lookingUp = false;
      _found = user;
      _lookupError = error;
    });
  }

  Future<void> _invite(LookedUpUserRes user) async {
    if (_inviting) return;
    setState(() {
      _inviting = true;
      _inviteError = null;
    });

    final error = await widget.invite(user.userId);

    if (!mounted) return;
    if (error == null) {
      widget.onDone();
    } else {
      setState(() {
        _inviting = false;
        _inviteError = error;
      });
    }
  }

  Widget _errorLine(BuildContext context, String message) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: CricketText(
      text: message,
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colorScheme.error,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final user = _found;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CricketText(
          text: TranslationKeys.findUserByEmailHint.tr,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        8.h,
        CricketTextField(
          controller: _email,
          hintText: TranslationKeys.email.tr,
          labelText: TranslationKeys.email.tr,
          prefixIcon: const Icon(Icons.mail_outline),
          keyboardType: TextInputType.emailAddress,
          hideCounter: true,
          onChanged: (_) => setState(() {
            _lookupGeneration++;
            _lookingUp = false;
            _found = null;
            _lookupError = null;
            _inviteError = null;
          }),
        ),
        12.h,
        CricketButton(
          buttonText: TranslationKeys.findUser.tr,
          isDisabled:
              _lookingUp || !_looksLikeEmail.hasMatch(_email.text.trim()),
          onPressed: _find,
        ),
        if (_lookupError != null) _errorLine(context, _lookupError!),
        if (user != null) ...[
          12.h,
          _userCard(user),
          if (_inviteError != null) _errorLine(context, _inviteError!),
        ],
      ],
    );
  }

  Widget _userCard(LookedUpUserRes user) {
    final photo = user.photoUrl;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          foregroundImage: photo != null ? NetworkImage(photo) : null,
          child: CricketText(
            text: user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
          ),
        ),
        title: CricketText(text: user.fullName),
        subtitle: user.userName == null
            ? null
            : CricketText(text: '@${user.userName}'),
        trailing: _inviting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                key: const ValueKey('invite-user'),
                onPressed: () => _invite(user),
                child: CricketText(text: TranslationKeys.invite.tr),
              ),
      ),
    );
  }
}
