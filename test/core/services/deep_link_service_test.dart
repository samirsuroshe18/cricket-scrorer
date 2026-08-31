import 'dart:async';

import 'package:cricket_scorer/core/services/deep_link_service.dart';
import 'package:cricket_scorer/core/utils/pending_deep_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('PendingDeepLink.spectatorCodeFrom', () {
    test('extracts the code from a spectate path', () {
      expect(
        PendingDeepLink.spectatorCodeFrom(
          Uri.parse('cricketscorer:///spectate/ABC123'),
        ),
        'ABC123',
      );
    });

    test('returns null for a link this app does not recognise', () {
      expect(
        PendingDeepLink.spectatorCodeFrom(Uri.parse('cricketscorer:///home')),
        isNull,
      );
    });
  });

  group('DeepLinkService.routeFor', () {
    // Constructed directly rather than via Get.put — routeFor only reads
    // Get.currentRoute, so exercising it needs no `onInit()`/stream
    // subscription (and therefore no real `AppLinks()` platform channel) at
    // all — the whole reason the decision was pulled out of `_onLink` into
    // its own pure-ish method in the first place.
    final service = DeepLinkService();

    testWidgets(
      'targets the spectate route for a recognised link',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/home',
            getPages: [
              GetPage(name: '/home', page: () => const SizedBox()),
              GetPage(name: '/spectate/:code', page: () => const SizedBox()),
            ],
          ),
        );

        expect(
          service.routeFor(Uri.parse('cricketscorer:///spectate/ABC123')),
          '/spectate/ABC123',
        );
      },
    );

    testWidgets(
      'returns null for a link this app does not recognise',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/home',
            getPages: [GetPage(name: '/home', page: () => const SizedBox())],
          ),
        );

        expect(
          service.routeFor(Uri.parse('cricketscorer:///not-a-spectate-link')),
          isNull,
        );
      },
    );

    testWidgets(
      // This is what makes the harmless cold-start replay of uriLinkStream's
      // first event a no-op, without needing to special-case "is this the
      // first event" at all — see the class doc comment.
      'returns null once the app is already on that exact spectate screen',
      (tester) async {
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/home',
            getPages: [
              GetPage(name: '/home', page: () => const SizedBox()),
              GetPage(name: '/spectate/:code', page: () => const SizedBox()),
            ],
          ),
        );

        unawaited(Get.offAllNamed<dynamic>('/spectate/ABC123'));
        await tester.pumpAndSettle();

        expect(
          service.routeFor(Uri.parse('cricketscorer:///spectate/ABC123')),
          isNull,
          reason: 're-navigating to the screen already on screen is a no-op',
        );

        // A tap on a *different* share link while already spectating a
        // match must still go through.
        expect(
          service.routeFor(Uri.parse('cricketscorer:///spectate/XYZ789')),
          '/spectate/XYZ789',
        );
      },
    );
  });
}
