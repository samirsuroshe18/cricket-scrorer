import 'package:cricket_scorer/config/app_config.dart';
import 'package:cricket_scorer/config/flavors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    AppFlavor.setAppFlavor(Flavor.dev); // set flavor before any test runs
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CricketScorerApp());
    expect(find.byType(CricketScorerApp), findsOneWidget);
  });
}
