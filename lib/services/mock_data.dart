import '../models/app_models.dart';

class MockDataService {
  static List<MarketPrice> getMarketPrices() {
    return [
      // Cars
      MarketPrice(item: 'Toyota Corolla 2018', price: 8500000, unit: 'NGN', change: -2.5, trending: false),
      MarketPrice(item: 'Honda Civic 2019', price: 9200000, unit: 'NGN', change: 1.8, trending: true),
      MarketPrice(item: 'Lexus RX 350 2020', price: 28000000, unit: 'NGN', change: 3.2, trending: true),
      MarketPrice(item: 'Mercedes C300 2019', price: 22000000, unit: 'NGN', change: -1.2, trending: false),
      MarketPrice(item: 'Toyota Camry 2020', price: 12000000, unit: 'NGN', change: 0.5, trending: true),

      // Gold
      MarketPrice(item: '24K Gold (per gram)', price: 95000, unit: 'NGN', change: 5.4, trending: true),
      MarketPrice(item: '22K Gold (per gram)', price: 87000, unit: 'NGN', change: 4.8, trending: true),
      MarketPrice(item: '18K Gold (per gram)', price: 71000, unit: 'NGN', change: 3.1, trending: true),
      MarketPrice(item: 'Gold Bar (10g)', price: 950000, unit: 'NGN', change: 5.2, trending: true),

      // Dollars
      MarketPrice(item: 'USD (parallel)', price: 1680, unit: 'NGN', change: 2.1, trending: true),
      MarketPrice(item: 'USD (CBN)', price: 1601, unit: 'NGN', change: 0.3, trending: false),
      MarketPrice(item: 'EUR (parallel)', price: 1820, unit: 'NGN', change: 1.8, trending: true),
      MarketPrice(item: 'GBP (parallel)', price: 2150, unit: 'NGN', change: 2.5, trending: true),

      // Oil/AGO
      MarketPrice(item: 'AGO (per litre)', price: 1250, unit: 'NGN', change: -1.5, trending: false),
      MarketPrice(item: 'AGO (per truck)', price: 2500000, unit: 'NGN', change: 0.8, trending: true),
      MarketPrice(item: 'PMS (per litre)', price: 855, unit: 'NGN', change: -0.5, trending: false),
      MarketPrice(item: 'BLCO (per barrel)', price: 82000, unit: 'USD', change: 1.2, trending: true),

      // Land
      MarketPrice(item: 'Land in Maitama (500sqm)', price: 75000000, unit: 'NGN', change: 8.5, trending: true),
      MarketPrice(item: 'Land in Lekki (600sqm)', price: 45000000, unit: 'NGN', change: 6.2, trending: true),
      MarketPrice(item: 'Land in Kubwa (300sqm)', price: 8000000, unit: 'NGN', change: 3.0, trending: true),
      MarketPrice(item: 'Land in Anambra (1000sqm)', price: 15000000, unit: 'NGN', change: 4.1, trending: true),
    ];
  }

