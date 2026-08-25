import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/app_models.dart';
import '../widgets/glass_ui.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class PaymentLinksScreen extends StatefulWidget {
  const PaymentLinksScreen({super.key});

  @override
  State<PaymentLinksScreen> createState() => _PaymentLinksScreenState();
}

class _PaymentLinksScreenState extends State<PaymentLinksScreen> {
  List<PaymentLink> _links = [];
  bool _loading = true;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    setState(() => _loading = true);
    try {
      _links = await ApiService.getPaymentLinks();
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MeshGradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Payment Links', style: SafePayText.heading3()),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.add_circle, color: SafePayColors.gold),
              onPressed: _showCreateDialog,
            ),
          ],
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: SafePayColors.gold))
              : _links.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: SafePayColors.gold,
                      onRefresh: _loadLinks,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _links.length,
                        itemBuilder: (context, index) => _buildLinkCard(_links[index]),
                      ),
                    ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: SafePayColors.gold,
          onPressed: _showCreateDialog,
          child: const Icon(Iconsax.add, color: SafePayColors.bg),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeumorphicIcon(icon: Iconsax.link_2, size: 32, containerSize: 80, color: SafePayColors.gold),
          const SizedBox(height: 20),
          Text('No payment links yet', style: SafePayText.heading3()),
          const SizedBox(height: 8),
          Text('Create a shareable link so buyers can pay you safely', style: SafePayText.bodySmall()),
          const SizedBox(height: 24),
          GoldButton3D(
            label: 'Create Link',
            icon: Iconsax.add,
            onPressed: _showCreateDialog,
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(PaymentLink link) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NeumorphicIcon(icon: Iconsax.link_2, size: 22, containerSize: 48, color: SafePayColors.gold),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(link.title, style: SafePayText.heading4()),
                      Text('₦${_formatPrice(link.amount)} • ${link.category}', style: SafePayText.bodySmall()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: link.active ? SafePayColors.green.withOpacity(0.15) : SafePayColors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    link.active ? 'Active' : 'Inactive',
                    style: SafePayText.caption(color: link.active ? SafePayColors.green : SafePayColors.red),
                  ),
                ),
              ],
            ),
            if (link.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(link.description, style: SafePayText.bodySmall()),
            ],
            const SizedBox(height: 14),
            // Share link button
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    blur: 8,
                    opacity: 0.05,
                    borderRadius: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    showShadow: false,
                    child: Row(
                      children: [
                        const Icon(Iconsax.link, size: 14, color: SafePayColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'safepay.ng/p/${link.code}',
                            style: SafePayText.bodySmall(color: SafePayColors.gold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final url = 'http://15.204.248.160:8000/pay-links/${link.code}';
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard!')),
                    );
                  },
                  child: NeumorphicIcon(icon: Iconsax.copy, size: 18, containerSize: 40, color: SafePayColors.gold),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    await ApiService.deletePaymentLink(link.id);
                    _loadLinks();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link deleted')),
                      );
                    }
                  },
                  child: NeumorphicIcon(icon: Iconsax.trash, size: 18, containerSize: 40, color: SafePayColors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'cars';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: SafePayColors.bgLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Create Payment Link', style: SafePayText.heading3()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(titleCtrl, 'Title (e.g. Toyota Corolla 2015)'),
                const SizedBox(height: 12),
                _dialogField(amountCtrl, 'Amount (₦)', isNumber: true),
                const SizedBox(height: 12),
                _dialogField(descCtrl, 'Description (optional)', maxLines: 2),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: SafePayColors.bgLight,
                  style: SafePayText.body(),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: SafePayText.bodySmall(),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: SafePayColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: SafePayColors.gold),
                    ),
                  ),
                  items: ['cars', 'gold', 'dollars', 'oil', 'land'].map((c) {
                    return DropdownMenuItem(value: c, child: Text(c[0].toUpperCase() + c.substring(1)));
                  }).toList(),
                  onChanged: (v) => setState(() => category = v ?? 'cars'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: SafePayText.body(color: SafePayColors.textSecondary)),
            ),
            GoldButton3D(
              label: _creating ? '...' : 'Create',
              width: 120,
              onPressed: _creating ? null : () async {
                if (titleCtrl.text.isEmpty || amountCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                setState(() => _creating = true);
                try {
                  await ApiService.createPaymentLink(
                    title: titleCtrl.text,
                    amount: double.parse(amountCtrl.text),
                    category: category,
                    description: descCtrl.text,
                  );
                  _loadLinks();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Payment link created!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: SafePayColors.red),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _creating = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: SafePayText.body(),
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)}M';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toStringAsFixed(0);
  }
}
