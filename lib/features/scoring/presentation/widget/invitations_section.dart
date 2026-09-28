import 'package:cricket_scorer/core/extensions/space_extension.dart';
import 'package:cricket_scorer/core/extensions/theme_x.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_text.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_invites_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The team's invitations and how each was answered — waiting, accepted or
/// declined — for the scorer. Renders nothing when there are none. A waiting
/// invite can be cancelled; a declined one can be sent again. An accepted one is
/// informational: that player is already on the team.
class InvitationsSection extends StatelessWidget {
  const InvitationsSection({
    required this.invites,
    required this.onCancel,
    required this.onInviteAgain,
    super.key,
  });

  final List<TeamInviteItemRes> invites;
  final ValueChanged<TeamInviteItemRes> onCancel;
  final ValueChanged<TeamInviteItemRes> onInviteAgain;

  @override
  Widget build(BuildContext context) {
    if (invites.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CricketText(
          text: TranslationKeys.squadInvitations.tr,
          style: context.textTheme.titleSmall,
        ),
        8.h,
        for (final invite in invites) _InviteRow(invite: invite, section: this),
      ],
    );
  }
}

class _InviteRow extends StatelessWidget {
  const _InviteRow({required this.invite, required this.section});

  final TeamInviteItemRes invite;
  final InvitationsSection section;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (invite.status) {
      'accepted' => (
        TranslationKeys.inviteStatusAccepted,
        context.colors.statusSuccess,
      ),
      'declined' => (
        TranslationKeys.inviteStatusDeclined,
        context.colors.statusDanger,
      ),
      _ => (
        TranslationKeys.inviteStatusWaiting,
        context.colors.statusWarning,
      ),
    };

    return Card(
      key: Key('invite_row_${invite.inviteId}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        title: CricketText(text: invite.invitee.fullName),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: 8.radius,
            ),
            child: CricketText(
              text: label.tr,
              style: context.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ),
        trailing: switch (invite.status) {
          'pending' => TextButton(
            key: Key('invite_cancel_${invite.inviteId}'),
            onPressed: () => section.onCancel(invite),
            child: CricketText(text: TranslationKeys.cancelInvite.tr),
          ),
          'declined' => TextButton(
            key: Key('invite_again_${invite.inviteId}'),
            onPressed: () => section.onInviteAgain(invite),
            child: CricketText(text: TranslationKeys.inviteAgain.tr),
          ),
          _ => null,
        },
      ),
    );
  }
}
