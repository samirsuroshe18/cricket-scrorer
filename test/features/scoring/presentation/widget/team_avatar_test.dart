import 'package:cached_network_image/cached_network_image.dart';
import 'package:cricket_scorer/config/theme/app_theme.dart';
import 'package:cricket_scorer/features/scoring/presentation/widget/team_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

Widget _host(Widget child) => GetMaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('shows first+last word initials when there is no logo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const TeamAvatar(name: 'Mumbai Indians', color: Colors.blue)),
    );

    expect(find.text('MI'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('a single-word name uses its first two letters', (tester) async {
    await tester.pumpWidget(
      _host(const TeamAvatar(name: 'Titans', color: Colors.blue)),
    );

    expect(find.text('TI'), findsOneWidget);
  });

  testWidgets('an empty name falls back to a question mark', (tester) async {
    await tester.pumpWidget(
      _host(const TeamAvatar(name: '   ', color: Colors.blue)),
    );

    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('an empty logoUrl is treated as no logo', (tester) async {
    await tester.pumpWidget(
      _host(const TeamAvatar(name: 'Mumbai Indians', color: Colors.blue, logoUrl: '')),
    );

    expect(find.text('MI'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('renders the network logo when logoUrl is set', (tester) async {
    await tester.pumpWidget(
      _host(
        const TeamAvatar(
          name: 'Mumbai Indians',
          color: Colors.blue,
          logoUrl: 'https://res.cloudinary.com/demo/mumbai.png',
        ),
      ),
    );

    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });
}
