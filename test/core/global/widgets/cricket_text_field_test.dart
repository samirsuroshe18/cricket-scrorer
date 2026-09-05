import 'package:cricket_scorer/core/global/widgets/cricket_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// No credential field anywhere in the app declared `autofillHints`, so no
// password manager could offer to fill or save on any of them — the fix
// threads an `autofillHints` param through to the underlying TextFormField.
// This pins that wiring: a hint passed to CricketTextField must actually
// reach the rendered field, not just exist as an unused constructor param.
void main() {
  testWidgets('passes autofillHints through to the underlying TextFormField', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CricketTextField(
            autofillHints: [AutofillHints.email, AutofillHints.username],
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(
      field.autofillHints,
      containsAll([AutofillHints.email, AutofillHints.username]),
    );
  });

  testWidgets('defaults to no autofill hints when none are given', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CricketTextField())),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.autofillHints, isNull);
  });
}
