import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/services/shared_preference_service.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/home_controller.dart';
import 'package:cricket_scorer/features/home/presentation/pages/matches_tab.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_status_strip.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/match_list_row.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/matches_skeleton.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/create_match_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_history_res.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/match_result_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Same approach as the dashboard test: provide exactly the members the tab
// reads and let anything else fall through to noSuchMethod, which fails loudly
// if the tab starts depending on something this test did not think about.
class _FakeHome extends GetxController implements HomeController {
  @override
  final matches = <MatchHistoryItem>[].obs;
  @override
  final isLoading = false.obs;
  @override
  final isLoadingMore = false.obs;
  @override
  final hasMore = false.obs;
  @override
  final loadError = Rxn<String>();
  @override
  final deletingMatchIds = <String>{}.obs;
  @override
  final statusCounts = <String, int>{}.obs;
  @override
  final statusFilter = Rxn<String>();
  @override
  final filteredMatches = <MatchHistoryItem>[].obs;
  @override
  final isLoadingFiltered = false.obs;
  @override
  final isLoadingMoreFiltered = false.obs;
  @override
  final hasMoreFiltered = false.obs;
  @override
  final filteredError = Rxn<String>();

  /// Every chip the tab asked for, in order (`null` is All). The fake only
  /// records and flips [statusFilter]; the filtered list is seeded by the
  /// test, standing in for what the server would answer.
  final selected = <String?>[];
  var filteredLoads = 0;
  var filteredLoadMores = 0;
  var refreshes = 0;

  final opened = <String>[];
  var loads = 0;
  var loadMores = 0;

  @override
  void openMatch(MatchHistoryItem item) => opened.add(item.matchId);

  @override
  Future<void> loadHistory() async => loads++;

  @override
  Future<void> loadMore() async => loadMores++;

  @override
  Future<void> loadFiltered() async => filteredLoads++;

  @override
  Future<void> loadMoreFiltered() async => filteredLoadMores++;

  @override
  Future<void> refreshMatches() async => refreshes++;

  @override
  Future<void> selectStatusFilter(String? status) async {
    selected.add(status);
    statusFilter.value = status;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MatchHistoryItem _match(
  String id, {
  String status = 'live',
  String syncStatus = 'synced',
  MatchResultInfo? result,
  CurrentInningsSummary? innings,
}) => MatchHistoryItem(
  matchId: id,
  teamA: TeamRef(id: 'a-$id', name: 'Alpha $id'),
  teamB: TeamRef(id: 'b-$id', name: 'Bravo $id'),
  totalOvers: 20,
  status: status,
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.put(await SharedPreferenceService().init());
    home = Get.put<HomeController>(_FakeHome()) as _FakeHome;
  });

