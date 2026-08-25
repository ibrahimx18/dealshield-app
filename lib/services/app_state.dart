import 'package:flutter/material.dart';
import '../models/app_models.dart';
import 'api_service.dart';
import 'auth_service.dart';

class AppState extends ChangeNotifier {
  UserProfile? _profile;
  List<Listing> _listings = [];
  List<EscrowTransaction> _transactions = [];
  List<MarketPrice> _marketPrices = [];
  double _walletBalance = 0;
  bool _loading = false;
  String? _error;

  UserProfile? get profile => _profile;
  List<Listing> get listings => _listings;
  List<EscrowTransaction> get transactions => _transactions;
  List<MarketPrice> get marketPrices => _marketPrices;
  double get walletBalance => _walletBalance;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> initData() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.wait([
        loadProfile(),
        loadListings(),
        loadTransactions(),
        loadMarketPrices(),
        loadWalletBalance(),
      ]);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    try {
      _profile = await ApiService.getProfile();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshProfile() async {
    try {
      _profile = await ApiService.getProfile();
      notifyListeners();
    } catch (e) {
      // silent fail
    }
  }

  Future<void> loadListings() async {
    try {
      _listings = await ApiService.getListings();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadTransactions() async {
    try {
      _transactions = await ApiService.getTransactions();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadMarketPrices() async {
    try {
      _marketPrices = await ApiService.getMarketPrices();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadWalletBalance() async {
    try {
      _walletBalance = await ApiService.getWalletBalance();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // === LISTINGS ===

  Future<void> addListing(Listing listing) async {
    final newListing = await ApiService.createListing(
      category: listing.category,
      title: listing.title,
      description: listing.description,
      price: listing.price,
      location: listing.location,
      insured: listing.insured,
    );
    _listings.insert(0, newListing);
    notifyListeners();
  }

  // === ESCROW ===

  Future<EscrowTransaction> createEscrow(String listingId, {bool insured = false}) async {
    final tx = await ApiService.createEscrow(listingId, insured: insured);
    _transactions.insert(0, tx);
    await loadWalletBalance();
    notifyListeners();
    return tx;
  }

  Future<void> updateTransactionStatus(String id, EscrowStatus status, {String logisticsProvider = '', String trackingNumber = ''}) async {
    try {
      EscrowTransaction updated;
      switch (status) {
        case EscrowStatus.shipped:
          updated = await ApiService.markShipped(id, logisticsProvider: logisticsProvider, trackingNumber: trackingNumber);
          break;
        case EscrowStatus.delivered:
          updated = await ApiService.confirmReceipt(id);
          break;
        case EscrowStatus.disputed:
          updated = await ApiService.dispute(id);
          break;
        case EscrowStatus.cancelled:
          updated = await ApiService.cancelEscrow(id);
          break;
        default:
          return;
      }
      final idx = _transactions.indexWhere((t) => t.id == id);
      if (idx >= 0) {
        _transactions[idx] = updated;
      }
      await loadWalletBalance();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // === WALLET ===

  Future<double> depositToWallet(double amount) async {
    _walletBalance = await ApiService.depositWallet(amount);
    notifyListeners();
    return _walletBalance;
  }

  Future<double> withdrawFromWallet(double amount) async {
    _walletBalance = await ApiService.withdrawWallet(amount);
    notifyListeners();
    return _walletBalance;
  }

  // === AUTH ===

  Future<void> logout() async {
    await AuthService.logout();
    _profile = null;
    _listings = [];
    _transactions = [];
    _marketPrices = [];
    _walletBalance = 0;
    notifyListeners();
  }
}
