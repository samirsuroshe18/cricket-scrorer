import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/features/auth/data/models/user.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_sync_status_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/main_shell_controller.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_stats_controller.dart';
import 'package:cricket_scorer/features/home/presentation/pages/home_dashboard_tab.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_hero_card.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_live_carousel.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_recent_results.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_skeleton.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_status_strip.dart';
import 'package:cricket_scorer/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_career_stats_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The dashboard only reads a handful of members off each controller, so these
// fakes provide exactly those and let everything else fall through to
// noSuchMethod — which fails loudly if the dashboard ever starts depending on
// something the test did not think about.
class _FakeHome extends GetxController implements HomeController {
  @override
  final matches = <MatchHistoryItem>[].obs;
  @override
  final isLoading = false.obs;
  @override
  final loadError = Rxn<String>();
  @override
  final currentUserProfile = Rx<User?>(null);

  final opened = <String>[];
  var loads = 0;

  @override
  void openMatch(MatchHistoryItem item) => opened.add(item.matchId);

  @override
  Future<void> loadHistory() async => loads++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStats extends GetxController implements MyStatsController {
  @override
  final stats = Rxn<MyCareerStatsRes>();

  @override
  Future<void> load() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotifications extends GetxController
    implements NotificationsController {
  @override
  final unreadCount = 0.obs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MatchHistoryItem _match(
  String id, {
  String status = 'live',
  MatchUserRef? assignedScorer,
  String syncStatus = 'synced',
  MatchResultInfo? result,
  CurrentInningsSummary? innings,
}) => MatchHistoryItem(
  matchId: id,
  teamA: TeamRef(id: 'a-$id', name: 'Alpha $id'),
  teamB: TeamRef(id: 'b-$id', name: 'Bravo $id'),
  joinCode: 'CODE$id',
  totalOvers: 20,
  status: status,
  assignedScorer: assignedScorer,
  result: result,
  createdAt: '2026-09-18T10:15:00.000Z',
  syncStatus: syncStatus,
  currentInnings: innings,
);

CurrentInningsSummary _innings() => CurrentInningsSummary(
  inningsNumber: 1,
  battingTeam: 'teamA',
  totalRuns: 50,
  wickets: 1,
  overs: '6.0',
);

void main() {
  late _FakeHome home;
  late StreamController<List<QueuedRow>> queue;
  late StreamController<List<ConnectivityResult>> connectivity;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.put(await SharedPreferenceService().init());

    home = Get.put<HomeController>(_FakeHome()) as _FakeHome;
    Get.put<MyStatsController>(_FakeStats());
    Get.put<NotificationsController>(_FakeNotifications());
    Get.put(MainShellController());

    queue = StreamController<List<QueuedRow>>.broadcast();
    connectivity = StreamController<List<ConnectivityResult>>.broadcast();
    Get.put(
      HomeSyncStatusController(
        queue: queue.stream,
        connectivity: connectivity.stream,
        checkConnectivity: () async => const [ConnectivityResult.wifi],
      ),
    );
  });

  tearDown(() async {
    await queue.close();
    await connectivity.close();
    Get.reset();
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.darkTheme, home: const HomeDashboardTab()),
    );
    await tester.pump();
  }

