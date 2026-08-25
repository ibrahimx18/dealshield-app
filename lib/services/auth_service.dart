import 'api_service.dart';
import '../models/app_models.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static UserProfile? _profile;

  static bool get isLoggedIn => _isLoggedIn;
  static UserProfile? get profile => _profile;

  static Future<void> init() async {
    await ApiService.init();
    if (ApiService.token != null) {
      try {
        _profile = await ApiService.getProfile();
        _isLoggedIn = true;
      } catch (_) {
        _isLoggedIn = false;
        await ApiService.clearToken();
      }
    }
  }

  static Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final data = await ApiService.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
    _profile = _parseProfileFromAuth(data);
    _isLoggedIn = true;
  }

  static Future<void> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final data = await ApiService.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    _profile = _parseProfileFromAuth(data);
    _isLoggedIn = true;
  }

  static Future<void> logout() async {
    await ApiService.clearToken();
    _isLoggedIn = false;
    _profile = null;
  }

  static Future<void> refreshProfile() async {
    if (_isLoggedIn) {
      _profile = await ApiService.getProfile();
    }
  }

  static UserProfile _parseProfileFromAuth(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>?;
    if (user == null) return UserProfile(
      id: '', name: '', phone: '', email: '', walletBalance: 0,
    );
    return UserProfile(
      id: user['id']?.toString() ?? '',
      name: user['name'] ?? '',
      phone: user['phone'] ?? '',
      email: user['email'] ?? '',
      walletBalance: (user['wallet_balance'] as num?)?.toDouble() ?? 0,
      ninVerified: user['nin_verified'] ?? false,
      phoneVerified: user['phone_verified'] ?? true,
      idVerified: user['id_verified'] ?? false,
      totalDeals: user['total_deals'] ?? 0,
      rating: (user['rating'] as num?)?.toDouble() ?? 5.0,
    );
  }
}
