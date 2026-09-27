import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
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
void navigateForNotificationData(
  Map<String, dynamic> data, {
  Future<void> Function(String inviteId)? showInvite,
}) {
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
