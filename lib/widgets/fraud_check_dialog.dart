import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import '../widgets/glass_ui.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Shows AI fraud check result in a beautiful dialog
Future<void> showFraudCheckDialog(BuildContext context, Listing listing, {int sellerDeals = 0, double sellerRating = 5.0}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const Center(child: CircularProgressIndicator(color: SafePayColors.gold)),
  );

  FraudCheckResult? result;
  try {
    result = await ApiService.fraudCheck(
      title: listing.title,
      description: listing.description,
      price: listing.price,
      category: listing.category.label,
      sellerName: listing.sellerName,
      sellerDeals: sellerDeals,
      sellerRating: sellerRating,
    );
  } catch (e) {
    // ignore
  }

  // Pop the loading indicator
  if (context.mounted) Navigator.pop(context);

  if (result == null || !context.mounted) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fraud check unavailable. Try again later.')),
      );
    }
    return;
  }

  // Show result dialog
  Color riskColor;
  IconData riskIcon;
  switch (result.riskLevel) {
    case 'HIGH':
      riskColor = SafePayColors.red;
      riskIcon = Iconsax.danger;
      break;
    case 'MEDIUM':
      riskColor = Colors.orange;
      riskIcon = Iconsax.warning_2;
      break;
    default:
      riskColor = SafePayColors.green;
      riskIcon = Iconsax.shield_tick;
  }

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: SafePayColors.bgLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          NeumorphicIcon(icon: riskIcon, size: 28, containerSize: 60, color: riskColor),
          const SizedBox(height: 10),
          Text('AI Fraud Check', style: SafePayText.heading3()),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risk score bar
          Center(
            child: Column(
              children: [
                Text(
                  '${result!.riskScore}/100',
                  style: SafePayText.money(size: 36, color: riskColor),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: riskColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    result!.riskLevel,
                    style: SafePayText.label(color: riskColor, weight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (result!.redFlags.isNotEmpty) ...[
            Text('⚠️ Red Flags:', style: SafePayText.heading4(color: SafePayColors.red)),
            const SizedBox(height: 8),
            ...result!.redFlags.map((flag) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.close_circle, color: SafePayColors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(flag, style: SafePayText.bodySmall())),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],
          // Recommendation
          GlassContainer(
            blur: 8,
            opacity: 0.06,
            borderRadius: 12,
            padding: const EdgeInsets.all(12),
            tint: riskColor,
            showShadow: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Iconsax.info_circle, color: riskColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result!.recommendation,
                    style: SafePayText.bodySmall(color: SafePayColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        GoldButton3D(
          label: 'Got it',
          width: 120,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}
