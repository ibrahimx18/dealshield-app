import 'package:flutter/material.dart';
import '../widgets/glass_ui.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CommodityCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final prices = state.marketPrices;

    if (state.loading && state.listings.isEmpty) {
      return MeshGradientBg(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: SafePayColors.gold),
                const SizedBox(height: 16),
                Text('Loading...', style: SafePayText.body(color: SafePayColors.textSecondary)),
              ],
            ),
          ),
        ),
      );
    }

    if (state.error != null && state.listings.isEmpty) {
      return MeshGradientBg(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NeumorphicIcon(icon: Iconsax.wifi, size: 28, containerSize: 60),
                const SizedBox(height: 20),
                Text('Cannot connect to server', style: SafePayText.heading3()),
                const SizedBox(height: 8),
                Text(state.error!, style: SafePayText.bodySmall()),
                const SizedBox(height: 24),
                GoldButton3D(
                  label: 'Retry',
                  icon: Iconsax.refresh,
                  onPressed: () => state.initData(),
                  width: 200,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredListings = _selectedCategory != null
        ? state.listings.where((l) => l.category == _selectedCategory).toList()
        : state.listings;

    return MeshGradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            color: SafePayColors.gold,
            onRefresh: () => state.initData(),
            child: CustomScrollView(
              slivers: [
                // Premium header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Brand name in Playfair Display
                            Text('SafePay', style: SafePayText.brand(size: 26)),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: NeumorphicIcon(
                                    icon: Iconsax.notification,
                                    size: 20,
                                    containerSize: 42,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, '/wallet'),
                                  child: GlassContainer(
                                    blur: 10,
                                    opacity: 0.08,
                                    borderRadius: 20,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    showShadow: false,
                                    tint: SafePayColors.green,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Iconsax.wallet, size: 16, color: SafePayColors.green),
                                        const SizedBox(width: 4),
                                        Text(
                                          '₦${_formatPrice(state.walletBalance)}',
                                          style: SafePayText.money(color: SafePayColors.green, size: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Wallet balance card — gold accent
                        GoldAccentCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Iconsax.emoji_happy, color: SafePayColors.gold, size: 24),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Welcome back, ${state.profile?.name.split(' ').first ?? 'Trader'}',
                                      style: SafePayText.heading3(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Wallet Balance',
                                style: SafePayText.label(color: SafePayColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₦${_formatPrice(state.walletBalance)}',
                                style: SafePayText.money(size: 32),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Trade cars, gold, dollars, oil & land safely with escrow protection.',
                                style: SafePayText.bodySmall(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Categories header
                        SectionHeader(
                          title: 'Categories',
                          action: _selectedCategory != null ? 'Clear' : null,
                          onAction: _selectedCategory != null
                              ? () => setState(() => _selectedCategory = null)
                              : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                // Category grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: CommodityCategory.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return _buildCategoryCard(cat, prices, isSelected);
                      }).toList(),
                    ),
                  ),
                ),
                // Featured listings header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                    child: SectionHeader(
                      title: _selectedCategory != null
                          ? '${_selectedCategory!.icon} ${_selectedCategory!.label} Listings'
                          : 'Featured Listings',
                      action: _selectedCategory == null ? 'See All' : null,
                    ),
                  ),
                ),
                // Listings
                if (filteredListings.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          _selectedCategory != null
                              ? 'No ${_selectedCategory!.label} listings yet. Be the first!'
                              : 'No listings yet. Be the first!',
                          style: SafePayText.body(color: SafePayColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= 4 && _selectedCategory == null) return null;
                        if (index >= filteredListings.length) return null;
                        return _buildListingCard(filteredListings[index]);
                      },
                      childCount: filteredListings.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(CommodityCategory cat, List<MarketPrice> prices, bool isSelected) {
    final catPrices = prices.where((p) {
      if (cat == CommodityCategory.cars) return p.item.contains('Toyota') || p.item.contains('Honda') || p.item.contains('Lexus') || p.item.contains('Mercedes');
      if (cat == CommodityCategory.gold) return p.item.contains('Gold');
      if (cat == CommodityCategory.dollars) return p.item.contains('USD') || p.item.contains('EUR') || p.item.contains('GBP');
      if (cat == CommodityCategory.oil) return p.item.contains('AGO') || p.item.contains('PMS') || p.item.contains('BLCO');
      if (cat == CommodityCategory.land) return p.item.contains('Land');
      return false;
    }).toList();

    String priceText = catPrices.isNotEmpty
      ? 'From ₦${_formatPrice(catPrices.last.priceNgn)}'
      : '';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : cat;
        });
      },
      child: GlassContainer(
        blur: 10,
        opacity: isSelected ? 0.12 : 0.05,
        borderRadius: 16,
        showShadow: false,
        tint: isSelected ? SafePayColors.gold : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(cat.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              cat.label,
              style: SafePayText.label(
                color: isSelected ? SafePayColors.gold : SafePayColors.textPrimary,
                weight: FontWeight.w600,
              ),
            ),
            if (priceText.isNotEmpty)
              Text(
                priceText,
                style: SafePayText.money(color: SafePayColors.gold, size: 10),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/listing', arguments: listing),
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Category icon
              NeumorphicIcon(
                icon: _getCategoryIcon(listing.category),
                size: 24,
                containerSize: 56,
                color: SafePayColors.gold,
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: SafePayText.heading4(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (listing.verified)
                          const VerifiedBadge(label: 'Verified', verified: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('📍 ${listing.location}', style: SafePayText.bodySmall()),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PriceTag3D(price: '₦${_formatPrice(listing.price)}'),
                        Row(
                          children: [
                            const Icon(Iconsax.star_1, color: SafePayColors.gold, size: 14),
                            Text(listing.sellerRating, style: SafePayText.caption(color: SafePayColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(CommodityCategory cat) {
    switch (cat) {
      case CommodityCategory.cars:
        return Iconsax.car;
      case CommodityCategory.gold:
        return Iconsax.coin;
      case CommodityCategory.dollars:
        return Iconsax.dollar_circle;
      case CommodityCategory.oil:
        return Iconsax.gas_station;
      case CommodityCategory.land:
        return Iconsax.map;
    }
  }

  static String _formatPrice(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)}M';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toStringAsFixed(0);
  }
}
