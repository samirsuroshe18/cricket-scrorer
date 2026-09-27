import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/team_stats_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TeamStatsRes _stats({
  int played = 12,
  int won = 7,
  int lost = 4,
  int tied = 1,
  int noResult = 0,
  double winPercentage = 58.3,
  List<String> form = const ['W', 'L', 'T', 'N'],
}) => TeamStatsRes(
  played: played,
  won: won,
  lost: lost,
  tied: tied,
  noResult: noResult,
  winPercentage: winPercentage,
  form: form,
);

Future<void> _pump(WidgetTester tester, TeamStatsRes stats) =>
    tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: TeamStatsStrip(stats: stats)),
      ),
    );

void main() {
  testWidgets(
    'shows record, win percentage and form dots with semantics labels',
    (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pump(tester, _stats());

      expect(find.text('12'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('58.3%'), findsOneWidget);
      expect(find.bySemanticsLabel(TranslationKeys.formWon), findsOneWidget);
      expect(find.bySemanticsLabel(TranslationKeys.formLost), findsOneWidget);
      expect(find.bySemanticsLabel(TranslationKeys.formTied), findsOneWidget);
      expect(
        find.bySemanticsLabel(TranslationKeys.formNoResult),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );

  testWidgets('a whole-number win percentage drops the trailing .0', (
    tester,
  ) async {
    await _pump(
      tester,
      _stats(
        played: 2,
        won: 2,
        lost: 0,
        tied: 0,
        winPercentage: 100,
        form: ['W', 'W'],
      ),
    );

    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('is hidden when no matches were played', (tester) async {
    await _pump(
      tester,
      _stats(played: 0, won: 0, lost: 0, tied: 0, winPercentage: 0, form: []),
    );

    expect(find.text(TranslationKeys.playedShort), findsNothing);
    expect(find.text(TranslationKeys.recentForm), findsNothing);
  });

  testWidgets('shows tied and no-result counts only when non-zero', (
    tester,
  ) async {
    await _pump(tester, _stats(tied: 0, noResult: 0, form: ['W', 'L']));
    expect(find.text(TranslationKeys.tiedShort), findsNothing);
    expect(find.text(TranslationKeys.noResultShort), findsNothing);

    await _pump(tester, _stats(tied: 1, noResult: 2));
    await tester.pump();
    expect(find.text(TranslationKeys.tiedShort), findsWidgets);
    expect(find.text(TranslationKeys.noResultShort), findsWidgets);
  });
}
