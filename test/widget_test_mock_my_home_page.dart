import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'mock_my_home_page.dart'; // Path to the mock MyHomePage

void main() {
  group('MockMyHomePage Tests', () {
    testWidgets('Should display logo and Get Started button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MockMyHomePage(),
        ),
      );

      // Verify the presence of the logo image
      expect(find.byKey(Key('logoImage')), findsOneWidget);

      // Verify the presence of the Get Started button
      expect(find.byKey(Key('getStartedButton')), findsOneWidget);
    });

    testWidgets('Should navigate to LoginPage when Get Started button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MockMyHomePage(),
        ),
      );

      // Tap the Get Started button
      await tester.tap(find.byKey(Key('getStartedButton')));
      await tester.pumpAndSettle();

      // Verify navigation to LoginPage
      expect(find.text('Log In'), findsOneWidget);
    });
  });
}
