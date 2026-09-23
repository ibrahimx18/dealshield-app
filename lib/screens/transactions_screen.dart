import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../widgets/glass_ui.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final txns = state.transactions;

    if (state.loading && txns.isEmpty) {
      return MeshGradientBg(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: SafePayColors.gold),
                const SizedBox(height: 16),
                Text('Loading deals...', style: SafePayText.body(color: SafePayColors.textSecondary)),
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
            onRefresh: () => state.loadTransactions(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Text('My Deals', style: SafePayText.brand(size: 26)),
                  ),
                ),
                if (txns.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No deals yet. Browse listings and make your first deal!',
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
                        final tx = txns[index];
                        final statusColor = _statusColor(tx.status);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/escrow', arguments: tx),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      NeumorphicIcon(
                                        icon: _getCategoryIcon(tx.category),
                                        size: 22,
                                        containerSize: 48,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.listingTitle,
                                              style: SafePayText.heading4(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '₦${_formatPrice(tx.amount)} • Commission ₦${_formatPrice(tx.commission)}',
                                              style: SafePayText.money(size: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      StatusBadge3D(
                                        icon: tx.status.icon,
                                        label: tx.status.label,
                                        color: statusColor,
                                      ),
                                      if (tx.insured)
                                        const VerifiedBadge(label: 'Insured', verified: true),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}',
                                    style: SafePayText.caption(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: txns.length,
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

  IconData _getCategoryIcon(CommodityCategory cat) {
    switch (cat) {
      case CommodityCategory.cars: return Iconsax.car;
      case CommodityCategory.gold: return Iconsax.coin;
      case CommodityCategory.dollars: return Iconsax.dollar_circle;
      case CommodityCategory.oil: return Iconsax.gas_station;
      case CommodityCategory.land: return Iconsax.map;
      case CommodityCategory.cement: return Iconsax.box;
      case CommodityCategory.crypto: return Iconsax.bitcoin;
      case CommodityCategory.giftcards: return Iconsax.card;
    }
  }

  Color _statusColor(EscrowStatus s) {
    switch (s) {
      case EscrowStatus.pending: return SafePayColors.gold;
      case EscrowStatus.fundsDeposited: return SafePayColors.blue;
      case EscrowStatus.shipped: return SafePayColors.blue;
      case EscrowStatus.delivered: return SafePayColors.green;
      case EscrowStatus.disputed: return SafePayColors.red;
      case EscrowStatus.cancelled: return SafePayColors.textMuted;
    }
  }

  static String _formatPrice(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)}M';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toStringAsFixed(0);
  }
}
