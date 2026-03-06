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

    expect(find.text('Hi, Welcome Back'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
  });

  testWidgets('opens analysis tab from bottom bar', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.byKey(const ValueKey<String>('bottom-nav-1')));
    await tester.pumpAndSettle();

    expect(find.text('Analysis'), findsOneWidget);
    expect(find.text('Income & Expenses'), findsOneWidget);
  });

  testWidgets('opens transfer tab and filters to income', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.byKey(const ValueKey<String>('bottom-nav-2')));
    await tester.pumpAndSettle();

    expect(find.text('Transaction'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('Others'), findsWidgets);
    expect(find.text('Transport'), findsNothing);
  });

  testWidgets('opens categories tab and add expense form', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.byKey(const ValueKey<String>('bottom-nav-3')));
    await tester.pumpAndSettle();

    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('category-card-Food')));
    await tester.pumpAndSettle();

    expect(find.text('Add Expenses'), findsOneWidget);

    final addExpenseButton = find.widgetWithText(
      ElevatedButton,
      'Add Expenses',
    );
    await tester.ensureVisible(addExpenseButton);
    await tester.tap(addExpenseButton);
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Optional Notes'), findsOneWidget);
  });

  testWidgets('opens profile tab and navigates to edit profile', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.byKey(const ValueKey<String>('bottom-nav-4')));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('My Account'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('profile-tile-my-account')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('profile-edit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('profile-save-button')),
      findsOneWidget,
    );
  });
}
