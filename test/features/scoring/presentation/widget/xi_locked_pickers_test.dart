import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_button.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/strike.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/team_profile_res.dart';
import 'package:cricket_scorer/features/scoring/data/scoring_constants.dart';
import 'package:cricket_scorer/features/scoring/domain/bowler_ref.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/next_bowler_bottom_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/openers_bottom_sheet.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/wicket_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// When a side has a Playing XI set, the server refuses anyone outside it — a
// brand-new typed name included — so the pickers offer the XI's chips only and
// the name field stops accepting typing.
TeamRosterPlayer _r(String id, String name) =>
    TeamRosterPlayer(playerId: id, playerName: name, role: 'batsman');

Future<void> _open(WidgetTester tester, void Function() show) async {
  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) =>
              ElevatedButton(onPressed: show, child: const Text('open')),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

// A real reactive read: the sheets' undo Obx needs a subscription to be well
// formed, exactly as in the other sheet tests.
final RxBool _canUndo = false.obs;

bool _readOnly(WidgetTester tester, Finder field) =>
    tester.widget<TextField>(field).readOnly;

void main() {
  group('OpenersBottomSheet', () {
    void show({required bool lock, required List<Object?> sent}) =>
        OpenersBottomSheet.show(
          onSubmit:
              (
                striker,
                nonStriker,
                bowler, {
                strikerId,
                nonStrikerId,
                bowlerId,
              }) async {
                sent.addAll([striker, nonStriker, bowler, strikerId, bowlerId]);
                return true;
              },
          isSubmitting: false.obs,
          canUndo: () => _canUndo.value,
          isUndoing: false.obs,
          onUndo: () async => false,
          battingRoster: [_r('a1', 'Rohit'), _r('a2', 'Pant')],
          bowlingRoster: [_r('b1', 'Bumrah')],
          lockToRoster: lock,
        );

    testWidgets('unlocked, the name fields stay typeable', (tester) async {
      await _open(tester, () => show(lock: false, sent: []));

      for (final field in tester.widgetList<TextField>(
        find.byType(TextField),
      )) {
        expect(field.readOnly, isFalse);
      }
    });

    testWidgets(
      'locked, every name field is read-only but a chip still fills it',
      (
        tester,
      ) async {
        final sent = <Object?>[];
        await _open(tester, () => show(lock: true, sent: sent));

        final fields = find.byType(TextField);
        expect(fields, findsNWidgets(3));
        for (final field in tester.widgetList<TextField>(fields)) {
          expect(field.readOnly, isTrue);
        }

        Future<void> pick(String key, String name) async {
          final chip = find.descendant(
            of: find.byKey(ValueKey(key)),
            matching: find.text(name),
          );
          await tester.ensureVisible(chip);
          await tester.tap(chip);
          await tester.pump();
        }

        await pick('opener-picker-striker', 'Rohit');
        await pick('opener-picker-non-striker', 'Pant');
        await pick('opener-picker-bowler', 'Bumrah');
        await tester.ensureVisible(find.byType(CricketButton));
        await tester.tap(find.byType(CricketButton));
        await tester.pumpAndSettle();

        expect(sent, ['Rohit', 'Pant', 'Bumrah', 'a1', 'b1']);
      },
    );
  });

  group('NextBowlerBottomSheet', () {
    void show({required bool lock}) => NextBowlerBottomSheet.show(
      excludedBowlerName: null,
      knownBowlers: const [BowlerRef(id: 'b1', name: 'Bumrah')],
      isSubmitting: false.obs,
      onSubmit: (name, {bowlerId}) async => true,
      canUndo: () => _canUndo.value,
      isUndoing: false.obs,
      onUndo: () async => true,
      lockToRoster: lock,
    );

    testWidgets('unlocked, the name field stays typeable', (tester) async {
      await _open(tester, () => show(lock: false));

      expect(_readOnly(tester, find.byType(TextField)), isFalse);
    });

    testWidgets('locked, the name field is read-only', (tester) async {
      await _open(tester, () => show(lock: true));

      expect(_readOnly(tester, find.byType(TextField)), isTrue);
      expect(find.widgetWithText(ChoiceChip, 'Bumrah'), findsOneWidget);
    });
  });

  group('WicketBottomSheet', () {
    late List<String?> incoming;

    void show({List<TeamRosterPlayer>? xiRoster}) => WicketBottomSheet.show(
      strike: Strike(strikerName: 'Rohit', nonStrikerName: 'Pant'),
      extraType: null,
      isFinalWicket: false,
      isSubmitting: false.obs,
      xiRoster: xiRoster,
      onSubmit:
          ({
            required wicketType,
            required dismissedBatsman,
            required runs,
            incomingBatsmanName,
          }) async {
            incoming.add(incomingBatsmanName);
            return true;
          },
    );

    setUp(() => incoming = []);

    testWidgets('with no XI the incoming batsman is typed, as before', (
      tester,
    ) async {
      await _open(tester, show);

      expect(_readOnly(tester, find.byType(TextField)), isFalse);
      expect(find.byType(ChoiceChip), findsNothing);
    });

    testWidgets('with an XI the incoming batsman is picked from its chips', (
      tester,
    ) async {
      await _open(
        tester,
        () => show(
          xiRoster: [_r('a1', 'Rohit'), _r('a2', 'Pant'), _r('a3', 'Kohli')],
        ),
      );

      expect(_readOnly(tester, find.byType(TextField)), isTrue);
      // Whoever is already at the crease cannot come in.
      expect(find.widgetWithText(ChoiceChip, 'Kohli'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Rohit'), findsNothing);
      expect(find.widgetWithText(ChoiceChip, 'Pant'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'bowled'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Kohli'));
      await tester.pump();
      await tester.tap(find.byType(CricketButton).last);
      await tester.pumpAndSettle();

      expect(incoming, ['Kohli']);
    });

    testWidgets('an XI with nobody left to come in still shows the empty field', (
      tester,
    ) async {
      await _open(tester, () => show(xiRoster: [_r('a1', 'Rohit')]));

      expect(find.byType(ChoiceChip), findsNothing);
      expect(_readOnly(tester, find.byType(TextField)), isTrue);
      // WicketType is referenced so a rename of the constants breaks this file.
      expect(WicketType.bowled, isNotEmpty);
    });
  });
}
