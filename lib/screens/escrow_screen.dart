import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../widgets/glass_ui.dart';
import '../widgets/review_dialog.dart';

class EscrowScreen extends StatelessWidget {
  const EscrowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = ModalRoute.of(context)!.settings.arguments as EscrowTransaction;
    final state = Provider.of<AppState>(context);
    final currentUserId = state.profile?.id ?? '';
    final isSeller = tx.sellerId == currentUserId;
    final isBuyer = tx.buyerId == currentUserId;

    final steps = [
      {'icon': '⏳', 'title': 'Awaiting Deposit', 'desc': 'Buyer deposits funds to escrow', 'status': EscrowStatus.pending},
      {'icon': '💰', 'title': 'Funds Deposited', 'desc': 'Funds secured in escrow wallet', 'status': EscrowStatus.fundsDeposited},
      {'icon': '🚚', 'title': 'Goods Shipped', 'desc': 'Seller ships goods to buyer', 'status': EscrowStatus.shipped},
      {'icon': '✅', 'title': 'Confirmed & Released', 'desc': 'Buyer confirms receipt, funds released', 'status': EscrowStatus.delivered},
    ];

    int currentStepIndex = steps.indexWhere((s) => s['status'] == tx.status);
    if (tx.status == EscrowStatus.disputed) currentStepIndex = -1;
    if (tx.status == EscrowStatus.cancelled) currentStepIndex = -2;

