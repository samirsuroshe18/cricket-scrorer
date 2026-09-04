import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

MatchHistoryItem _item() => MatchHistoryItem(
  matchId: 'match-1',
  teamA: TeamRef(id: 'team-a', name: 'Mumbai Indians'),
  teamB: TeamRef(id: 'team-b', name: 'Chennai Super Kings'),
  totalOvers: 20,
  status: 'completed',
  createdAt: '2026-08-20T10:15:00.000Z',
);

void main() {
  testWidgets('tapping teamA\'s name opens that team\'s profile, not the card\'s own onTap', (
    tester,
  ) async {
    var cardTapped = false;

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: '/home',
        getPages: [
          GetPage(
            name: '/home',
            page: () => MatchHistoryCard(
              item: _item(),
              onTap: () => cardTapped = true,
            ),
          ),
          GetPage(
            name: AppRoutes.teamProfile,
            page: () => const Scaffold(body: Text('team profile')),
          ),
        ],
      ),
    );

    await tester.tap(find.text('Mumbai Indians'));
    await tester.pumpAndSettle();

    expect(find.text('team profile'), findsOneWidget);
    expect(cardTapped, isFalse);
  });

  testWidgets('with highlightTeamId set to teamA, the title shows only the opponent', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: MatchHistoryCard(
          item: _item(),
          onTap: () {},
          highlightTeamId: 'team-a',
        ),
      ),
    );

    expect(find.text('vs Chennai Super Kings'), findsOneWidget);
    expect(find.text('Mumbai Indians'), findsNothing);
  });
}
