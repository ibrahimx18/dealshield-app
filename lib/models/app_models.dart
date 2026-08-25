// Models for SafePay

enum CommodityCategory { cars, gold, dollars, oil, land }

extension CommodityCategoryExt on CommodityCategory {
  String get label {
    switch (this) {
      case CommodityCategory.cars: return 'Cars';
      case CommodityCategory.gold: return 'Gold';
      case CommodityCategory.dollars: return 'Dollars';
      case CommodityCategory.oil: return 'Oil (AGO)';
      case CommodityCategory.land: return 'Land';
    }
  }

  String get icon {
    switch (this) {
      case CommodityCategory.cars: return '🚗';
      case CommodityCategory.gold: return '🥇';
      case CommodityCategory.dollars: return '💵';
      case CommodityCategory.oil: return '🛢️';
      case CommodityCategory.land: return '🏞️';
    }
  }

  String get color {
    switch (this) {
      case CommodityCategory.cars: return '#4A90D9';
      case CommodityCategory.gold: return '#FFD700';
      case CommodityCategory.dollars: return '#00C896';
      case CommodityCategory.oil: return '#E67E22';
      case CommodityCategory.land: return '#2ECC71';
    }
  }
}

class MarketPrice {
  final String item;
  final double priceUsd;
  final double priceNgn;
  final String unit;
  final double change; // % change
  final bool trending;
  final String category;

  MarketPrice({required this.item, required this.priceUsd, required this.priceNgn, required this.unit, required this.change, required this.trending, this.category = ''});
}

class Listing {
  final String id;
  final CommodityCategory category;
  final String title;
  final String description;
  final double price;
  final String location;
  final String sellerName;
  final String sellerRating;
  final bool verified;
  final String? imagePath;
  final DateTime postedDate;
  final bool insured;
  // Proof of Product fields
  final bool proofVerified;
  final String? proofDocType;      // e.g. 'NNPC Allocation', 'Refinery Certificate', 'Assay Report'
  final String? proofDocNumber;    // Document reference number
  final String? proofDocUrl;       // Uploaded document path/URL
  final String? verificationNote;  // Admin/verifier note

  Listing({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.sellerName,
    required this.sellerRating,
    this.verified = false,
    this.imagePath,
    required this.postedDate,
    this.insured = false,
    this.proofVerified = false,
    this.proofDocType,
    this.proofDocNumber,
    this.proofDocUrl,
    this.verificationNote,
  });
}

enum EscrowStatus {
  pending, // buyer hasn't deposited yet
  fundsDeposited, // buyer deposited, waiting for seller to ship
  shipped, // seller shipped, waiting for buyer confirmation
  delivered, // buyer confirmed receipt, funds released
  disputed, // dispute opened
  cancelled,
}

extension EscrowStatusExt on EscrowStatus {
  String get label {
    switch (this) {
      case EscrowStatus.pending: return 'Awaiting Deposit';
      case EscrowStatus.fundsDeposited: return 'Funds Deposited';
      case EscrowStatus.shipped: return 'Shipped';
      case EscrowStatus.delivered: return 'Completed';
      case EscrowStatus.disputed: return 'Disputed';
      case EscrowStatus.cancelled: return 'Cancelled';
    }
  }

  String get icon {
    switch (this) {
      case EscrowStatus.pending: return '⏳';
      case EscrowStatus.fundsDeposited: return '💰';
      case EscrowStatus.shipped: return '🚚';
      case EscrowStatus.delivered: return '✅';
      case EscrowStatus.disputed: return '⚠️';
      case EscrowStatus.cancelled: return '❌';
    }
  }
}

class EscrowTransaction {
  final String id;
  final String listingId;
  final String listingTitle;
  final CommodityCategory category;
  final double amount;
  final double commission;
  final EscrowStatus status;
  final String buyerId;
  final String sellerId;
  final String? buyerName;
  final String? sellerName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool insured;
  final String logisticsProvider;
  final String trackingNumber;
  final double insuranceFee;

  EscrowTransaction({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.category,
    required this.amount,
    required this.commission,
    required this.status,
    required this.buyerId,
    required this.sellerId,
    this.buyerName,
    this.sellerName,
    required this.createdAt,
    this.completedAt,
    this.insured = false,
    this.logisticsProvider = '',
    this.trackingNumber = '',
    this.insuranceFee = 0,
  });
}

class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final double walletBalance;
  final bool ninVerified;
  final bool phoneVerified;
  final bool idVerified;
  final bool bvnVerified;
  final bool businessVerified;
  final String? businessName;
  final String badge; // 'new' | 'verified' | 'trusted' | 'top_dealer'
  final int totalDeals;
  final double rating;
  final int reviewCount;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.walletBalance,
    this.ninVerified = false,
    this.phoneVerified = true,
    this.idVerified = false,
    this.bvnVerified = false,
    this.businessVerified = false,
    this.businessName,
    this.badge = 'new',
    this.totalDeals = 0,
    this.rating = 5.0,
    this.reviewCount = 0,
  });
}

// ─── Review ────────────────────────────────────
class Review {
  final String id;
  final String escrowId;
  final String reviewerName;
  final String reviewerRole; // 'buyer' | 'seller'
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.escrowId,
    required this.reviewerName,
    required this.reviewerRole,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

// ─── Payment Link ──────────────────────────────
class PaymentLink {
  final String id;
  final String code;
  final String title;
  final double amount;
  final String category;
  final String description;
  final bool active;
  final DateTime createdAt;

  PaymentLink({
    required this.id,
    required this.code,
    required this.title,
    required this.amount,
    required this.category,
    required this.description,
    required this.active,
    required this.createdAt,
  });
}

// ─── Fraud Check Result ────────────────────────
class FraudCheckResult {
  final int riskScore;
  final String riskLevel; // 'LOW' | 'MEDIUM' | 'HIGH'
  final List<String> redFlags;
  final String recommendation;

  FraudCheckResult({
    required this.riskScore,
    required this.riskLevel,
    required this.redFlags,
    required this.recommendation,
  });
}
