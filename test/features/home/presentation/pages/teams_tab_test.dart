import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_teams_controller.dart';
import 'package:cricket_scorer/features/home/presentation/pages/teams_tab.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_list_skeleton.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_search_empty_state.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/home_status_strip.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/team_row.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/get_my_organizations.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/remove_organization_member.dart';
import 'package:cricket_scorer/features/organization/presentation/controllers/organizations_list_controller.dart';
import 'package:cricket_scorer/features/organization/presentation/pages/organizations_list_screen.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeGetMyTeams implements GetMyTeamsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeGetMyOrganizations implements GetMyOrganizationsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeCreateOrganization implements CreateOrganizationUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _FakeRemoveMember implements RemoveOrganizationMemberUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// Holds whatever state a test sets and only counts reloads, so the tab's
/// rendering is exercised without a network.
class _TeamsController extends MyTeamsController {
  _TeamsController() : super(getMyTeamsUseCase: _FakeGetMyTeams());

  int reloads = 0;

  @override
  Future<void> loadMyTeams() async => reloads++;
}

class _OrgsController extends OrganizationsListController {
  _OrgsController()
    : super(
        getMyOrganizationsUseCase: _FakeGetMyOrganizations(),
        createOrganizationUseCase: _FakeCreateOrganization(),
        removeOrganizationMemberUseCase: _FakeRemoveMember(),
        currentUserId: 'u1',
      );

  int reloads = 0;

  @override
  Future<void> loadOrganizations() async => reloads++;
}

List<TeamSummary> _teams(int n) => [
  for (var i = 0; i < n; i++) TeamSummary(id: 't$i', name: 'Team $i'),
];

