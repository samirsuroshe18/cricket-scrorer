import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:cricket_scorer/features/notifications/presentation/widget/player_invite_sheet.dart';
import 'package:get/get.dart';

/// Where a tap on a notification (a push, in any app state, or a row in the
/// in-app inbox) should land — one shared decision, used from
/// `FirebaseService.onMessageOpenedApp`, `NotificationService`'s local-tap
/// callback, and `NotificationsScreen`'s own row tap, so the three can never
/// disagree about what a given payload means.
///
/// Resuming a *specific* match correctly (live vs. completed) needs the
/// full `MatchHistoryItem` `HomeController.openMatch` already knows how to
/// route from — duplicating that from just a bare `matchId` risks the two
/// falling out of sync. Landing on the Matches tab instead means the real
/// card, and its already-correct routing, is one tap away.
///
/// A `player_invite` payload (`inviteId`) opens the invitee's Accept / Decline
/// sheet instead; [showInvite] exists so a test can observe that decision
/// without a live bottom sheet.
///
/// The **inviter's** side of the same flow — `player_invite_accepted` /
/// `player_invite_declined` — is decided by `type` *first*, ahead of the
/// `inviteId` check: it opens that team's profile ([showTeamProfile] for tests)
/// and never the invitee's sheet, whatever else the payload carries. Without a
/// usable `teamId` it does nothing.
void navigateForNotificationData(
  Map<String, dynamic> data, {
  Future<void> Function(String inviteId)? showInvite,
  void Function(String teamId)? showTeamProfile,
}) {
  final type = data['type'];
  if (type == 'player_invite_accepted' || type == 'player_invite_declined') {
    final teamId = data['teamId'];
    if (teamId is String && teamId.isNotEmpty) {
      (showTeamProfile ?? _openTeamProfile)(teamId);
    }
    return;
  }

  final inviteId = data['inviteId'];
  if (inviteId is String && inviteId.isNotEmpty) {
    unawaited((showInvite ?? showPlayerInviteSheet)(inviteId));
    return;
  }

  final matchId = data['matchId'];
  if (matchId is String && matchId.isNotEmpty) {
    if (!Get.isRegistered<MainShellController>()) return;
    Get.find<MainShellController>().showTab(1);
    if (Get.currentRoute != AppRoutes.home) {
      unawaited(Get.offAllNamed<dynamic>(AppRoutes.home));
    }
    return;
  }

  final tournamentId = data['tournamentId'];
  if (tournamentId is String && tournamentId.isNotEmpty) {
    unawaited(
      Get.toNamed<dynamic>(AppRoutes.tournamentDetailPath(tournamentId)),
    );
  }
}

void _openTeamProfile(String teamId) {
  unawaited(Get.toNamed<dynamic>(AppRoutes.teamProfilePath(teamId)));
}

/// For a push that arrives while the app is open: an invite accepted or
/// declined bumps [NotificationsController.inviteResponseTick], which the Squad
/// screen watches to re-read its invitations. Anything else — or no
/// notifications controller yet (before the home shell is up) — does nothing.
void refreshOnInviteResponse(Map<String, dynamic> data) {
  final type = data['type'];
  if (type != 'player_invite_accepted' && type != 'player_invite_declined') {
    return;
  }
  if (!Get.isRegistered<NotificationsController>()) return;
  Get.find<NotificationsController>().notifyInviteResponse();
}
