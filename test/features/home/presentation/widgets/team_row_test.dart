import 'package:cached_network_image/cached_network_image.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/core/global/widgets/cricket_grouped_card.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/team_row.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Widget _host(TeamSummary team, {ThemeData? theme}) => GetMaterialApp(
  theme: theme ?? AppTheme.lightTheme,
  home: Scaffold(
    body: Center(
      child: CricketGroupedCard(children: [TeamRow(team: team)]),
    ),
  ),
);

void main() {
  testWidgets('shows the full name and a monogram without a logo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(TeamSummary(id: 't1', name: 'Mumbai Indians')),
    );

    expect(find.text('Mumbai Indians'), findsOneWidget);
    expect(find.text('MI'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('an empty logoUrl is treated as no logo', (tester) async {
    await tester.pumpWidget(
      _host(TeamSummary(id: 't1', name: 'Mumbai Indians', logoUrl: '')),
    );

    expect(find.text('MI'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('renders the network logo when logoUrl is set', (tester) async {
    await tester.pumpWidget(
      _host(
        TeamSummary(
          id: 't1',
          name: 'Mumbai Indians',
          logoUrl: 'https://res.cloudinary.com/demo/mumbai.png',
        ),
      ),
    );

    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });

  testWidgets('shows the organization name when the team belongs to one', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        TeamSummary(
          id: 't1',
          name: 'Mumbai Indians',
          organization: OrganizationRef(id: 'o1', name: 'Shivaji Park CC'),
        ),
      ),
    );

    expect(find.text('Shivaji Park CC'), findsOneWidget);
  });

  testWidgets('shows no second line for a standalone team', (tester) async {
    await tester.pumpWidget(
      _host(TeamSummary(id: 't1', name: 'Sunday Sixers')),
    );

    expect(find.text('Sunday Sixers'), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('lays out in the dark theme at a large text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _host(
          TeamSummary(
            id: 't1',
            name: 'Mumbai Indians Under Nineteen Colts',
            organization: OrganizationRef(
              id: 'o1',
              name: 'Shivaji Park Cricket Club',
            ),
          ),
          theme: AppTheme.darkTheme,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
