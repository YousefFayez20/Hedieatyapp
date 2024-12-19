import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'logintest.dart';

void main() {
  group('Login Page Tests', () {
    testWidgets('Should display email and password fields and login button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(),
        ),
      );

      expect(find.byKey(Key('emailField')), findsOneWidget);
      expect(find.byKey(Key('passwordField')), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('Should allow text input in email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
      await tester.enterText(find.byKey(Key('passwordField')), 'password123');

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
