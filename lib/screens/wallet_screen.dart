import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../widgets/glass_ui.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final balance = state.walletBalance;

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Balance card — glassmorphic with gold gradient
            GlassContainer(
              width: double.infinity,
              blur: 20,
              opacity: 0.12,
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF111634), Color(0xFF1A2050)],
              ),
              child: Column(
                children: [
                  const Text('Available Balance', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '₦${balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _walletAction(context, Iconsax.arrow_down, 'Deposit', const Color(0xFF00C896), () {
                        _showAmountDialog(context, 'Deposit', true, state);
                      }),
                      _walletAction(context, Iconsax.arrow_up, 'Withdraw', const Color(0xFF4A90D9), () {
                        _showAmountDialog(context, 'Withdraw', false, state);
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Paystack notice — glass container
            GlassContainer(
              width: double.infinity,
              blur: 10,
              opacity: 0.06,
              borderRadius: 14,
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  NeumorphicIcon(icon: Iconsax.card, color: Color(0xFFFFD700), size: 22, containerSize: 44),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paystack Integration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        Text('Card payments coming soon. For now, direct wallet funding.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recent activity
            const Text('Recent Activity', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: state.transactions.isNotEmpty
                ? Future.value(state.transactions.map((t) => {
                    'title': t.listingTitle,
                    'amount': -t.amount,
                    'type': 'escrow',
                  }).toList())
                : Future.value([]),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No transactions yet', style: TextStyle(color: Colors.white54))));
                }
                return Column(
                  children: snapshot.data!.map((tx) {
                    final isOut = (tx['amount'] as num) < 0;
                    return GlassCard(
                      glass: true,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      child: ListTile(
                        leading: NeumorphicIcon(
                          icon: isOut ? Iconsax.arrow_square_up : Iconsax.arrow_down,
                          color: isOut ? const Color(0xFFFF4757) : const Color(0xFF00C896),
                          size: 20,
                          containerSize: 40,
                        ),
                        title: Text(tx['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        trailing: Text(
                          '${isOut ? '-' : '+'}₦${(tx['amount'] as num).abs().toStringAsFixed(0)}',
                          style: TextStyle(color: isOut ? const Color(0xFFFF4757) : const Color(0xFF00C896), fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          NeumorphicContainer(
            borderRadius: 25,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: 50, height: 50,
              child: Center(child: Icon(icon, color: color, size: 24)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showAmountDialog(BuildContext context, String type, bool isDeposit, dynamic state) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111634),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(type, style: const TextStyle(color: Colors.white)),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount (₦)',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                hintStyle: const TextStyle(color: Colors.white30),
                prefixText: '₦ ',
                prefixStyle: const TextStyle(color: Color(0xFFFFD700)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          GoldButton3D(
            label: type,
            onPressed: () async {
              final amount = double.tryParse(ctrl.text) ?? 0;
              if (amount > 0) {
                Navigator.pop(context);
                try {
                  if (isDeposit) {
                    await state.depositToWallet(amount);
                  } else {
                    await state.withdrawFromWallet(amount);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✓ $type of ₦${amount.toStringAsFixed(0)} successful')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: const Color(0xFFFF4757)),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
