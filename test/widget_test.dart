import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expence_tracking/app/app.dart';

void main() {
  Future<void> pumpToAuthLanding(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
  }

  testWidgets('shows launch splash then auth landing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExpenseTracingApp());

    expect(find.text('FinWise'), findsOneWidget);

    await pumpToAuthLanding(tester);

    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('navigates login to signup', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTracingApp());
    await pumpToAuthLanding(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up').first);
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('navigates to forgot password from auth landing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ExpenseTracingApp());
    await pumpToAuthLanding(tester);

    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset Password?'), findsOneWidget);
    expect(find.text('Next Step'), findsOneWidget);
  });

  testWidgets('logs in and opens dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTracingApp());
    await pumpToAuthLanding(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'demo@finwise.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '12345678');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log In').first);
    await tester.pumpAndSettle();

    expect(find.text('FinWise Dashboard'), findsOneWidget);
    expect(find.text('Current Balance'), findsOneWidget);
  });
}
