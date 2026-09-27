import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/translations/en.dart';
import 'package:cricket_scorer/core/translations/translation_keys.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/playing_for_section.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/playing_for_teams_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Widget _host(List<PlayingForTeam> teams, void Function(String) onTap) =>
    GetMaterialApp(
      theme: AppTheme.lightTheme,
      translations: _EnglishOnly(),
      locale: const Locale('en'),
      home: Scaffold(
        body: PlayingForSection(teams: teams, onTap: onTap),
      ),
    );

class _EnglishOnly extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en': en};
}

void main() {
  testWidgets('renders nothing at all when there are no teams', (tester) async {
    await tester.pumpWidget(_host(const [], (_) {}));

    expect(find.text(en[TranslationKeys.teamsIPlayFor]!), findsNothing);
    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('shows the header and a row per team with my player name', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([
        PlayingForTeam(
          id: 't1',
          name: 'Mumbai Indians',
          myPlayerName: 'Mohit Zatu',
        ),
        PlayingForTeam(id: 't2', name: 'Riverside', myPlayerName: 'Mohit'),
      ], (_) {}),
    );

    expect(find.text('Teams I play for'), findsOneWidget);
    expect(find.text('Mumbai Indians'), findsOneWidget);
    expect(find.text('Playing as Mohit Zatu'), findsOneWidget);
    expect(find.text('Riverside'), findsOneWidget);
  });

  testWidgets('tapping a row reports that team id', (tester) async {
    String? tapped;
    await tester.pumpWidget(
      _host([
        PlayingForTeam(
          id: 't1',
          name: 'Mumbai Indians',
          myPlayerName: 'Mohit Zatu',
        ),
      ], (id) => tapped = id),
    );

    await tester.tap(find.text('Mumbai Indians'));

    expect(tapped, 't1');
  });
}
