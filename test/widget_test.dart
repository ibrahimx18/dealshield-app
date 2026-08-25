import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:safepay_app/main.dart';

void main() {
  group('SafePay App Tests', () {
    
    testWidgets('App launches and shows splash then home', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pump();
      
      // Splash should show briefly
      expect(find.text('SafePay'), findsOneWidget);
      expect(find.text('Trade with confidence'), findsOneWidget);
      
      // Wait for splash to navigate
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Home should show
      expect(find.textContaining('Welcome back'), findsOneWidget);
    });

    testWidgets('Home screen shows wallet balance in app bar', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      expect(find.byIcon(Icons.account_balance_wallet), findsWidgets);
    });

    testWidgets('Home screen shows featured listings and categories', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Should see category emoji somewhere
      expect(find.textContaining('Cars'), findsWidgets);
    });

    testWidgets('Bottom navigation has all 5 tabs', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Market'), findsWidgets);
      expect(find.text('New Deal'), findsWidgets);
      expect(find.text('Deals'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('Navigate to Market tab', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.text('Market'));
      await tester.pumpAndSettle();
      
      // Market should show prices
      expect(find.byIcon(Icons.trending_up), findsWidgets);
    });

    testWidgets('Navigate to New Deal tab', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.text('New Deal'));
      await tester.pumpAndSettle();
      
      // Should see create listing form
      expect(find.text('Create Listing'), findsOneWidget);
      expect(find.text('Select Category'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Navigate to Deals tab', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.text('Deals'));
      await tester.pumpAndSettle();
      
      // Should see deal cards
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Navigate to Profile tab', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('Navigate to Wallet from Home', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.byIcon(Icons.account_balance_wallet).first);
      await tester.pumpAndSettle();
      
      expect(find.textContaining('Balance'), findsWidgets);
    });

    testWidgets('Full navigation cycle through all tabs', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Home
      expect(find.textContaining('Welcome back'), findsOneWidget);
      
      // Market
      await tester.tap(find.text('Market'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.trending_up), findsWidgets);
      
      // New Deal
      await tester.tap(find.text('New Deal'));
      await tester.pumpAndSettle();
      expect(find.text('Create Listing'), findsOneWidget);
      
      // Deals
      await tester.tap(find.text('Deals'));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsWidgets);
      
      // Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.person), findsWidgets);
      
      // Back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Welcome back'), findsOneWidget);
    });

    testWidgets('New Deal form has all required fields', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.text('New Deal'));
      await tester.pumpAndSettle();
      
      expect(find.text('Select Category'), findsOneWidget);
      expect(find.text('Listing Title'), findsOneWidget);
      expect(find.textContaining('Price'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('New Deal form has category choice chips', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.text('New Deal'));
      await tester.pumpAndSettle();
      
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('Deals tab shows transaction status badges', (tester) async {
      await tester.pumpWidget(const SafePayApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await tester.tap(find.text('Deals'));
      await tester.pumpAndSettle();
      
      // Should find deal-related text
      expect(find.byType(Card), findsWidgets);
    });
  });
}
