import 'dart:async';

import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
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
void navigateForNotificationData(Map<String, dynamic> data) {
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
