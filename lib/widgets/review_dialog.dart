import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import '../widgets/glass_ui.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Shows a review dialog after a completed escrow transaction.
/// Returns true if review was submitted.
Future<bool> showReviewDialog(BuildContext context, String escrowId, String listingTitle) async {
  int rating = 5;
  final commentCtrl = TextEditingController();
  bool submitting = false;

  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: SafePayColors.bgLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Iconsax.star_1, color: SafePayColors.gold, size: 40),
            const SizedBox(height: 8),
            Text('Rate Your Experience', style: SafePayText.heading3()),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(listingTitle, style: SafePayText.bodySmall(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => rating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < rating ? Iconsax.star_1 : Iconsax.star,
                      color: index < rating ? SafePayColors.gold : SafePayColors.textMuted,
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentCtrl,
              maxLines: 3,
              style: SafePayText.body(),
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)...',
                hintStyle: SafePayText.body(color: SafePayColors.textMuted),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: SafePayColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: SafePayColors.gold),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: submitting ? null : () => Navigator.pop(ctx, false),
            child: Text('Skip', style: SafePayText.body(color: SafePayColors.textSecondary)),
          ),
          GoldButton3D(
            label: submitting ? '...' : 'Submit',
            width: 130,
            onPressed: submitting ? null : () async {
              setState(() => submitting = true);
              try {
                await ApiService.createReview(
                  escrowId: escrowId,
                  rating: rating,
                  comment: commentCtrl.text,
                );
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: SafePayColors.red),
                  );
                }
                setState(() => submitting = false);
              }
            },
          ),
        ],
      ),
    ),
  ) ?? false;
}
