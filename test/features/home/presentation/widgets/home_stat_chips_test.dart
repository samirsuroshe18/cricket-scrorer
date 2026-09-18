import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_stat_chips.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_career_stats_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('shows matches, runs and wickets with their labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: HomeStatChips(
            stats: MyCareerStatsRes(
              linkedPlayerCount: 1,
              matchesPlayed: 12,
              runs: 345,
              wickets: 9,
            ),
          ),
        ),
      ),
    );

    expect(find.text('12'), findsOneWidget);
    expect(find.text('345'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    // Raw keys: no translations are loaded in this bare test.
    expect(find.text('stat_matches'), findsOneWidget);
    expect(find.text('stat_runs'), findsOneWidget);
    expect(find.text('wickets'), findsOneWidget);
  });

  testWidgets('lays out without overflow in dark mode at a narrow width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: HomeStatChips(
            stats: MyCareerStatsRes(
              linkedPlayerCount: 3,
              matchesPlayed: 1234,
              runs: 56789,
              wickets: 999,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
