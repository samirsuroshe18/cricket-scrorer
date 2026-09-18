import 'package:cricket_scorer/config/routes/app_routes.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/match_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

MatchHistoryItem _item({
  MatchUserRef? createdBy,
  MatchUserRef? assignedScorer,
  String status = 'completed',
  CurrentInningsSummary? currentInnings,
  String syncStatus = 'synced',
}) => MatchHistoryItem(
  matchId: 'match-1',
  teamA: TeamRef(id: 'team-a', name: 'Mumbai Indians'),
  teamB: TeamRef(id: 'team-b', name: 'Chennai Super Kings'),
  totalOvers: 20,
  status: status,
  createdBy: createdBy,
  assignedScorer: assignedScorer,
  createdAt: '2026-08-20T10:15:00.000Z',
  currentInnings: currentInnings,
  syncStatus: syncStatus,
);

void main() {
  testWidgets(
    'tapping teamA\'s name opens that team\'s profile, not the card\'s own onTap',
    (
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
                currentUserId: 'viewer-1',
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
    },
  );

  testWidgets(
    'with highlightTeamId set to teamA, the title shows only the opponent',
    (
      tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(),
            currentUserId: 'viewer-1',
            onTap: () {},
            highlightTeamId: 'team-a',
          ),
        ),
      );

      expect(find.text('vs Chennai Super Kings'), findsOneWidget);
      expect(find.text('Mumbai Indians'), findsNothing);
    },
  );

  testWidgets(
    'shows no delegation label when there is no createdBy or assignedScorer',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(),
            currentUserId: 'viewer-1',
            onTap: () {},
          ),
        ),
      );

      // Raw keys (no translations loaded in this bare test) — absence of
      // either proves _delegationLabel() returned null, not just that one
      // specific wording didn't match.
      expect(find.textContaining('assigned_by_name'), findsNothing);
      expect(find.textContaining('assigned_to_name'), findsNothing);
    },
  );

  testWidgets(
    "shows 'assigned by' when the viewer isn't the match's creator",
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(
              createdBy: MatchUserRef(id: 'owner-1', name: 'Priya Nair'),
            ),
            currentUserId: 'viewer-1',
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('assigned_by_name'), findsOneWidget);
      expect(find.textContaining('assigned_to_name'), findsNothing);
    },
  );

  testWidgets(
    "shows no delegation label when the viewer IS the match's creator and "
    'nobody is assigned',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(
              createdBy: MatchUserRef(id: 'viewer-1', name: 'Me'),
            ),
            currentUserId: 'viewer-1',
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('assigned_by_name'), findsNothing);
      expect(find.textContaining('assigned_to_name'), findsNothing);
    },
  );

  testWidgets(
    "shows 'assigned to' on the creator's own card once delegated",
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(
              createdBy: MatchUserRef(id: 'viewer-1', name: 'Me'),
              assignedScorer: MatchUserRef(id: 'user-2', name: 'Raj Patel'),
            ),
            currentUserId: 'viewer-1',
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('assigned_to_name'), findsOneWidget);
      expect(find.textContaining('assigned_by_name'), findsNothing);
    },
  );

  testWidgets(
    "'assigned by' wins over 'assigned to' when both fields are set and the "
    "viewer isn't the creator — this is the assigned scorer's own view of a "
    'match delegated to them',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(
              createdBy: MatchUserRef(id: 'owner-1', name: 'Priya Nair'),
              assignedScorer: MatchUserRef(id: 'viewer-1', name: 'Me'),
            ),
            currentUserId: 'viewer-1',
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('assigned_by_name'), findsOneWidget);
      expect(find.textContaining('assigned_to_name'), findsNothing);
    },
  );

  testWidgets(
    'the assign-scorer icon only appears when onAssignScorer is provided, '
    'and tapping it invokes the callback',
    (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(),
            currentUserId: 'viewer-1',
            onTap: () {},
            onAssignScorer: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.person_add_alt), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_add_alt));
      await tester.pump();

      expect(tapped, isTrue);
    },
  );

  testWidgets(
    'the assign-scorer icon is absent when onAssignScorer is null',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(),
            currentUserId: 'viewer-1',
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.person_add_alt), findsNothing);
    },
  );

  testWidgets(
    'shows the live score line when currentInnings is present',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(
              status: 'live',
              currentInnings: CurrentInningsSummary(
                inningsNumber: 1,
                totalRuns: 145,
                wickets: 4,
                overs: '18.2',
              ),
            ),
            currentUserId: 'viewer-1',
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('145/4'), findsOneWidget);
      expect(find.textContaining('18.2'), findsOneWidget);
    },
  );

  testWidgets(
    'shows no score line when currentInnings is null (e.g. a completed match)',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(),
            currentUserId: 'viewer-1',
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('/'), findsNothing);
    },
  );

  testWidgets(
    "shows the conflict chip when syncStatus is 'conflict'",
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(syncStatus: 'conflict'),
            currentUserId: 'viewer-1',
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('sync_conflict_title'), findsOneWidget);
      expect(find.byIcon(Icons.sync_problem), findsOneWidget);
    },
  );

  testWidgets(
    "shows the syncing chip when syncStatus is 'syncing'",
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: MatchHistoryCard(
            item: _item(syncStatus: 'syncing'),
            currentUserId: 'viewer-1',
            onTap: () {},
          ),
        ),
      );

      expect(find.textContaining('syncing_now'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    },
  );

  testWidgets(
    'renders inside a ListView (the real Home/Matches usage) without a '
    'layout exception for a live match with an accent bar',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: ListView(
              children: [
                MatchHistoryCard(
                  item: _item(
                    status: 'live',
                    currentInnings: CurrentInningsSummary(
                      inningsNumber: 1,
                      totalRuns: 52,
                      wickets: 2,
                      overs: '6.3',
                    ),
                  ),
                  currentUserId: 'viewer-1',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    "shows no sync chip for 'synced' or the ambiguous default 'local' — "
    'most matches are scored entirely online and stay at local forever, so '
    "badging it would flag them as 'not synced' incorrectly",
    (tester) async {
      for (final status in ['synced', 'local']) {
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.lightTheme,
            home: MatchHistoryCard(
              item: _item(syncStatus: status),
              currentUserId: 'viewer-1',
              onTap: () {},
            ),
          ),
        );

        expect(find.textContaining('sync_conflict_title'), findsNothing);
        expect(find.textContaining('syncing_now'), findsNothing);
      }
    },
  );
}