  tearDown(Get.reset);

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.lightTheme, home: const MatchesTab()),
    );
    await tester.pump();
  }

  Finder chip(String label) => find.widgetWithText(InkWell, label);

  testWidgets('first fetch in flight shows the skeleton, not a spinner', (
    tester,
  ) async {
    home.isLoading.value = true;
    await pump(tester);

    expect(find.byType(MatchesSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('All splits in-progress matches from past ones', (tester) async {
    home.matches.assignAll([
      _match('past', status: 'completed'),
      _match('now', innings: _innings()),
      _match('soon', status: 'upcoming'),
    ]);
    await pump(tester);

    expect(find.text('matches_section_active'), findsOneWidget);
    expect(find.text('matches_section_past'), findsOneWidget);
    expect(find.byType(MatchListRow), findsNWidgets(3));
    // In progress renders above past regardless of fetch order.
    expect(
      tester.getTopLeft(find.text('Alpha now')).dy,
      lessThan(tester.getTopLeft(find.text('Alpha past')).dy),
    );
  });

  testWidgets('tapping a chip asks the controller for that status', (
    tester,
  ) async {
    home.matches.assignAll([_match('a', innings: _innings())]);
    await pump(tester);

    await tester.tap(chip('status_live'));
    await tester.pump();

    expect(home.selected, ['live']);
  });

  testWidgets('a filter shows the server-filtered list, not the All list', (
    tester,
  ) async {
    home.matches.assignAll([
      _match('live', innings: _innings()),
      _match('done', status: 'completed'),
    ]);
    home.statusFilter.value = 'completed';
    home.filteredMatches.assignAll([_match('found', status: 'completed')]);
    await pump(tester);

    expect(find.text('Alpha found'), findsOneWidget);
    expect(find.text('Alpha live'), findsNothing);
    expect(find.text('Alpha done'), findsNothing);
    // Sections only make sense across the whole list.
    expect(find.text('matches_section_active'), findsNothing);
    expect(find.text('matches_section_past'), findsNothing);
  });

  testWidgets('a filter with nothing on the server offers Show all', (
    tester,
  ) async {
    home.matches.assignAll([_match('done', status: 'completed')]);
    home.statusFilter.value = 'abandoned';
    await pump(tester);

    expect(find.byType(MatchListRow), findsNothing);

    await tester.tap(find.text('show_all_matches'));
    expect(home.selected, [null]);
  });

  testWidgets('a filtered list loads more from the filtered paging state', (
    tester,
  ) async {
    home.statusFilter.value = 'live';
    home.filteredMatches.assignAll([_match('a', innings: _innings())]);
    home.hasMoreFiltered.value = true;
    home.hasMore.value = false;
    await pump(tester);

    await tester.tap(find.text('load_more_matches'));

    expect(home.filteredLoadMores, 1);
    expect(home.loadMores, 0);
  });

  testWidgets('a filtered load in flight shows the skeleton', (tester) async {
    home.statusFilter.value = 'live';
    home.isLoadingFiltered.value = true;
    await pump(tester);

    expect(find.byType(MatchesSkeleton), findsOneWidget);
  });

  testWidgets('a failed filtered load offers retry through the controller', (
    tester,
  ) async {
    home.statusFilter.value = 'live';
    home.filteredError.value = 'boom';
    await pump(tester);

    await tester.tap(find.text('retry'));

    expect(home.filteredLoads, 1);
    expect(home.loads, 0);
  });

  group('chip counts', () {
    testWidgets('show the server counts, Live including innings break', (
      tester,
    ) async {
      home.statusCounts.assignAll({
        'upcoming': 1,
        'live': 2,
        'innings_break': 1,
        'completed': 5,
        'abandoned': 0,
      });
      home.matches.assignAll([_match('a', innings: _innings())]);
      await pump(tester);

      // All = 9, Live = 3, Upcoming = 1, Completed = 5.
      expect(find.text('9'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('show no number before the server has sent any', (
      tester,
    ) async {
      home.matches.assignAll([_match('a', innings: _innings())]);
      await pump(tester);

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('a chip is announced with its count', (tester) async {
      home.statusCounts.assignAll({'live': 2, 'completed': 4});
      home.matches.assignAll([_match('a', innings: _innings())]);
      await pump(tester);

      expect(find.bySemanticsLabel('status_live, 2'), findsOneWidget);
    });
  });

  testWidgets('Load more only shows while the server has more pages', (
    tester,
  ) async {
    home.matches.assignAll([_match('done', status: 'completed')]);
    await pump(tester);
    expect(find.text('load_more_matches'), findsNothing);

    home.hasMore.value = true;
    await tester.pump();
    expect(find.text('load_more_matches'), findsOneWidget);
  });

  testWidgets('a completed match shows its result line', (tester) async {
    home.matches.assignAll([
      _match(
        'done',
        status: 'completed',
        result: MatchResultInfo(winner: 'teamB', marginType: 'runs', margin: 9),
      ),
    ]);
    await pump(tester);

    expect(find.textContaining('Bravo done'), findsWidgets);
    expect(find.textContaining('won_by 9'), findsOneWidget);
  });

  testWidgets('delete and assign are behind the ⋮ button, not on the row', (
    tester,
  ) async {
    home.matches.assignAll([_match('now', innings: _innings())]);
    await pump(tester);

    expect(find.byIcon(Icons.delete_outline), findsNothing);
    expect(find.byIcon(Icons.person_add_alt), findsNothing);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    expect(find.text('assign_scorer'), findsOneWidget);
    expect(find.text('delete_match'), findsOneWidget);
  });

  testWidgets('long-press opens the same actions sheet', (tester) async {
    home.matches.assignAll([_match('now', innings: _innings())]);
    await pump(tester);

    await tester.longPress(find.text('Alpha now'));
    await tester.pumpAndSettle();

    expect(find.text('delete_match'), findsOneWidget);
  });

  testWidgets('a conflicted match carries a persistent, tappable strip', (
    tester,
  ) async {
    home.matches.assignAll([_match('bad', syncStatus: 'conflict')]);
    await pump(tester);

    expect(find.text('sync_conflict_title'), findsOneWidget);

    await tester.tap(find.text('home_strip_review'));
    expect(home.opened, ['bad']);
  });

  testWidgets('a failed refresh over a loaded list shows a retry strip', (
    tester,
  ) async {
    home.matches.assignAll([_match('done', status: 'completed')]);
    home.loadError.value = 'boom';
    await pump(tester);

    expect(find.byType(HomeStatusStrip), findsOneWidget);
    expect(find.byType(MatchListRow), findsOneWidget);

    await tester.tap(find.text('retry'));
    expect(home.loads, 1);
  });

  testWidgets('a match being deleted is inert', (tester) async {
    home.matches.assignAll([_match('now', innings: _innings())]);
    home.deletingMatchIds.add('now');
    await pump(tester);

    await tester.tap(find.text('Alpha now'), warnIfMissed: false);
    expect(home.opened, isEmpty);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a chip\'s tap ink is clipped to its own pill', (tester) async {
    home.matches.assignAll([_match('a', innings: _innings())]);
    await pump(tester);

    final inkWell = tester.widget<InkWell>(chip('status_live'));
    expect(inkWell.customBorder, isA<StadiumBorder>());

    // The ink paints on the nearest Material, which must be the pill itself
    // (same shape, clipping on) — not the page behind it, where the splash
    // showed as a halo around the chip.
    final material = tester.widget<Material>(
      find
          .ancestor(of: chip('status_live'), matching: find.byType(Material))
          .first,
    );
    expect(material.shape, isA<StadiumBorder>());
    expect(material.clipBehavior, Clip.antiAlias);
  });
}
