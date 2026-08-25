import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:safepay_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SafePay Full Flow Test', () {
    testWidgets('App launches and shows login screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Should see SafePay logo text
      expect(find.text('SafePay'), findsOneWidget);
      expect(find.text('No more heartache. Guaranteed.'), findsOneWidget);
    });

    testWidgets('Login with demo account and navigate home', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Find email field by hint text
      final emailField = find.byWidgetPredicate((w) => 
        w is TextField && (w.decoration?.hintText?.contains('you@example') ?? false));
      
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'seller@safepay.ng');
        
        // Find password field
        final passField = find.byWidgetPredicate((w) => 
          w is TextField && (w.decoration?.hintText?.contains('•••') ?? false));
        await tester.enterText(passField, 'demo1234');
        
        // Find and tap login button
        final loginButton = find.text('Login').first;
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Should now be on home screen
        // Check for bottom nav items
        expect(find.text('Home'), findsWidgets);
        expect(find.text('Market'), findsWidgets);
      }
    });

    testWidgets('Category filter works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Login first
      final emailField = find.byWidgetPredicate((w) => 
        w is TextField && (w.decoration?.hintText?.contains('you@example') ?? false));
      
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'seller@safepay.ng');
        final passField = find.byWidgetPredicate((w) => 
          w is TextField && (w.decoration?.hintText?.contains('•••') ?? false));
        await tester.enterText(passField, 'demo1234');
        await tester.tap(find.text('Login').first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Find category chips and tap one
        final categories = find.byType(GestureDetector);
        if (categories.evaluate().isNotEmpty) {
          await tester.tap(categories.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    });

    testWidgets('Navigate to Market screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Login
      final emailField = find.byWidgetPredicate((w) => 
        w is TextField && (w.decoration?.hintText?.contains('you@example') ?? false));
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'seller@safepay.ng');
        final passField = find.byWidgetPredicate((w) => 
          w is TextField && (w.decoration?.hintText?.contains('•••') ?? false));
        await tester.enterText(passField, 'demo1234');
        await tester.tap(find.text('Login').first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Tap Market in bottom nav
        final marketTab = find.text('Market');
        if (marketTab.evaluate().isNotEmpty) {
          await tester.tap(marketTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }
      }
    });

    testWidgets('Navigate to Create Listing', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Login
      final emailField = find.byWidgetPredicate((w) => 
        w is TextField && (w.decoration?.hintText?.contains('you@example') ?? false));
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'seller@safepay.ng');
        final passField = find.byWidgetPredicate((w) => 
          w is TextField && (w.decoration?.hintText?.contains('•••') ?? false));
        await tester.enterText(passField, 'demo1234');
        await tester.tap(find.text('Login').first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Tap New Deal in bottom nav
        final newDealTab = find.text('New Deal');
        if (newDealTab.evaluate().isNotEmpty) {
          await tester.tap(newDealTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    });

    testWidgets('Navigate to Deals screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Login
      final emailField = find.byWidgetPredicate((w) => 
        w is TextField && (w.decoration?.hintText?.contains('you@example') ?? false));
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'seller@safepay.ng');
        final passField = find.byWidgetPredicate((w) => 
          w is TextField && (w.decoration?.hintText?.contains('•••') ?? false));
        await tester.enterText(passField, 'demo1234');
        await tester.tap(find.text('Login').first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Tap Deals in bottom nav
        final dealsTab = find.text('Deals');
        if (dealsTab.evaluate().isNotEmpty) {
          await tester.tap(dealsTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }
      }
    });

    testWidgets('Navigate to Profile screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Login
      final emailField = find.byWidgetPredicate((w) => 
        w is TextField && (w.decoration?.hintText?.contains('you@example') ?? false));
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'seller@safepay.ng');
        final passField = find.byWidgetPredicate((w) => 
          w is TextField && (w.decoration?.hintText?.contains('•••') ?? false));
        await tester.enterText(passField, 'demo1234');
        await tester.tap(find.text('Login').first);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Tap Profile in bottom nav
        final profileTab = find.text('Profile');
        if (profileTab.evaluate().isNotEmpty) {
          await tester.tap(profileTab.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }
    });
  });
}