  testWidgets('first fetch in flight shows the skeleton, not a spinner', (
    tester,
  ) async {
    home.isLoading.value = true;
    await pump(tester);

    expect(find.byType(HomeSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a user with no matches gets the first-run walkthrough', (
    tester,
  ) async {
    await pump(tester);

    expect(find.byType(FirstMatchHero), findsOneWidget);
    expect(find.text('home_watch_with_code'), findsOneWidget);
    // Search is for someone with a season behind them, not a first run.
    expect(find.text('search'), findsNothing);
    expect(find.byType(HomeLiveCarousel), findsNothing);
    expect(find.byType(HomeRecentResults), findsNothing);
  });

  testWidgets('only finished matches: the hero offers the next one', (
    tester,
  ) async {
    home.matches.assignAll([
      _match(
        'done',
        status: 'completed',
        result: MatchResultInfo(winner: 'teamA', marginType: 'runs', margin: 9),
      ),
    ]);
    await pump(tester);

    expect(find.byType(StartMatchHero), findsOneWidget);
    expect(find.byType(HomeRecentResults), findsOneWidget);
    expect(find.text('Alpha done vs Bravo done'), findsOneWidget);
  });

  testWidgets('a live match the user scores becomes the hero, not a card', (
    tester,
  ) async {
    home.matches.assignAll([
      _match('mine', innings: _innings()),
      _match(
        'other',
        innings: _innings(),
        assignedScorer: MatchUserRef(id: 'someone-else', name: 'S'),
      ),
    ]);
    await pump(tester);

    expect(find.byType(ResumeScoringHero), findsOneWidget);
    // Exactly one card in the carousel: the other scorer's match. The hero's
    // own match must not be listed twice.
    expect(find.byType(HomeLiveCard), findsOneWidget);
    expect(find.text('Alpha other'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    expect(home.opened, ['mine']);
  });

  testWidgets(
    'a live match assigned to someone else is watched, not scored: no hero',
    (tester) async {
      home.matches.assignAll([
        _match(
          'theirs',
          innings: _innings(),
          assignedScorer: MatchUserRef(id: 'someone-else', name: 'S'),
        ),
      ]);
      await pump(tester);

      expect(find.byType(ResumeScoringHero), findsNothing);
      expect(find.byType(StartMatchHero), findsOneWidget);
      expect(find.byType(HomeLiveCard), findsOneWidget);
    },
  );

  testWidgets('a created-but-unstarted match is offered as the hero', (
    tester,
  ) async {
    home.matches.assignAll([_match('soon', status: 'upcoming')]);
    await pump(tester);

    expect(find.byType(ResumeScoringHero), findsOneWidget);
    expect(find.text('home_start_scoring'), findsOneWidget);
  });

  group('status strip', () {
    testWidgets('is absent when nothing needs attention', (tester) async {
      home.matches.assignAll([_match('a', innings: _innings())]);
      await pump(tester);

      expect(find.byType(HomeStatusStrip), findsNothing);
    });

    testWidgets('queued balls show a waiting-to-sync strip', (tester) async {
      home.matches.assignAll([_match('a', innings: _innings())]);
      await pump(tester);

      queue.add([(matchId: 'a', isBall: true), (matchId: 'a', isBall: true)]);
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeStatusStrip), findsOneWidget);
      expect(find.textContaining('home_balls_waiting_many'), findsOneWidget);
    });

    testWidgets('tapping details opens the match holding the queue', (
      tester,
    ) async {
      home.matches.assignAll([_match('a', innings: _innings())]);
      await pump(tester);
      queue.add([(matchId: 'a', isBall: true)]);
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('home_strip_details'));

      expect(home.opened, ['a']);
    });

    testWidgets('a sync conflict outranks queued balls', (tester) async {
      home.matches.assignAll([
        _match('a', innings: _innings(), syncStatus: 'conflict'),
      ]);
      await pump(tester);
      queue.add([(matchId: 'a', isBall: true)]);
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeStatusStrip), findsOneWidget);
      expect(find.textContaining('home_sync_conflict_one'), findsOneWidget);
      expect(find.textContaining('home_balls_waiting'), findsNothing);
    });

    testWidgets('a failed refresh keeps the list and offers a retry', (
      tester,
    ) async {
      home.matches.assignAll([_match('a', innings: _innings())]);
      home.loadError.value = 'boom';
      await pump(tester);

      expect(find.byType(ResumeScoringHero), findsOneWidget);
      expect(find.text('home_refresh_failed'), findsOneWidget);

      await tester.tap(find.text('retry'));
      expect(home.loads, 1);
    });
  });
}
