import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_models.dart';

class ApiService {
  // Server URL — uses the dev server IP
  // In production, this should be https://api.safepay.ng
  static const String baseUrl = 'http://15.204.248.160:8000';

  static String? _token;
  static String? get token => _token;

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> init() async {
    try {
      _token = await _secureStorage.read(key: 'auth_token');
    } catch (_) {
      _token = null;
    }
  }

  static Future<void> _saveToken(String token) async {
    _token = token;
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
    } catch (_) {
      // Fallback — shouldn't happen on modern devices
    }
  }

  static Future<void> clearToken() async {
    _token = null;
    try {
      await _secureStorage.delete(key: 'auth_token');
    } catch (_) {}
  }

  static Map<String, String> get _headers {
    final h = {'Content-Type': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    Uri uri = Uri.parse('$baseUrl$path');
    if (queryParams != null) uri = uri.replace(queryParameters: queryParams);

    late http.Response res;
    try {
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: _headers);
          break;
        case 'POST':
          res = await http.post(uri, headers: _headers, body: jsonEncode(body));
          break;
        case 'PUT':
          res = await http.put(uri, headers: _headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: _headers);
          break;
        default:
          throw Exception('Unknown method: $method');
      }
    } catch (e) {
      throw Exception('Cannot connect to server. Check your connection.');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode >= 400) {
      throw Exception(data['detail']?.toString() ?? 'Request failed (${res.statusCode})');
    }

    return data;
  }

  // === AUTH ===

  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final data = await _request('POST', '/auth/register', body: {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
    });
    await _saveToken(data['access_token']);
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final data = await _request('POST', '/auth/login', body: {
      'email_or_phone': emailOrPhone,
      'password': password,
    });
    await _saveToken(data['access_token']);
    return data;
  }

  static Future<UserProfile> getProfile() async {
    final data = await _request('GET', '/auth/me');
    return _parseProfile(data);
  }

  // === LISTINGS ===

  static Future<List<Listing>> getListings({CommodityCategory? category, String? search}) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category.name;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final data = await _request('GET', '/listings', queryParams: params.isNotEmpty ? params : null);
    final list = data['listings'] as List;
    return list.map((e) => _parseListing(e)).toList();
  }

  static Future<Listing> getListing(String id) async {
    final data = await _request('GET', '/listings/$id');
    return _parseListing(data);
  }

  static Future<Listing> createListing({
    required CommodityCategory category,
    required String title,
    required String description,
    required double price,
    required String location,
    bool insured = false,
  }) async {
    final data = await _request('POST', '/listings', body: {
      'category': category.name,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'insured': insured,
    });
    return _parseListing(data);
  }

  // === ESCROW ===

  static Future<EscrowTransaction> createEscrow(String listingId, {bool insured = false}) async {
    final data = await _request('POST', '/escrow/create', body: {
      'listing_id': listingId,
      'insured': insured,
    });
    return _parseTransaction(data);
  }

  static Future<List<EscrowTransaction>> getTransactions() async {
    final data = await _request('GET', '/escrow/transactions');
    final list = data['transactions'] as List;
    return list.map((e) => _parseTransaction(e)).toList();
  }

  static Future<EscrowTransaction> getTransaction(String id) async {
    final data = await _request('GET', '/escrow/$id');
    return _parseTransaction(data);
  }

  static Future<EscrowTransaction> markShipped(String id, {String logisticsProvider = '', String trackingNumber = ''}) async {
    final data = await _request('POST', '/escrow/$id/mark-shipped', body: {
      'logistics_provider': logisticsProvider,
      'tracking_number': trackingNumber,
    });
    return _parseTransaction(data);
  }

  static Future<EscrowTransaction> confirmReceipt(String id) async {
    final data = await _request('POST', '/escrow/$id/confirm-receipt');
    return _parseTransaction(data);
  }

  static Future<EscrowTransaction> dispute(String id) async {
    final data = await _request('POST', '/escrow/$id/dispute');
    return _parseTransaction(data);
  }

  static Future<EscrowTransaction> cancelEscrow(String id) async {
    final data = await _request('POST', '/escrow/$id/cancel');
    return _parseTransaction(data);
  }

  // === WALLET ===

  static Future<double> getWalletBalance() async {
    final data = await _request('GET', '/wallet/balance');
    return (data['balance'] as num).toDouble();
  }

  static Future<double> depositWallet(double amount) async {
    final data = await _request('POST', '/wallet/deposit', body: {'amount': amount});
    return (data['balance'] as num).toDouble();
  }

  static Future<double> withdrawWallet(double amount) async {
    final data = await _request('POST', '/wallet/withdraw', body: {'amount': amount});
    return (data['balance'] as num).toDouble();
  }

  static Future<List<Map<String, dynamic>>> getWalletTransactions() async {
    final data = await _request('GET', '/wallet/transactions');
    return (data['transactions'] as List).cast<Map<String, dynamic>>();
  }

  // === MARKET ===

  static Future<List<MarketPrice>> getMarketPrices({CommodityCategory? category}) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category.name;
    final data = await _request('GET', '/market/prices', queryParams: params.isNotEmpty ? params : null);
    final list = data['prices'] as List;
    return list.map((e) => _parseMarketPrice(e)).toList();
  }

  // === BVN & BUSINESS VERIFICATION ===

  static Future<Map<String, dynamic>> verifyBVN(String bvn) async {
    return await _request('POST', '/auth/verify-bvn', body: {'bvn': bvn});
  }

  static Future<Map<String, dynamic>> verifyBusiness(String businessName, String rcNumber) async {
    return await _request('POST', '/auth/verify-business', body: {
      'business_name': businessName,
      'rc_number': rcNumber,
    });
  }

  // === REVIEWS ===

  static Future<Review> createReview({required String escrowId, required int rating, String comment = ''}) async {
    final data = await _request('POST', '/reviews', body: {
      'escrow_id': int.parse(escrowId),
      'rating': rating,
      'comment': comment,
    });
    return _parseReview(data);
  }

  static Future<List<Review>> getReviewsForUser(String userId) async {
    final data = await _request('GET', '/reviews/user/$userId');
    final list = data['reviews'] as List;
    return list.map((e) => _parseReview(e as Map<String, dynamic>)).toList();
  }

  static Future<List<Review>> getReviewsForTransaction(String txId) async {
    final data = await _request('GET', '/reviews/transaction/$txId');
    final list = data['reviews'] as List;
    return list.map((e) => _parseReview(e as Map<String, dynamic>)).toList();
  }

  // === PAYMENT LINKS ===

  static Future<PaymentLink> createPaymentLink({
    required String title,
    required double amount,
    required String category,
    String description = '',
  }) async {
    final data = await _request('POST', '/pay-links', body: {
      'title': title,
      'amount': amount,
      'category': category,
      'description': description,
    });
    return _parsePaymentLink(data);
  }

  static Future<List<PaymentLink>> getPaymentLinks() async {
    final data = await _request('GET', '/pay-links');
    final list = data['links'] as List;
    return list.map((e) => _parsePaymentLink(e as Map<String, dynamic>)).toList();
  }

  static Future<Map<String, dynamic>> getPaymentLinkByCode(String code) async {
    return await _request('GET', '/pay-links/$code');
  }

  static Future<void> deletePaymentLink(String id) async {
    await _request('DELETE', '/pay-links/$id');
  }

  // === PAYMENTS (Paystack / Flutterwave) ===

  static Future<Map<String, dynamic>> initializePayment({
    required double amount,
    required String provider, // 'paystack' | 'flutterwave'
  }) async {
    return await _request('POST', '/payments/initialize', body: {
      'amount': amount,
      'provider': provider,
    });
  }

  static Future<Map<String, dynamic>> verifyPayment(String reference) async {
    return await _request('POST', '/payments/verify', body: {'reference': reference});
  }

  static Future<List<String>> getPaymentProviders() async {
    final data = await _request('GET', '/payments/providers');
    return (data['providers'] as List).cast<String>();
  }

  // === AI FRAUD CHECK ===

  static Future<FraudCheckResult> fraudCheck({
    required String title,
    required String description,
    required double price,
    required String category,
    required String sellerName,
    required int sellerDeals,
    required double sellerRating,
  }) async {
    final data = await _request('POST', '/ai/fraud-check', body: {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'seller_name': sellerName,
      'seller_deals': sellerDeals,
      'seller_rating': sellerRating,
    });
    return FraudCheckResult(
      riskScore: data['risk_score'] ?? 0,
      riskLevel: data['risk_level'] ?? 'LOW',
      redFlags: (data['red_flags'] as List?)?.cast<String>() ?? [],
      recommendation: data['recommendation'] ?? '',
    );
  }

  // === PARSERS ===

  static UserProfile _parseProfile(Map<String, dynamic> d) {
    return UserProfile(
      id: d['id']?.toString() ?? '',
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      email: d['email'] ?? '',
      walletBalance: (d['wallet_balance'] as num?)?.toDouble() ?? 0,
      ninVerified: d['nin_verified'] ?? false,
      phoneVerified: d['phone_verified'] ?? true,
      idVerified: d['id_verified'] ?? false,
      bvnVerified: d['bvn_verified'] ?? false,
      businessVerified: d['business_verified'] ?? false,
      businessName: d['business_name'],
      badge: d['badge'] ?? 'new',
      totalDeals: d['total_deals'] ?? 0,
      rating: (d['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: d['review_count'] ?? 0,
    );
  }

  static Listing _parseListing(Map<String, dynamic> d) {
    return Listing(
      id: d['id']?.toString() ?? '',
      category: _parseCategory(d['category']),
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      price: (d['price'] as num?)?.toDouble() ?? 0,
      location: d['location'] ?? '',
      sellerName: d['seller_name'] ?? '',
      sellerRating: d['seller_rating']?.toString() ?? '5.0',
      verified: d['verified'] ?? false,
      imagePath: d['image_path'],
      postedDate: d['posted_date'] != null
          ? DateTime.tryParse(d['posted_date']) ?? DateTime.now()
          : DateTime.now(),
      insured: d['insured'] ?? false,
    );
  }

  static EscrowTransaction _parseTransaction(Map<String, dynamic> d) {
    return EscrowTransaction(
      id: d['id']?.toString() ?? '',
      listingId: d['listing_id']?.toString() ?? '',
      listingTitle: d['listing_title'] ?? '',
      category: _parseCategory(d['category']),
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      commission: (d['commission'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(d['status']),
      buyerId: d['buyer_id']?.toString() ?? '',
      sellerId: d['seller_id']?.toString() ?? '',
      buyerName: d['buyer_name'],
      sellerName: d['seller_name'],
      createdAt: d['created_at'] != null
          ? DateTime.tryParse(d['created_at']) ?? DateTime.now()
          : DateTime.now(),
      completedAt: d['completed_at'] != null
          ? DateTime.tryParse(d['completed_at'])
          : null,
      insured: d['insured'] ?? false,
      logisticsProvider: d['logistics_provider'] ?? '',
      trackingNumber: d['tracking_number'] ?? '',
      insuranceFee: (d['insurance_fee'] as num?)?.toDouble() ?? 0,
    );
  }

  static MarketPrice _parseMarketPrice(Map<String, dynamic> d) {
    return MarketPrice(
      item: d['item'] ?? '',
      priceUsd: (d['price_usd'] as num?)?.toDouble() ?? 0,
      priceNgn: (d['price_ngn'] as num?)?.toDouble() ?? 0,
      unit: d['unit'] ?? '',
      change: (d['change'] as num?)?.toDouble() ?? 0,
      trending: d['trending'] ?? false,
      category: d['category'] ?? '',
    );
  }

  static CommodityCategory _parseCategory(String? s) {
    switch (s) {
      case 'cars': return CommodityCategory.cars;
      case 'gold': return CommodityCategory.gold;
      case 'dollars': return CommodityCategory.dollars;
      case 'currency': return CommodityCategory.dollars;
      case 'oil': return CommodityCategory.oil;
      case 'land': return CommodityCategory.land;
      case 'cement': return CommodityCategory.cement;
      default: return CommodityCategory.cars;
    }
  }

  static EscrowStatus _parseStatus(String? s) {
    switch (s) {
      case 'pending': return EscrowStatus.pending;
      case 'funds_deposited': return EscrowStatus.fundsDeposited;
      case 'shipped': return EscrowStatus.shipped;
      case 'delivered': return EscrowStatus.delivered;
      case 'disputed': return EscrowStatus.disputed;
      case 'cancelled': return EscrowStatus.cancelled;
      default: return EscrowStatus.pending;
    }
  }

  static Review _parseReview(Map<String, dynamic> d) {
    return Review(
      id: d['id']?.toString() ?? '',
      escrowId: d['escrow_id']?.toString() ?? '',
      reviewerName: d['reviewer_name'] ?? '',
      reviewerRole: d['reviewer_role'] ?? 'buyer',
      rating: d['rating'] ?? 5,
      comment: d['comment'] ?? '',
      createdAt: d['created_at'] != null
          ? DateTime.tryParse(d['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static PaymentLink _parsePaymentLink(Map<String, dynamic> d) {
    return PaymentLink(
      id: d['id']?.toString() ?? '',
      code: d['code'] ?? '',
      title: d['title'] ?? '',
      amount: (d['amount'] as num?)?.toDouble() ?? 0,
      category: d['category'] ?? '',
      description: d['description'] ?? '',
      active: d['active'] ?? true,
      createdAt: d['created_at'] != null
          ? DateTime.tryParse(d['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
