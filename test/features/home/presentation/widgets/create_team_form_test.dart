import 'dart:async';

import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/controllers/my_teams_controller.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/create_team_sheet.dart';
import 'package:cricket_scorer/features/organization/data/models/response/organization_summary_res.dart';
import 'package:cricket_scorer/features/organization/domain/usecases/create_organization_team.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:cricket_scorer/features/scoring/domain/team_field_limits.dart';
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

  final calls =
      <
        ({
          String name,
          String? shortName,
          String? organizationId,
          String? organizationName,
        })
      >[];
  Completer<String?>? pending;
  String? result;

  @override
  Future<String?> createTeam({
    required String name,
    String? shortName,
    String? organizationId,
    String? organizationName,
  }) {
    calls.add((
      name: name,
      shortName: shortName,
      organizationId: organizationId,
      organizationName: organizationName,
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
  final orgNotified = <String>[];

  setUp(() {
    Get.testMode = true;
    teams = _TeamsController()..isLoading.value = false;
    createdIn = null;
    createdCalls = 0;
    orgNotified.clear();
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
              onOrganizationTeamCreated: orgNotified.add,
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

  test('the form uses the shared team field length limits', () {
    expect(maxTeamNameLength, 50);
    expect(maxShortNameLength, 5);
  });

  group('length is counted the way the server counts it', () {
    // The field's counter and formatter count user-perceived characters
    // (graphemes); the backend and Mongoose count UTF-16 code units. A
    // Devanagari or emoji name can be under the limit on screen and over it
    // on the wire.
    const longDevanagari =
        'टीमचे नाव जास्तीत जास्त पन्नास अक्षरांचे असू शकते ओके';

    test('the fixtures really differ between the two ways of counting', () {
      expect(longDevanagari.characters.length, lessThanOrEqualTo(50));
      expect(longDevanagari.length, greaterThan(50));
      expect('🏏🏏🏏'.characters.length, lessThanOrEqualTo(5));
      expect('🏏🏏🏏'.length, greaterThan(5));
    });

    testWidgets('a name over 50 UTF-16 units is rejected before any request', (
      tester,
    ) async {
      await pumpForm(tester);
      await tester.enterText(field(0), longDevanagari);

      await tapCreate(tester);

      expect(find.text(TranslationKeys.teamNameTooLong.tr), findsOneWidget);
      expect(teams.calls, isEmpty);
    });

    testWidgets('a short name over 5 UTF-16 units is rejected before any '
        'request', (tester) async {
      await pumpForm(tester);
      await tester.enterText(field(0), 'Sunday Sixers');
      await tester.enterText(field(1), '🏏🏏🏏');

      await tapCreate(tester);

      expect(
        find.text(TranslationKeys.teamShortNameTooLong.tr),
        findsOneWidget,
      );
      expect(teams.calls, isEmpty);
    });

    testWidgets('exactly 50 units and exactly 5 units are accepted', (
      tester,
    ) async {
      await pumpForm(tester);
      await tester.enterText(field(0), 'a' * 50);
      await tester.enterText(field(1), 'abcde');

      await tapCreate(tester);
      await tester.pump();

      expect(teams.calls, hasLength(1));
      expect(find.text(TranslationKeys.teamNameTooLong.tr), findsNothing);
    });

    testWidgets('the short-name error clears when the field is edited', (
      tester,
    ) async {
      await pumpForm(tester);
      await tester.enterText(field(0), 'Sunday Sixers');
      await tester.enterText(field(1), '🏏🏏🏏');
      await tapCreate(tester);

      await tester.enterText(field(1), 'SS');
      await tester.pump();

      expect(find.text(TranslationKeys.teamShortNameTooLong.tr), findsNothing);
    });
  });

  testWidgets('in a short sheet the form scrolls instead of overflowing', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(800, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            // The height a phone leaves for the sheet once the keyboard is up;
            // no scroll view around it, as in the real sheet.
            child: SizedBox(
              height: 260,
              child: CreateTeamForm(
                teams: teams,
                ownedOrganizations: [_org('o1', 'Riverside CC')],
                onCreated: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text(TranslationKeys.createTeam.tr));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  group('after a failed create', () {
    Future<void> failOnce(
      WidgetTester tester, {
      List<OrganizationSummaryRes> owned = const [],
    }) async {
      teams.result = 'A team name can be at most 50 characters';
      await pumpForm(tester, owned: owned);
      await tester.enterText(field(0), 'Sunday Sixers');
      await tapCreate(tester);
      await tester.pump();
      expect(
        find.text('A team name can be at most 50 characters'),
        findsOneWidget,
      );
    }

    testWidgets('the server message clears when the name is edited', (
      tester,
    ) async {
      await failOnce(tester);

      await tester.enterText(field(0), 'Sunday Sixers XI');
      await tester.pump();

      expect(
        find.text('A team name can be at most 50 characters'),
        findsNothing,
      );
    });

    testWidgets('the server message clears when the short name is edited', (
      tester,
    ) async {
      await failOnce(tester);

      await tester.enterText(field(1), 'SS');
      await tester.pump();

      expect(
        find.text('A team name can be at most 50 characters'),
        findsNothing,
      );
    });

    testWidgets('the server message clears when another Belongs to is '
        'chosen', (tester) async {
      await failOnce(tester, owned: [_org('o1', 'Riverside CC')]);

      await tester.tap(find.text('Riverside CC'));
      await tester.pump();

      expect(
        find.text('A team name can be at most 50 characters'),
        findsNothing,
      );
    });
  });

  group('organization teams', () {
    testWidgets('the chosen organization is passed by id and by name', (
      tester,
    ) async {
      await pumpForm(tester, owned: [_org('o1', 'Riverside CC')]);
      await tester.enterText(field(0), 'Riverside U19');
      await tester.tap(find.text('Riverside CC'));
      await tester.pump();

      await tapCreate(tester);
      await tester.pump();

      expect(teams.calls.single.organizationId, 'o1');
      expect(teams.calls.single.organizationName, 'Riverside CC');
    });

    testWidgets('the organization is told about the new team', (tester) async {
      await pumpForm(tester, owned: [_org('o1', 'Riverside CC')]);
      await tester.enterText(field(0), 'Riverside U19');
      await tester.tap(find.text('Riverside CC'));
      await tester.pump();

      await tapCreate(tester);
      await tester.pump();

      expect(orgNotified, ['o1']);
    });

    testWidgets('an independent team tells no organization', (tester) async {
      await pumpForm(tester, owned: [_org('o1', 'Riverside CC')]);
      await tester.enterText(field(0), 'Sunday Sixers');

      await tapCreate(tester);
      await tester.pump();

      expect(orgNotified, isEmpty);
    });

    testWidgets('the organization is still told when the sheet was closed '
        'while the request ran', (tester) async {
      teams.pending = Completer<String?>();
      await pumpForm(tester, owned: [_org('o1', 'Riverside CC')]);
      await tester.enterText(field(0), 'Riverside U19');
      await tester.tap(find.text('Riverside CC'));
      await tester.pump();
      await tapCreate(tester);

      await tester.pumpWidget(const SizedBox.shrink());
      teams.pending!.complete(null);
      await tester.pump();

      expect(orgNotified, ['o1']);
      expect(createdCalls, 0, reason: 'a closed sheet is not closed again');
    });

    testWidgets('a failed create tells no organization', (tester) async {
      teams.result = 'nope';
      await pumpForm(tester, owned: [_org('o1', 'Riverside CC')]);
      await tester.enterText(field(0), 'Riverside U19');
      await tester.tap(find.text('Riverside CC'));
      await tester.pump();

      await tapCreate(tester);
      await tester.pump();

      expect(orgNotified, isEmpty);
    });
  });
}