    return Scaffold(
      appBar: AppBar(title: const Text('Escrow Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction header — glassmorphic with gold gradient
            GlassContainer(
              width: double.infinity,
              blur: 20,
              opacity: 0.12,
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              gradient: const LinearGradient(colors: [Color(0xFF111634), Color(0xFF1A2050)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(tx.category.icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(tx.listingTitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _row('Transaction ID', tx.id),
                  _row('Amount', '₦${_formatPrice(tx.amount)}'),
                  _row('Escrow Fee (2.5%)', '₦${_formatPrice(tx.commission)}'),
                  if (tx.insured) ...[
                    _row('Insurance Fee (1.5%)', '₦${_formatPrice(tx.insuranceFee)}'),
                    _row('Total (insured)', '₦${_formatPrice(tx.amount + tx.commission + tx.insuranceFee)}', bold: true),
                  ] else ...[
                    _row('Total', '₦${_formatPrice(tx.amount + tx.commission)}', bold: true),
                  ],
                  _row('Insured', tx.insured ? 'Yes ✓' : 'No'),
                  _row('Date', '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logistics info (if shipped or delivered) — glass with blue tint
            if ((tx.status == EscrowStatus.shipped || tx.status == EscrowStatus.delivered) && tx.logisticsProvider.isNotEmpty) ...[
              GlassContainer(
                width: double.infinity,
                blur: 15,
                opacity: 0.08,
                borderRadius: 16,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                tint: const Color(0xFF4A90D9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const NeumorphicIcon(icon: Iconsax.truck, color: Color(0xFF4A90D9), size: 20, containerSize: 36),
                        const SizedBox(width: 8),
                        const Text('Logistics Info', style: TextStyle(color: Color(0xFF4A90D9), fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _row('Provider', tx.logisticsProvider),
                    _row('Tracking #', tx.trackingNumber),
                  ],
                ),
              ),
            ],

            // Progress steps
            const Text('Transaction Progress', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final isComplete = i < currentStepIndex;
              final isCurrent = i == currentStepIndex;
              final status = step['status'] as EscrowStatus;

              return _buildStep(
                icon: step['icon'] as String,
                title: step['title'] as String,
                desc: step['desc'] as String,
                isComplete: isComplete,
                isCurrent: isCurrent,
                isLast: i == steps.length - 1,
              );
            }),

            // Dispute — glass with red tint
            if (tx.status == EscrowStatus.disputed)
              GlassContainer(
                width: double.infinity,
                blur: 15,
                opacity: 0.08,
                borderRadius: 16,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                tint: const Color(0xFFFF4757),
                child: const Column(
                  children: [
                    Icon(Iconsax.danger, color: Color(0xFFFF4757), size: 40),
                    SizedBox(height: 8),
                    Text('Dispute Opened', style: TextStyle(color: Color(0xFFFF4757), fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Our team is reviewing the case. You will be contacted within 48 hours.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),

            // Cancelled — glass with neutral tint
            if (tx.status == EscrowStatus.cancelled)
              GlassContainer(
                width: double.infinity,
                blur: 10,
                opacity: 0.05,
                borderRadius: 16,
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  children: [
                    Icon(Iconsax.close_circle, color: Colors.white54, size: 40),
                    SizedBox(height: 8),
                    Text('Transaction Cancelled', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Action buttons
            if (isSeller && tx.status == EscrowStatus.fundsDeposited)
              GoldButton3D(
                label: 'Mark as Shipped',
                color: const Color(0xFF4A90D9),
                onPressed: () => _showShipDialog(context, state, tx),
              ),

            if (isBuyer && tx.status == EscrowStatus.shipped)
              GoldButton3D(
                label: 'Confirm Receipt',
                color: const Color(0xFF00C896),
                onPressed: () async {
                  try {
                    await state.updateTransactionStatus(tx.id, EscrowStatus.delivered);
                    if (context.mounted) {
                      // Show review dialog
                      final reviewed = await showReviewDialog(context, tx.id, tx.listingTitle);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(reviewed ? '✓ Receipt confirmed. Review submitted!' : '✓ Receipt confirmed. Funds released to seller.')),
                        );
                      }
                    }
                  } catch (e) {
                    _showError(context, e);
                  }
                },
              ),

            if (tx.status == EscrowStatus.shipped || tx.status == EscrowStatus.fundsDeposited)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFF4757), side: const BorderSide(color: Color(0xFFFF4757))),
                    onPressed: () async {
                      try {
                        await state.updateTransactionStatus(tx.id, EscrowStatus.disputed);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        _showError(context, e);
                      }
                    },
                    child: const Text('Open Dispute'),
                  ),
                ),
              ),

            if (tx.status == EscrowStatus.pending || tx.status == EscrowStatus.fundsDeposited)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white54, side: const BorderSide(color: Colors.white54)),
                    onPressed: () async {
                      try {
                        await state.updateTransactionStatus(tx.id, EscrowStatus.cancelled);
                        if (context.mounted) Navigator.pop(context);
                      } catch (e) {
                        _showError(context, e);
                      }
                    },
                    child: const Text('Cancel Transaction'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showShipDialog(BuildContext context, AppState state, EscrowTransaction tx) {
    final providerController = TextEditingController();
    final trackingController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111634),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ship Goods', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter logistics details for the buyer to track their shipment.', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 16),
            GlassInput(controller: providerController, label: 'Logistics Provider', hint: 'DHL, GIG, Red Star'),
            const SizedBox(height: 12),
            GlassInput(controller: trackingController, label: 'Tracking Number', hint: 'TRK123456789'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          GoldButton3D(
            label: 'Ship Now',
            color: const Color(0xFF4A90D9),
            width: 120,
            onPressed: () async {
              try {
                await state.updateTransactionStatus(
                  tx.id, EscrowStatus.shipped,
                  logisticsProvider: providerController.text.trim(),
                  trackingNumber: trackingController.text.trim(),
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                }
              } catch (e) {
                Navigator.pop(ctx);
                _showError(context, e);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: const Color(0xFFFF4757)),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Expanded(child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: bold ? const Color(0xFFFFD700) : Colors.white, fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal))),
        ],
      ),
    );
  }

  Widget _buildStep({required String icon, required String title, required String desc, required bool isComplete, required bool isCurrent, required bool isLast}) {
    final color = isComplete ? const Color(0xFF00C896) : isCurrent ? const Color(0xFFFFD700) : Colors.white24;

    return Column(
      children: [
        Row(
          children: [
            NeumorphicContainer(
              borderRadius: 22,
              padding: EdgeInsets.zero,
              concave: !isComplete && !isCurrent,
              child: SizedBox(
                width: 44, height: 44,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.15), border: Border.all(color: color, width: 2)),
                    child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isComplete || isCurrent ? Colors.white : Colors.white54, fontWeight: FontWeight.w600)),
                  Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            if (isComplete) const Icon(Iconsax.tick_circle, color: Color(0xFF00C896)),
          ],
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.only(left: 21, top: 4, bottom: 4),
            width: 2, height: 24,
            color: isComplete ? const Color(0xFF00C896) : Colors.white12,
          ),
      ],
    );
  }

  static String _formatPrice(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)}M';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toStringAsFixed(0);
  }
}
