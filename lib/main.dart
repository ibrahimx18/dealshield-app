import 'widgets/glass_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/market_screen.dart';
import 'screens/create_listing_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/listing_detail_screen.dart';
import 'screens/escrow_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/payment_links_screen.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Security: block screenshots and screen recording on Android
  try {
    await PlatformChannel._setSecureFlag();
  } catch (_) {}

  await ApiService.init();
  if (ApiService.token != null) {
    try {
      await AuthService.init();
    } catch (_) {}
  }
  runApp(const SafePayApp());
}

class SafePayApp extends StatelessWidget {
  const SafePayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'SafePay',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const SplashScreen(),
        routes: {
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const MainNav(),
          '/listing': (context) => const ListingDetailScreen(),
          '/escrow': (context) => const EscrowScreen(),
          '/wallet': (context) => const WalletScreen(),
          '/payment-links': (context) => const PaymentLinksScreen(),
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: SafePayColors.gold,
      scaffoldBackgroundColor: SafePayColors.bg,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(
          color: SafePayColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: SafePayColors.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: SafePayColors.bgMid,
        selectedItemColor: SafePayColors.gold,
        unselectedItemColor: SafePayColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400),
      ),
      cardTheme: CardThemeData(
        color: SafePayColors.bgLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.inter(color: SafePayColors.textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: SafePayColors.textSecondary, fontSize: 14),
        bodySmall: GoogleFonts.inter(color: SafePayColors.textMuted, fontSize: 12),
        titleLarge: GoogleFonts.sora(color: SafePayColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 22),
        titleMedium: GoogleFonts.sora(color: SafePayColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleSmall: GoogleFonts.sora(color: SafePayColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SafePayColors.bgLighter,
        contentTextStyle: GoogleFonts.inter(color: SafePayColors.textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: SafePayColors.glassBorder,
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MarketScreen(),
    const CreateListingScreen(),
    const TransactionsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafePayColors.bg,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: SafePayColors.glassBorder, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Iconsax.home_2), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Iconsax.trend_up), label: 'Market'),
            BottomNavigationBarItem(icon: Icon(Iconsax.add_circle, size: 32), label: 'New Deal'),
            BottomNavigationBarItem(icon: Icon(Iconsax.receipt_item), label: 'Deals'),
            BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profile'),
          ],
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

/// Platform channel for Android-specific security settings.
class PlatformChannel {
  static const _channel = MethodChannel('com.safepay.app/security');

  static Future<void> _setSecureFlag() async {
    await _channel.invokeMethod('setSecureFlag');
  }
}
