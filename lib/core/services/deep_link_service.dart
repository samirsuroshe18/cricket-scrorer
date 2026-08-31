import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/core/utils/pending_deep_link.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Handles a spectator share-link tap while the app is already running
/// (foregrounded or backgrounded) — the warm-launch counterpart to
/// `PendingDeepLink`'s cold-start read.
///
/// `AndroidManifest.xml`'s `launchMode="singleTop"` means a second tap on the
/// share link is delivered to the existing activity via `onNewIntent`, never
/// a fresh `onCreate`. `AppLinks().getInitialLink()` — what `PendingDeepLink`
/// uses — only ever answers the process's *original* launch intent, once;
/// it has nothing to do with `onNewIntent` and never will. Without a
/// listener on the ongoing stream, a tap on the same link while the app is
/// open or backgrounded is a complete no-op.
///
/// `uriLinkStream`'s own first emission replays the same cold-start link
/// `PendingDeepLink.readSpectatorCode` already consumed (see the `app_links`
/// README: "Subscribe to all events (initial link and further)"). Rather
/// than trying to suppress exactly that one event — a cold start with no
/// deep link at all never emits a "first event" here either, so a blanket
/// "skip the first event we see" would instead wrongly eat the very first
/// genuine warm tap on a plain (non-deep-link) launch — every emission is
/// treated identically, and the only guard is a plain "are we already on
/// that screen" check, which is what makes the harmless cold-start replay
/// a no-op without needing to special-case it.
class DeepLinkService extends GetxService {
  StreamSubscription<Uri>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = AppLinks().uriLinkStream.listen(
      _onLink,
      onError: (Object error) {
        if (kDebugMode) {
          debugPrint('[DeepLinkService] uriLinkStream error: $error');
        }
      },
    );
  }

  /// The route this link should navigate to, or null if it names no
  /// spectate code or the app is already sitting on that exact screen.
  /// Pure and side-effect-free (bar reading [Get.currentRoute]) so the
  /// decision is testable without a real `uriLinkStream` event.
  String? routeFor(Uri uri) {
    final code = PendingDeepLink.spectatorCodeFrom(uri);
    if (code == null) return null;

    final path = AppRoutes.spectatorPath(code);
    return Get.currentRoute == path ? null : path;
  }

  void _onLink(Uri uri) {
    final path = routeFor(uri);
    if (path == null) return;

    // No user check, no onboarding check, no profile check — same as the
    // cold-start path: a spectator link bypasses every auth-shaped branch.
    unawaited(Get.offAllNamed<dynamic>(path));
  }

  @override
  void onClose() {
    unawaited(_subscription?.cancel());
    super.onClose();
  }
}
