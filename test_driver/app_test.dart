import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Hedieaty App Integration Tests', () {
    FlutterDriver? driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await Future.delayed(Duration(seconds: 3)); // Allow app to initialize
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver!.close();
      }
    });

    test('Sign-Up Workflow', () async {
      // Press the "Get Started" button
      await driver!.tap(find.text('Get Started'));

      // Navigate to Sign-Up
      await driver!.tap(find.byValueKey('navigate_to_sign_up'));
      await driver!.tap(find.byValueKey('name'));
      await driver!.enterText('Test User');
      await driver!.tap(find.byValueKey('email'));
      await driver!.enterText('testuser@example.com');
      await driver!.tap(find.byValueKey('password'));
      await driver!.enterText('password123');
      await driver!.tap(find.byValueKey('confirm_password'));
      await driver!.enterText('password123');
      await driver!.tap(find.byValueKey('sign_up_button'));

      // Validate navigation back to the login page
      await Future.delayed(Duration(seconds: 2)); // Allow transition
      final loginScreen = await driver!.getText(find.byValueKey('login_screen_text'));
      expect(loginScreen, contains('Log In')); // Validate login screen
    });

    test('Log-In Workflow', () async {


      // Log in with valid credentials
      await driver!.tap(find.byValueKey('login_email_field'));
      await driver!.enterText('testuser@example.com');
      await driver!.tap(find.byValueKey('login_password_field'));
      await driver!.enterText('password123');
      await driver!.tap(find.byValueKey('login_button'));

      // Validate navigation to the home page
      await Future.delayed(Duration(seconds: 2)); // Allow transition
      final homeScreen = await driver!.getText(find.byValueKey('home_screen_text'));
      expect(homeScreen, contains('Friends & Events')); // Validate home screen
    });

    test('Create Personal Event', () async {
      // Press the "Get Started" button
/*
      // Log in first
      await driver!.tap(find.byValueKey('email'));
      await driver!.enterText('testuser@example.com');
      await driver!.tap(find.byValueKey('password'));
      await driver!.enterText('password123');
      await driver!.tap(find.byValueKey('login_button'));

 */

      // Navigate to event creation
      await driver!.tap(find.byValueKey('add_event_button'));
      await driver!.tap(find.byValueKey('event_name'));
      await driver!.enterText('Birthday Party');
      await driver!.tap(find.byValueKey('event_location'));
      await driver!.enterText('Heliopolis');
      await driver!.tap(find.byValueKey('save_event_button'));

      // Validate the new event in the event list
      await Future.delayed(Duration(seconds: 2)); // Allow transition

    });
  });
}
