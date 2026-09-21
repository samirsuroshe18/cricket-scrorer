import 'dart:async';

import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_teams_controller.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/create_team_sheet.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/create_team.dart';
import 'package:cricket_scorer/features/scoring/domain/usecases/get_my_teams.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Unused1 implements GetMyTeamsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _Unused2 implements CreateTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

class _Unused3 implements CreateOrganizationTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Not exercised in this test.');
}

/// Records what the form asked for and lets a test decide when (and how) the
/// request resolves.
class _TeamsController extends MyTeamsController {
  _TeamsController()
    : super(
        getMyTeamsUseCase: _Unused1(),
        createTeamUseCase: _Unused2(),
        createOrganizationTeamUseCase: _Unused3(),
      );

  final calls = <({String name, String? shortName, String? organizationId})>[];
  Completer<String?>? pending;
  String? result;

  @override
  Future<String?> createTeam({
    required String name,
    String? shortName,
    String? organizationId,
  }) {
    calls.add((
      name: name,
      shortName: shortName,
      organizationId: organizationId,
    ));
    return pending?.future ?? Future.value(result);
  }
}

OrganizationSummaryRes _org(String id, String name) => OrganizationSummaryRes(
  id: id,
  name: name,
  myRole: 'owner',
  memberCount: 1,
  teamCount: 0,
);

void main() {
  late _TeamsController teams;
  String? createdIn;
  var createdCalls = 0;

  setUp(() {
    Get.testMode = true;
    teams = _TeamsController()..isLoading.value = false;
    createdIn = null;
    createdCalls = 0;
  });

  tearDown(Get.reset);

  Future<void> pumpForm(
    WidgetTester tester, {
    List<OrganizationSummaryRes> owned = const [],
  }) async {
    tester.view
      ..physicalSize = const Size(800, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CreateTeamForm(
              teams: teams,
              ownedOrganizations: owned,
              onCreated: (organizationId) {
                createdCalls++;
                createdIn = organizationId;
              },
            ),
          ),
        ),
      ),
    );
  }

  Finder field(int index) => find.byType(TextField).at(index);

  Future<void> tapCreate(WidgetTester tester) async {
    await tester.tap(find.text(TranslationKeys.createTeam.tr));
    await tester.pump();
  }

  testWidgets('an empty name shows the required message and sends nothing', (
    tester,
  ) async {
    await pumpForm(tester);

    await tapCreate(tester);

    expect(find.text(TranslationKeys.teamNameRequired.tr), findsOneWidget);
    expect(teams.calls, isEmpty);
  });

  testWidgets('a whitespace-only name counts as empty', (tester) async {
    await pumpForm(tester);
    await tester.enterText(field(0), '    ');

    await tapCreate(tester);

    expect(find.text(TranslationKeys.teamNameRequired.tr), findsOneWidget);
    expect(teams.calls, isEmpty);
  });

  testWidgets('a name already in My teams is caught before any request, '
      'ignoring case and surrounding spaces', (tester) async {
    teams.teams.assignAll([TeamSummary(id: 't1', name: 'Mumbai Indians')]);
    await pumpForm(tester);
    await tester.enterText(field(0), '  mumbai INDIANS ');

    await tapCreate(tester);

    expect(
      find.text(
        TranslationKeys.teamNameExists.trParams({'name': 'mumbai INDIANS'}),
      ),
      findsOneWidget,
    );
    expect(teams.calls, isEmpty);
  });

  testWidgets('sends the trimmed name and short name, independent by default', (
    tester,
  ) async {
    await pumpForm(tester);
    await tester.enterText(field(0), '  Sunday Sixers ');
    await tester.enterText(field(1), ' ss ');

    await tapCreate(tester);
    await tester.pump();

    expect(teams.calls, hasLength(1));
    expect(teams.calls.single.name, 'Sunday Sixers');
    expect(teams.calls.single.shortName, 'ss');
    expect(teams.calls.single.organizationId, isNull);
    expect(createdCalls, 1);
    expect(createdIn, isNull);
  });

  testWidgets('a blank short name is sent as null', (tester) async {
    await pumpForm(tester);
    await tester.enterText(field(0), 'Office XI');
    await tester.enterText(field(1), '   ');

    await tapCreate(tester);
    await tester.pump();

    expect(teams.calls.single.shortName, isNull);
  });

  testWidgets('hides "Belongs to" when the caller owns no organization', (
    tester,
  ) async {
    await pumpForm(tester);

    expect(find.text(TranslationKeys.teamBelongsTo.tr), findsNothing);
    expect(find.text(TranslationKeys.teamIndependent.tr), findsNothing);
  });

  testWidgets('lists Independent and each owned organization, and creates '
      'under the chosen one', (tester) async {
    await pumpForm(
      tester,
      owned: [_org('o1', 'Riverside CC'), _org('o2', 'Shivaji Park CC')],
    );

    expect(find.text(TranslationKeys.teamBelongsTo.tr), findsOneWidget);
    expect(find.text(TranslationKeys.teamIndependent.tr), findsOneWidget);
    expect(find.text('Riverside CC'), findsOneWidget);

    await tester.enterText(field(0), 'Riverside U19');
    await tester.tap(find.text('Riverside CC'));
    await tester.pump();
    await tapCreate(tester);
    await tester.pump();

    expect(teams.calls.single.organizationId, 'o1');
    expect(createdIn, 'o1');
  });

  testWidgets('shows a server error inline and keeps what was typed', (
    tester,
  ) async {
    teams.result = 'A team name can be at most 50 characters';
    await pumpForm(tester);
    await tester.enterText(field(0), 'Sunday Sixers');

    await tapCreate(tester);
    await tester.pump();

    expect(
      find.text('A team name can be at most 50 characters'),
      findsOneWidget,
    );
    expect(find.text('Sunday Sixers'), findsOneWidget);
    expect(createdCalls, 0);
  });

  testWidgets('a second tap while the request is in flight sends nothing '
      'more', (tester) async {
    teams.pending = Completer<String?>();
    await pumpForm(tester);
    await tester.enterText(field(0), 'Sunday Sixers');

    await tapCreate(tester);
    await tapCreate(tester);
    await tapCreate(tester);

    expect(teams.calls, hasLength(1));

    teams.pending!.complete(null);
    await tester.pump();

    expect(createdCalls, 1);
  });

  testWidgets('does not report success if the sheet was closed while the '
      'request was still running', (tester) async {
    teams.pending = Completer<String?>();
    await pumpForm(tester);
    await tester.enterText(field(0), 'Sunday Sixers');
    await tapCreate(tester);

    await tester.pumpWidget(const SizedBox.shrink());
    teams.pending!.complete(null);
    await tester.pump();

    expect(createdCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out in dark theme at a large text scale', (tester) async {
    tester.view
      ..physicalSize = const Size(800, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: GetMaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: CreateTeamForm(
                teams: teams,
                ownedOrganizations: [
                  _org('o1', 'Shivaji Park Cricket Club of Mumbai'),
                ],
                onCreated: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
