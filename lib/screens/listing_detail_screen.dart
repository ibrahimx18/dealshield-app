import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_models.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../widgets/glass_ui.dart';
import '../widgets/fraud_check_dialog.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listing = ModalRoute.of(context)!.settings.arguments as Listing;
    final state = Provider.of<AppState>(context);
    final commission = listing.price * 0.025;

    return Scaffold(
      appBar: AppBar(title: Text(listing.category.label)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder — glass with category gradient
            GlassContainer(
              width: double.infinity,
              blur: 0,
              opacity: 0.15,
              borderRadius: 0,
              showBorder: false,
              showShadow: false,
              padding: const EdgeInsets.symmetric(vertical: 60),
              gradient: LinearGradient(
                colors: [
                  _parseColor(listing.category.color).withOpacity(0.3),
                  _parseColor(listing.category.color).withOpacity(0.05),
                ],
              ),
              child: Center(child: Text(listing.category.icon, style: const TextStyle(fontSize: 80))),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (listing.verified)
                        StatusBadge3D(
                          icon: '✓',
                          label: 'Verified',
                          color: const Color(0xFF00C896),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Iconsax.location, color: Colors.white54, size: 16),
                      const SizedBox(width: 4),
                      Text(listing.location, style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price card — glass with gold gradient
                  GlassContainer(
                    width: double.infinity,
                    blur: 15,
                    opacity: 0.12,
                    borderRadius: 16,
                    padding: const EdgeInsets.all(16),
                    gradient: const LinearGradient(colors: [Color(0xFF111634), Color(0xFF1A2050)]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price', style: TextStyle(color: Colors.white54, fontSize: 14)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PriceTag3D(price: '₦${_formatPrice(listing.price)}', fontSize: 24),
                            const SizedBox(height: 4),
                            Text('+ 2.5% escrow fee (₦${_formatPrice(commission)})', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Seller info — glass card
                  GlassCard(
                    glass: true,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    child: ListTile(
                      leading: const NeumorphicIcon(icon: Iconsax.user, color: Color(0xFFFFD700), containerSize: 44),
                      title: Text(listing.sellerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Row(
                        children: [
                          const Icon(Iconsax.star_1, color: Color(0xFFFFD700), size: 14),
                          Text(' ${listing.sellerRating} rating', style: const TextStyle(color: Colors.white54)),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111634)),
                        child: const Text('Chat', style: TextStyle(color: Color(0xFFFFD700))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(listing.description, style: const TextStyle(color: Colors.white70, height: 1.6)),
                  const SizedBox(height: 24),

                  // AI Fraud Check button
                  GestureDetector(
                    onTap: () => showFraudCheckDialog(context, listing),
                    child: GlassContainer(
                      width: double.infinity,
                      blur: 8,
                      opacity: 0.06,
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      tint: SafePayColors.blue,
                      showShadow: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.shield_search, color: SafePayColors.blue, size: 18),
                          const SizedBox(width: 8),
                          Text('AI Fraud Check', style: SafePayText.label(color: SafePayColors.blue, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Action button — 3D gold button
                  GoldButton3D(
                    label: 'I Want to Buy — Deposit to Escrow',
                    icon: Iconsax.shield_tick,
                    onPressed: () {
                      _showDepositDialog(context, listing, commission, state);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context, Listing listing, double commission, AppState state) {
    final total = listing.price + commission;
    bool addInsurance = false;
    final insuranceFee = listing.price * 0.015;
    final totalWithInsurance = total + insuranceFee;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF111634),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Escrow Deposit', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogRow('Item Price', '₦${_formatPrice(listing.price)}'),
                _dialogRow('Escrow Fee (2.5%)', '₦${_formatPrice(commission)}'),
                const Divider(color: Colors.white24),

                // Insurance checkbox
                CheckboxListTile(
                  value: addInsurance,
                  onChanged: (v) => setState(() => addInsurance = v ?? false),
                  activeColor: const Color(0xFF00C896),
                  title: const Text('Insure shipment (1.5%)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('+₦${_formatPrice(insuranceFee)} — goods protected during shipping', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),

                if (addInsurance)
                  _dialogRow('Insurance Fee (1.5%)', '₦${_formatPrice(insuranceFee)}'),

                const Divider(color: Colors.white24),
                _dialogRow('Total to Deposit', '₦${_formatPrice(addInsurance ? totalWithInsurance : total)}', bold: true),
                const SizedBox(height: 12),
                GlassContainer(
                  blur: 10,
                  opacity: 0.06,
                  borderRadius: 10,
                  padding: const EdgeInsets.all(12),
                  tint: const Color(0xFF00C896),
                  showShadow: false,
                  child: const Row(
                    children: [
                      Icon(Iconsax.shield, color: Color(0xFF00C896), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text('Your money is safe. Funds only released to seller when you confirm receipt.', style: TextStyle(color: Color(0xFF00C896), fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
            GoldButton3D(
              label: 'Deposit Now',
              width: 140,
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await state.createEscrow(listing.id, insured: addInsurance);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✓ ₦${_formatPrice(addInsurance ? totalWithInsurance : total)} deposited to escrow. Seller notified.')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: const Color(0xFFFF4757)),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? Colors.white : Colors.white54, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: bold ? const Color(0xFFFFD700) : Colors.white, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  static String _formatPrice(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)}M';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toStringAsFixed(0);
  }

  Color _parseColor(String hex) => Color(int.parse(hex.replaceFirst('#', '0xFF')));
}
