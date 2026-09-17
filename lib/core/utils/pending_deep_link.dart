import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// A `cricketscorer:///claim-player/<playerId>?name=<name>` link's payload —
/// the `name` travels in the link itself (query param, set by the sharing
/// scorer) rather than being fetched, since no endpoint resolves a Player's
/// name for anyone but the scorer who created it (see docs/api.md's
/// `GET /v1/match/public/:code` privacy notes) — the claiming user is very
/// much not that scorer.
class ClaimPlayerLink {
  const ClaimPlayerLink({required this.playerId, required this.name});

  final String playerId;
  final String name;
}

/// Resolves a cold-launch deep link — spectator share links and
/// claim-player links today, both under the one `cricketscorer://` scheme.
///
/// Deliberately NOT read from `WidgetsBinding.instance.platformDispatcher.
/// defaultRouteName` / the AndroidManifest `flutter_deeplinking_enabled` flag.
/// That flag makes Flutter's own Router treat the platform's launch route as
/// authoritative and build that page directly — which collides with GetX's
/// own routing in this app (plain `Navigator` via `getPages`, not go_router /
/// Router 2.0) and crashes on launch with a GlobalKey/Element assertion
/// (`'_elements.contains(element)' is not true`). Reproduced twice on-device
/// with the flag on; confirmed absent with it off.
///
/// `app_links` sidesteps this entirely: it reads the launching Intent's data
/// URI through its own platform channel, never touching `defaultRouteName` or
/// the Router. `GetMaterialApp` therefore always starts at [AppRoutes.splash]
/// — deep link or not — and [SplashController] is genuinely guaranteed to be
/// the first screen built, which is what makes a single one-shot read here
/// safe: nothing else could have already acted on the link first.
class PendingDeepLink {
  PendingDeepLink._();

  static final _spectatorPattern = RegExp(r'^/spectate/([^/?]+)');
  static final _claimPlayerPattern = RegExp(r'^/claim-player/([^/?]+)');

  /// The share code from a `/spectate/<code>` link, or null for any URI this
  /// app doesn't recognise. Pure and side-effect-free on purpose: shared
  /// between this class's own cold-start read and [DeepLinkService]'s
  /// warm-launch listener, so the two can never recognise the link
  /// differently.
  static String? spectatorCodeFrom(Uri uri) =>
      _spectatorPattern.firstMatch(uri.path)?.group(1);

  /// Same shape as [spectatorCodeFrom], for a claim-player link. `name`
  /// missing or empty is treated as "not a claim link" — the confirmation
  /// screen has nothing to show without it.
  static ClaimPlayerLink? claimPlayerFrom(Uri uri) {
    final playerId = _claimPlayerPattern.firstMatch(uri.path)?.group(1);
    if (playerId == null) return null;
    final name = uri.queryParameters['name'];
    if (name == null || name.isEmpty) return null;
    return ClaimPlayerLink(playerId: playerId, name: name);
  }

  /// The raw cold-launch URI, or null for an ordinary launch — or any link
  /// this app doesn't recognise at all. One platform-channel read, shared by
  /// every link type: [SplashController] derives [spectatorCodeFrom] and
  /// [claimPlayerFrom] from the same resolved URI rather than each type
  /// paying for its own `getInitialLink()` round trip (and, on-device, its
  /// own worst-case 3-second timeout on top).
  ///
  /// Call once, from [SplashController.onReady] before any auth work — a
  /// spectator link must not fire `get-current-user` at all, not merely skip
  /// acting on its result.
  static Future<Uri?> readInitialUri() async {
    try {
      // A hard timeout, not a nicety: this runs on the startup path of every
      // single launch, deep link or not. A platform channel call that never
      // completes — observed on-device for a VIEW intent delivered via `adb
      // shell am start` — must not be able to strand the entire app on the
      // splash screen forever. Timing out and falling through to "no deep
      // link" is a deep link that silently fails to redirect; the
      // alternative, an unbounded await here, is the whole app never
      // starting for anyone.
      return await AppLinks().getInitialLink().timeout(
        const Duration(seconds: 3),
      );
    } catch (e) {
      // Covers both a thrown platform-channel error and the TimeoutException
      // above — both must degrade to "no deep link" rather than block launch.
      if (kDebugMode) {
        debugPrint('[PendingDeepLink] getInitialLink failed: $e');
      }
      return null;
    }
  }

  /// Convenience wrapper over [readInitialUri] for callers that only care
  /// about a spectator link (unchanged call shape from before
  /// [claimPlayerFrom] existed) — [SplashController] itself calls
  /// [readInitialUri] directly so it can check both link types from one
  /// read.
  static Future<String?> readSpectatorCode() async {
    final uri = await readInitialUri();
    return uri == null ? null : spectatorCodeFrom(uri);
  }
}