void main() {
  late _TeamsController teams;
  late _OrgsController orgs;

  setUp(() {
    teams = _TeamsController()..isLoading.value = false;
    orgs = _OrgsController()..isLoading.value = false;
    // Registered under the real types: the tab looks them up by those.
    Get.put<MyTeamsController>(teams);
    Get.put<OrganizationsListController>(orgs);
    // onInit fetched once on registration; count only what a test triggers.
    teams.reloads = 0;
    orgs.reloads = 0;
  });

  tearDown(Get.reset);

  Future<void> pumpTab(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(800, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.lightTheme, home: const TeamsTab()),
    );
  }

  testWidgets('shows a skeleton per section while the first load runs', (
    tester,
  ) async {
    teams.isLoading.value = true;
    orgs.isLoading.value = true;

    await pumpTab(tester);

    expect(find.byType(HomeListSkeleton), findsNWidgets(2));
  });

  testWidgets('both sections empty: a hint and a create action', (
    tester,
  ) async {
    await pumpTab(tester);

    expect(find.text(TranslationKeys.myTeamsEmptyHint.tr), findsOneWidget);
    expect(find.text(TranslationKeys.noOrganizationsYet.tr), findsOneWidget);
    expect(
      find.text(TranslationKeys.createOrganization.tr),
      findsOneWidget,
      reason: 'the empty state carries the button; the header "+" is a tooltip',
    );
    expect(
      find.byTooltip(TranslationKeys.createOrganization.tr),
      findsOneWidget,
    );
  });

  testWidgets('a failed teams load says so and offers a retry, not the empty '
      'hint', (tester) async {
    teams.loadError.value = 'boom';

    await pumpTab(tester);

    expect(find.byType(HomeStatusStrip), findsOneWidget);
    expect(find.text(TranslationKeys.myTeamsEmptyHint.tr), findsNothing);

    await tester.tap(find.text(TranslationKeys.retry.tr));
    await tester.pump();

    expect(teams.reloads, 1);
    expect(orgs.reloads, 0);
  });

  testWidgets('a failed refresh keeps the teams already loaded on screen', (
    tester,
  ) async {
    teams.teams.assignAll(_teams(2));
    teams.loadError.value = 'boom';

    await pumpTab(tester);

    expect(find.byType(HomeStatusStrip), findsOneWidget);
    expect(find.byType(TeamRow), findsNWidgets(2));
  });

  testWidgets('shows four teams, and See all expands the rest in place', (
    tester,
  ) async {
    teams.teams.assignAll(_teams(6));

    await pumpTab(tester);

    expect(find.byType(TeamRow), findsNWidgets(4));
    expect(find.text('6'), findsOneWidget, reason: 'the section count');

    await tester.tap(find.text(TranslationKeys.seeAll.tr));
    await tester.pump();

    expect(find.byType(TeamRow), findsNWidgets(6));
    expect(find.text(TranslationKeys.seeAll.tr), findsNothing);
  });

  testWidgets('four or fewer teams have nothing to expand', (tester) async {
    teams.teams.assignAll(_teams(4));

    await pumpTab(tester);

    expect(find.byType(TeamRow), findsNWidgets(4));
    expect(find.text(TranslationKeys.seeAll.tr), findsNothing);
  });

  testWidgets('previews three organizations and links to the rest', (
    tester,
  ) async {
    orgs.organizations.assignAll([
      for (var i = 0; i < 5; i++)
        OrganizationSummaryRes(
          id: 'o$i',
          name: 'Org $i',
          myRole: i == 0 ? 'owner' : 'member',
          memberCount: 10,
          teamCount: 2,
        ),
    ]);

    await pumpTab(tester);

    expect(find.byType(OrganizationRow), findsNWidgets(3));
    expect(find.text(TranslationKeys.seeAll.tr), findsOneWidget);
    expect(find.text(TranslationKeys.roleOwner.tr), findsOneWidget);
    expect(find.text(TranslationKeys.roleMember.tr), findsNWidgets(2));
    expect(find.text('owner'), findsNothing, reason: 'never the raw role');
  });

  group('search', () {
    void seedTeamsAndOrgs() {
      teams.teams.assignAll([
        TeamSummary(
          id: 't1',
          name: 'Mumbai Indians',
          organization: OrganizationRef(id: 'o1', name: 'Shivaji Park CC'),
        ),
        TeamSummary(
          id: 't2',
          name: 'Thane Warriors',
          organization: OrganizationRef(id: 'o1', name: 'Shivaji Park CC'),
        ),
        TeamSummary(id: 't3', name: 'Sunday Sixers'),
      ]);
      orgs.organizations.assignAll([
        OrganizationSummaryRes(
          id: 'o1',
          name: 'Shivaji Park CC',
          myRole: 'owner',
          memberCount: 12,
          teamCount: 2,
        ),
        OrganizationSummaryRes(
          id: 'o2',
          name: 'Gully Cricket League',
          myRole: 'member',
          memberCount: 40,
          teamCount: 8,
        ),
      ]);
    }

    Future<void> openSearch(WidgetTester tester) async {
      await tester.tap(find.byTooltip(TranslationKeys.search.tr));
      await tester.pump();
    }

    Future<void> type(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
    }

    testWidgets('the icon opens a field in place, not another screen', (
      tester,
    ) async {
      seedTeamsAndOrgs();
      await pumpTab(tester);

      await openSearch(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(TeamsTab), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text(TranslationKeys.searchTeamsHint.tr), findsOneWidget);
      expect(find.byType(TeamRow), findsNWidgets(3), reason: 'nothing typed');
    });

    testWidgets('filters teams by their own name', (tester) async {
      seedTeamsAndOrgs();
      await pumpTab(tester);
      await openSearch(tester);

      await type(tester, 'mumbai');

      expect(find.byType(TeamRow), findsOneWidget);
      expect(find.text('Mumbai Indians'), findsOneWidget);
      expect(
        find.byType(OrganizationRow),
        findsNothing,
        reason: 'no organization matches, so the section is dropped',
      );
    });

    testWidgets('finds a team through its organization name', (tester) async {
      seedTeamsAndOrgs();
      await pumpTab(tester);
      await openSearch(tester);

      await type(tester, 'shivaji');

      expect(find.byType(TeamRow), findsNWidgets(2));
      expect(find.byType(OrganizationRow), findsOneWidget);
    });

    testWidgets('ignores case and surrounding spaces', (tester) async {
      seedTeamsAndOrgs();
      await pumpTab(tester);
      await openSearch(tester);

      await type(tester, '  SUNDAY ');

      expect(find.byType(TeamRow), findsOneWidget);
      expect(find.text('Sunday Sixers'), findsOneWidget);
    });

    testWidgets('shows every match rather than stopping at four', (
      tester,
    ) async {
      teams.teams.assignAll(_teams(6));
      await pumpTab(tester);
      await openSearch(tester);

      await type(tester, 'team');

      expect(find.byType(TeamRow), findsNWidgets(6));
      expect(find.text(TranslationKeys.seeAll.tr), findsNothing);
    });

    testWidgets('a search with no match says so, and Clear brings the lists '
        'back', (tester) async {
      seedTeamsAndOrgs();
      await pumpTab(tester);
      await openSearch(tester);

      await type(tester, 'zzz');

      expect(find.byType(TeamRow), findsNothing);
      expect(find.byType(OrganizationRow), findsNothing);
      expect(
        find.text(
          TranslationKeys.noTeamsSearchResults.trParams({'query': 'zzz'}),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text(TranslationKeys.clearSearch.tr).last);
      await tester.pump();

      expect(find.byType(TeamRow), findsNWidgets(3));
      expect(find.byType(OrganizationRow), findsNWidgets(2));
    });

    testWidgets('the back arrow closes the field and restores the lists', (
      tester,
    ) async {
      seedTeamsAndOrgs();
      await pumpTab(tester);
      await openSearch(tester);
      await type(tester, 'mumbai');

      await tester.tap(find.byTooltip(TranslationKeys.cancel.tr));
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
      expect(find.text(TranslationKeys.navTeams.tr), findsOneWidget);
      expect(find.byType(TeamRow), findsNWidgets(3));
    });

    testWidgets('never claims "nothing found" while a load has failed', (
      tester,
    ) async {
      teams.loadError.value = 'boom';
      await pumpTab(tester);
      await openSearch(tester);

      await type(tester, 'zzz');

      expect(find.byType(HomeStatusStrip), findsOneWidget);
      expect(find.byType(HomeSearchEmptyState), findsNothing);
    });
  });
}
