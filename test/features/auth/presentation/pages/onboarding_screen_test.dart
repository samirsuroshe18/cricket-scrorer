import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/core/translations/app_translations.dart';
import 'package:cricket_scorer/features/auth/presentation/controllers/onboarding_controller.dart';
import 'package:cricket_scorer/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:cricket_scorer/features/auth/presentation/widget/onboarding_hero_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpOnboardingScreen(WidgetTester tester) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await Get.put(SharedPreferenceService()).init();

  // OnboardingController resolves its page titles/descriptions via `.tr`
  // in a field initializer, at the moment it's constructed — GetMaterialApp
  // only wires up `translations`/`locale` once it builds, which is too
  // late for that. Registering them directly first is what makes `.tr`
  // resolve to real English strings instead of the raw keys.
  Get.addTranslations(AppTranslations().keys);
  Get.locale = const Locale('en');

  Get.put(OnboardingController());

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.lightTheme,
      translations: AppTranslations(),
      locale: const Locale('en'),
      home: const OnboardingScreen(),
    ),
  );
}

void main() {
  tearDown(Get.reset);

  testWidgets('renders inside a SafeArea, matching sibling auth screens', (
    tester,
  ) async {
    await _pumpOnboardingScreen(tester);

    expect(
      find.descendant(
        of: find.byType(Scaffold),
        matching: find.byType(SafeArea),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'does not overflow on any page, including the final "Get Started" CTA',
    (tester) async {
      await _pumpOnboardingScreen(tester);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // The CTA is on its single-line, auto-sizing path (not the default
      // CricketText path, which allows a 2-line wrap) — that's what stops
      // "Get Started" from wrapping and jumping the footer's height.
      final textWidget = tester.widget<Text>(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text('Get Started'),
        ),
      );
      expect(textWidget.maxLines, 1);
    },
  );

  testWidgets('exposes page position to assistive technology', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpOnboardingScreen(tester);

    // The page content itself carries the title/description too, so it's
    // distinguishable from the indicator dot below, which announces the
    // bare "Page X of Y" as its button label.
    expect(
      find.bySemanticsLabel(RegExp('Page 1 of 3\\. Live Scoring.*')),
      findsOneWidget,
    );

    handle.dispose();
  });

  testWidgets('indicator dots announce their page and are actionable', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpOnboardingScreen(tester);

    expect(find.bySemanticsLabel('Page 2 of 3'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('tapping an indicator dot jumps straight to that page', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpOnboardingScreen(tester);

    expect(find.text('Deep Match Stats'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Page 3 of 3'));
    await tester.pumpAndSettle();

    expect(find.text('Share The Victory'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    handle.dispose();
  });

  testWidgets(
    'each indicator dot has at least a 48x48 tap target',
    (tester) async {
      await _pumpOnboardingScreen(tester);

      final dots = find.byWidgetPredicate(
        (widget) => widget is InkWell && widget.customBorder is CircleBorder,
      );
      expect(dots, findsNWidgets(3));

      for (final element in dots.evaluate()) {
        final size = tester.getSize(find.byWidget(element.widget));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    },
  );

  testWidgets(
    'does not overflow on a small phone height, on any page',
    (tester) async {
      // iPhone SE-ish — the shortest common target. The per-page column is
      // wrapped in a LayoutBuilder + SingleChildScrollView so it scrolls
      // instead of overflowing when the hero card + copy don't fit.
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pumpOnboardingScreen(tester);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'does not overflow at a narrow width, on the stat-grid page',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pumpOnboardingScreen(tester);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Deep Match Stats'), findsOneWidget);
    },
  );

  testWidgets(
    'does not overflow at a large text-scale factor, on any page',
    (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _pumpOnboardingScreen(tester);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the hero card is the same size on every page',
    (tester) async {
      await _pumpOnboardingScreen(tester);
      final firstPageSize = tester.getSize(
        find.byType(OnboardingHeroCard),
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(OnboardingHeroCard)),
        firstPageSize,
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(OnboardingHeroCard)),
        firstPageSize,
      );
    },
  );
}
