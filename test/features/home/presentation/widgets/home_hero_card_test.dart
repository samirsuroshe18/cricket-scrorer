import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_hero_card.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_live_carousel.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_status_strip.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/recent_ball_dots.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

MatchHistoryItem _item({
  String status = 'live',
  String? joinCode = 'AB12CD',
  CurrentInningsSummary? innings,
}) => MatchHistoryItem(
  matchId: 'm1',
  teamA: TeamRef(id: 'a', name: 'Mumbai Warriors'),
  teamB: TeamRef(id: 'b', name: 'Pune Kings'),
  joinCode: joinCode,
  totalOvers: 20,
  status: status,
  createdAt: '2026-09-18T10:15:00.000Z',
  syncStatus: 'synced',
  currentInnings: innings,
);

CurrentInningsSummary _live({List<RecentBall> balls = const []}) =>
    CurrentInningsSummary(
      inningsNumber: 1,
      battingTeam: 'teamA',
      totalRuns: 142,
      wickets: 4,
      overs: '16.2',
      recentBalls: balls,
    );

Widget _host(Widget child, {ThemeData? theme, double width = 360}) =>
    GetMaterialApp(
      theme: theme ?? AppTheme.darkTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

void main() {
  group('ResumeScoringHero', () {
    testWidgets('shows the batting side, the score and the recent balls', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ResumeScoringHero(
            item: _item(
              innings: _live(
                balls: [
                  RecentBall(totalRuns: 4, isWicket: false),
                  RecentBall(totalRuns: 0, isWicket: true),
                ],
              ),
            ),
            onResume: () {},
          ),
        ),
      );

      expect(find.text('Mumbai Warriors'), findsOneWidget);
      expect(find.text('142/4', findRichText: true), findsOneWidget);
      expect(find.byType(RecentBallDots), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
    });

    testWidgets('omits the ball dots when nothing has been bowled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ResumeScoringHero(
            item: _item(innings: _live()),
            onResume: () {},
          ),
        ),
      );

      expect(find.byType(RecentBallDots), findsNothing);
    });

    testWidgets('the button resumes the match', (tester) async {
      var resumed = false;
      await tester.pumpWidget(
        _host(
          ResumeScoringHero(
            item: _item(innings: _live()),
            onResume: () => resumed = true,
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      expect(resumed, isTrue);
    });

    testWidgets('a match with no innings yet shows both teams, not a score', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ResumeScoringHero(
            item: _item(status: 'upcoming'),
            onResume: () {},
          ),
        ),
      );

      expect(find.text('Mumbai Warriors vs Pune Kings'), findsOneWidget);
      expect(find.text('home_start_scoring'), findsOneWidget);
    });

    testWidgets('lays out in light mode at a narrow width without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ResumeScoringHero(
            item: _item(
              innings: _live(
                balls: [RecentBall(totalRuns: 4, isWicket: false)],
              ),
            ),
            onResume: () {},
          ),
          theme: AppTheme.lightTheme,
          width: 300,
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('empty-state heroes', () {
    testWidgets('start hero starts a match', (tester) async {
      var started = false;
      await tester.pumpWidget(
        _host(StartMatchHero(onStart: () => started = true)),
      );

      await tester.tap(find.byType(FilledButton));
      expect(started, isTrue);
    });

    testWidgets('first-run hero lists the three steps and starts a match', (
      tester,
    ) async {
      var started = false;
      await tester.pumpWidget(
        _host(FirstMatchHero(onStart: () => started = true)),
      );

      for (final n in ['1', '2', '3']) {
        expect(find.text(n), findsOneWidget);
      }
      await tester.tap(find.byType(FilledButton));
      expect(started, isTrue);
    });
  });

  group('HomeLiveCarousel', () {
    Future<void> pump(
      WidgetTester tester,
      List<MatchHistoryItem> items, {
      ValueChanged<MatchHistoryItem>? onShare,
      ValueChanged<MatchHistoryItem>? onOpen,
    }) => tester.pumpWidget(
      _host(
        HomeLiveCarousel(
          items: items,
          onOpen: onOpen ?? (_) {},
          onShare: onShare ?? (_) {},
          onMore: (_) {},
        ),
      ),
    );

    testWidgets('shows the batting side with its score and the other side', (
      tester,
    ) async {
      await pump(tester, [_item(innings: _live())]);

      expect(find.text('Mumbai Warriors'), findsOneWidget);
      expect(find.text('Pune Kings'), findsOneWidget);
      expect(find.text('142/4 (16.2)', findRichText: true), findsOneWidget);
      expect(find.text('home_yet_to_bat'), findsOneWidget);
    });

    testWidgets('a share tap reports the card, a card tap opens it', (
      tester,
    ) async {
      final shared = <String>[];
      final opened = <String>[];
      await pump(
        tester,
        [_item(innings: _live())],
        onShare: (i) => shared.add(i.matchId),
        onOpen: (i) => opened.add(i.matchId),
      );

      await tester.tap(find.text('home_share_link'));
      expect(shared, ['m1']);

      await tester.tap(find.text('Pune Kings'));
      expect(opened, ['m1']);
    });

    testWidgets('a match with no share code offers no share action', (
      tester,
    ) async {
      await pump(tester, [_item(joinCode: null, innings: _live())]);

      expect(find.text('home_share_link'), findsNothing);
    });

    testWidgets('scrolls sideways without overflowing with several matches', (
      tester,
    ) async {
      await pump(tester, [
        for (var i = 0; i < 4; i++) _item(innings: _live()),
      ]);

      expect(tester.takeException(), isNull);
    });
  });

  group('HomeStatusStrip', () {
    testWidgets('shows its message and reports a tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(
          HomeStatusStrip(
            tone: HomeStripTone.warning,
            icon: Icons.cloud_off_outlined,
            message: 'Offline · 2 balls waiting to sync',
            actionLabel: 'Details',
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Offline · 2 balls waiting to sync'), findsOneWidget);
      await tester.tap(find.text('Details'));
      expect(tapped, isTrue);
    });
  });
}
