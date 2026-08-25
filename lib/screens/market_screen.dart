import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../widgets/glass_ui.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  bool _showUsd = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final prices = state.marketPrices;

    if (state.loading && prices.isEmpty) {
      return MeshGradientBg(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: SafePayColors.gold),
                const SizedBox(height: 16),
                Text('Loading market...', style: SafePayText.body(color: SafePayColors.textSecondary)),
              ],
            ),
          ),
        ),
      );
    }

    return MeshGradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            color: SafePayColors.gold,
            onRefresh: () => state.loadMarketPrices(),
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Market', style: SafePayText.brand(size: 26)),
                            GlassToggle(
                              value: !_showUsd,
                              leftLabel: 'NGN',
                              rightLabel: 'USD',
                              onChanged: (v) => setState(() => _showUsd = !v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Live rates banner
                        GlassContainer(
                          width: double.infinity,
                          blur: 10,
                          opacity: 0.06,
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          showShadow: false,
                          tint: SafePayColors.gold,
                          child: Row(
                            children: [
                              const Icon(Iconsax.refresh, color: SafePayColors.gold, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Live rates • ${_getTimeStr()}',
                                style: SafePayText.bodySmall(),
                              ),
                              const Spacer(),
                              Text(
                                '1 USD = ₦${_formatNgn(prices.isNotEmpty ? prices.firstWhere((p) => p.item.contains('Dollar'), orElse: () => prices.first).priceNgn : 1350)}',
                                style: SafePayText.money(size: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // Price cards
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = prices[index];
                      final isUp = p.change > 0;
                      final price = _showUsd ? p.priceUsd : p.priceNgn;
                      final symbol = _showUsd ? '\$' : '₦';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(p.item, style: SafePayText.heading4()),
                                  ),
                                  StatusBadge3D(
                                    icon: isUp ? '▲' : '▼',
                                    label: '${isUp ? '+' : ''}${p.change.toStringAsFixed(1)}%',
                                    color: isUp ? SafePayColors.green : SafePayColors.red,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$symbol${_formatPrice(price)}',
                                style: SafePayText.money(size: 22),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _showUsd
                                    ? '≈ ₦${_formatNgn(p.priceNgn)}'
                                    : '≈ \$${_formatUsd(p.priceUsd)}',
                                style: SafePayText.caption(),
                              ),
                              const SizedBox(height: 4),
                              Text('per ${p.unit}', style: SafePayText.caption()),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: prices.length,
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

  String _formatPrice(double price) {
    if (_showUsd) return _formatUsd(price);
    return _formatNgn(price);
  }

  static String _formatNgn(double price) {
    if (price >= 1000000000) return '${(price / 1000000000).toStringAsFixed(2)}B';
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(2)}M';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(1)}K';
    return price.toStringAsFixed(0);
  }

  static String _formatUsd(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(2)}M';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(2)}K';
    return price.toStringAsFixed(2);
  }

  String _getTimeStr() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }
}