  static List<Listing> getListings() {
    return [
      Listing(
        id: 'L001',
        category: CommodityCategory.cars,
        title: 'Toyota Corolla 2018 — Clean Nigerian Used',
        description: 'Clean Nigerian used Toyota Corolla 2018. Full option, leather seats, sunroof, reverse camera. Lagos registered. Papers up to date. Engine and AC perfect.',
        price: 8500000,
        location: 'Lekki, Lagos',
        sellerName: 'Ibrahim Auto Sales',
        sellerRating: '4.8',
        verified: true,
        postedDate: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Listing(
        id: 'L002',
        category: CommodityCategory.gold,
        title: '24K Gold Bar — 10 grams',
        description: 'Pure 24K gold bar, 10 grams. Hallmarked and certified. Bought from Dubai. Available for inspection in Abuja. Price slightly negotiable for serious buyers.',
        price: 950000,
        location: 'Wuse 2, Abuja',
        sellerName: 'Alhaji Gold Trading',
        sellerRating: '5.0',
        verified: true,
        postedDate: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Listing(
        id: 'L003',
        category: CommodityCategory.dollars,
        title: 'USD — \$10,000 Available',
        description: 'Ten thousand US dollars available at parallel rate. Clean notes. Transaction in Lagos or Abuja. Verification at bank. No online transfer.',
        price: 16800000,
        location: 'Wuse, Abuja',
        sellerName: 'Ibrahim BDC',
        sellerRating: '4.9',
        verified: true,
        postedDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Listing(
        id: 'L004',
        category: CommodityCategory.oil,
        title: 'AGO — 30,000 Litres Available',
        description: '30,000 litres of Automotive Gas Oil (AGO) available. Quality tested. Delivery within Lagos. Can arrange transportation. NNPC compliant product.',
        price: 37500000,
        location: 'Apapa, Lagos',
        sellerName: 'Delta Oil Trading',
        sellerRating: '4.7',
        verified: true,
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Listing(
        id: 'L005',
        category: CommodityCategory.land,
        title: 'Land in Maitama — 500 sqm with C of O',
        description: 'Prime land in Maitama, Abuja. 500 square meters. Certificate of Occupancy (C of O) intact. Gated estate. Ready for immediate development. Title documents verifiable at AGIS.',
        price: 75000000,
        location: 'Maitama, Abuja',
        sellerName: 'Geralt Properties',
        sellerRating: '5.0',
        verified: true,
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Listing(
        id: 'L006',
        category: CommodityCategory.cars,
        title: 'Lexus RX 350 2020 — Full Option',
        description: 'Lexus RX 350 2020 model. Full option, panoramic roof, Mark Levinson sound system, adaptive cruise control. 35,000km mileage. Foreign used. Spotless condition.',
        price: 28000000,
        location: 'Banana Island, Lagos',
        sellerName: 'Premium Motors Lagos',
        sellerRating: '4.9',
        verified: true,
        postedDate: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Listing(
        id: 'L007',
        category: CommodityCategory.gold,
        title: '22K Gold Jewelry Set',
        description: 'Complete 22K gold jewelry set — necklace, earrings, 2 rings, bangle. Total weight 45 grams. Perfect for wedding or gift. Hallmarked. Inspection welcome.',
        price: 3915000,
        location: 'Kano',
        sellerName: 'Kano Gold Market',
        sellerRating: '4.6',
        verified: false,
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Listing(
        id: 'L008',
        category: CommodityCategory.land,
        title: 'Land in Kubwa — 300 sqm',
        description: '300 sqm land in Kubwa, Abuja. Good for residential building. Survey plan available. RofO title. Near road. Quiet neighbourhood.',
        price: 8000000,
        location: 'Kubwa, Abuja',
        sellerName: 'Sodiq Properties',
        sellerRating: '4.5',
        verified: true,
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<EscrowTransaction> getTransactions() {
    return [
      EscrowTransaction(
        id: 'T001',
        listingId: 'L002',
        listingTitle: '24K Gold Bar — 10 grams',
        category: CommodityCategory.gold,
        amount: 950000,
        commission: 23750,
        status: EscrowStatus.shipped,
        buyerId: 'U001',
        sellerId: 'U002',
        buyerName: 'You',
        sellerName: 'Alhaji Gold Trading',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        insured: true,
      ),
      EscrowTransaction(
        id: 'T002',
        listingId: 'L001',
        listingTitle: 'Toyota Corolla 2018',
        category: CommodityCategory.cars,
        amount: 8500000,
        commission: 212500,
        status: EscrowStatus.delivered,
        buyerId: 'U001',
        sellerId: 'U003',
        buyerName: 'You',
        sellerName: 'Ibrahim Auto Sales',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
        insured: false,
      ),
      EscrowTransaction(
        id: 'T003',
        listingId: 'L008',
        listingTitle: 'Land in Kubwa — 300 sqm',
        category: CommodityCategory.land,
        amount: 8000000,
        commission: 200000,
        status: EscrowStatus.pending,
        buyerId: 'U001',
        sellerId: 'U005',
        buyerName: 'You',
        sellerName: 'Sodiq Properties',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  static UserProfile getProfile() {
    return UserProfile(
      name: 'Geralt Revia',
      phone: '+234 803 XXX XXXX',
      email: 'geralt@example.com',
      walletBalance: 500000,
      ninVerified: true,
      phoneVerified: true,
      idVerified: true,
      totalDeals: 12,
      rating: 4.9,
    );
  }
}
