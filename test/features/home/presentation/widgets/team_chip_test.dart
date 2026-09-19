import 'package:cached_network_image/cached_network_image.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/home/presentation/widgets/team_chip.dart';
import 'package:cricket_scorer/features/scoring/data/models/response/my_teams_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Widget _host(TeamSummary team) => GetMaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: Center(child: TeamChip(team: team))),
);

void main() {
  testWidgets('shows the monogram and no network image without a logo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(TeamSummary(id: 't1', name: 'Mumbai Indians')),
    );

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

  testWidgets('labels the chip with shortName when there is one', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(TeamSummary(id: 't1', name: 'Mumbai Indians', shortName: 'MI')),
    );

    expect(find.text('MI'), findsWidgets);
    expect(find.text('Mumbai Indians'), findsNothing);
  });
}
