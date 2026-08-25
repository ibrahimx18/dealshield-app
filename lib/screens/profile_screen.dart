import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../widgets/glass_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _verifying = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final profile = state.profile ?? AuthService.profile;

    if (profile == null) {
      return MeshGradientBg(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: const CircularProgressIndicator(color: SafePayColors.gold),
          ),
        ),
      );
    }

    // Badge widget
    final badgeInfo = _getBadgeInfo(profile.badge);

    return MeshGradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            color: SafePayColors.gold,
            onRefresh: () async {
              await state.refreshProfile();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text('Profile', style: SafePayText.brand(size: 26)),
                  const SizedBox(height: 24),

                  // Profile header — gold accent card with badge
                  GoldAccentCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [SafePayColors.gold, SafePayColors.bg],
                            ),
                            border: Border.all(color: SafePayColors.gold, width: 2),
                          ),
                          child: const Icon(Iconsax.user, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(profile.name, style: SafePayText.heading2()),
                        if (profile.businessName != null) ...[
                          const SizedBox(height: 4),
                          Text(profile.businessName!, style: SafePayText.bodySmall()),
                        ],
                        const SizedBox(height: 8),
                        // Badge
                        if (badgeInfo != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: badgeInfo['color'].withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: badgeInfo['color'].withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(badgeInfo['icon'], color: badgeInfo['color'], size: 14),
                                const SizedBox(width: 4),
                                Text(badgeInfo['label'], style: SafePayText.label(color: badgeInfo['color'], weight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.star_1, color: SafePayColors.gold, size: 16),
                            Text(
                              ' ${profile.rating} • ${profile.totalDeals} deals • ${profile.reviewCount} reviews',
                              style: SafePayText.bodySmall(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verification section
                  _buildSectionTitle('Verification'),
                  _buildVerification(context, 'NIN Verified', profile.ninVerified, 'National ID linked', state),
                  _buildVerification(context, 'BVN Verified', profile.bvnVerified, 'Bank verification', state, type: 'bvn'),
                  _buildVerification(context, 'Business Verified', profile.businessVerified, profile.businessName ?? 'Register your business', state, type: 'business'),
                  _buildVerification(context, 'Phone Verified', profile.phoneVerified, profile.phone, state),

                  const SizedBox(height: 20),

                  // Quick actions
                  _buildSectionTitle('Quick Actions'),
                  _buildMenuItem(Iconsax.link_2, 'Payment Links', () {
                    Navigator.pushNamed(context, '/payment-links');
                  }),
                  _buildMenuItem(Iconsax.wallet, 'Wallet', () => Navigator.pushNamed(context, '/wallet')),
                  _buildMenuItem(Iconsax.clock, 'Transaction History', () {}),

                  const SizedBox(height: 20),

                  // Support
                  _buildSectionTitle('Support'),
                  _buildMenuItem(Iconsax.support, 'Help & Support', () {}),
                  _buildMenuItem(Iconsax.document_text, 'Terms & Privacy', () {}),
                  _buildMenuItem(Iconsax.logout, 'Logout', () async {
                    await state.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                    }
                  }, color: SafePayColors.red),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? _getBadgeInfo(String badge) {
    switch (badge) {
      case 'top_dealer':
        return {'label': '★ Top Dealer', 'color': SafePayColors.gold, 'icon': Iconsax.crown};
      case 'trusted':
        return {'label': '✓ Trusted', 'color': SafePayColors.green, 'icon': Iconsax.shield_tick};
      case 'verified':
        return {'label': 'Verified', 'color': SafePayColors.blue, 'icon': Iconsax.verify};
      default:
        return null;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: SafePayText.heading3(color: SafePayColors.gold)),
      ),
    );
  }

  Widget _buildVerification(BuildContext context, String title, bool verified, String subtitle, AppState state, {String type = 'nin'}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            NeumorphicIcon(
              icon: verified ? Iconsax.shield_tick : Iconsax.danger,
              size: 22,
              containerSize: 48,
              color: verified ? SafePayColors.green : SafePayColors.red,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: SafePayText.heading4()),
                  Text(subtitle, style: SafePayText.bodySmall()),
                ],
              ),
            ),
            if (verified)
              const Icon(Iconsax.tick_circle, color: SafePayColors.green, size: 24)
            else
              GoldButton3D(
                label: _verifying ? '...' : 'Verify',
                onPressed: _verifying ? null : () => _showVerifyDialog(context, type, state),
                width: 90,
              ),
          ],
        ),
      ),
    );
  }

  void _showVerifyDialog(BuildContext context, String type, AppState state) {
    if (type == 'bvn') {
      _showBVNDialog(context, state);
    } else if (type == 'business') {
      _showBusinessDialog(context, state);
    } else {
      // NIN verification — simple confirm
      _doVerify(context, state, 'nin', null);
    }
  }

  void _showBVNDialog(BuildContext context, AppState state) {
    final bvnController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SafePayColors.bgLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('BVN Verification', style: SafePayText.heading3()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your 11-digit BVN number', style: SafePayText.bodySmall()),
            const SizedBox(height: 12),
            TextField(
              controller: bvnController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              style: SafePayText.body(),
              decoration: InputDecoration(
                hintText: '12345678901',
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
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: SafePayText.body(color: SafePayColors.textSecondary)),
          ),
          GoldButton3D(
            label: 'Verify',
            width: 120,
            onPressed: () {
              Navigator.pop(ctx);
              _doVerify(context, state, 'bvn', {'bvn': bvnController.text});
            },
          ),
        ],
      ),
    );
  }

  void _showBusinessDialog(BuildContext context, AppState state) {
    final nameController = TextEditingController();
    final rcController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SafePayColors.bgLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Business Verification', style: SafePayText.heading3()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: SafePayText.body(),
              decoration: InputDecoration(
                hintText: 'Business name',
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
            const SizedBox(height: 12),
            TextField(
              controller: rcController,
              style: SafePayText.body(),
              decoration: InputDecoration(
                hintText: 'RC number (e.g. RC1234567)',
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
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: SafePayText.body(color: SafePayColors.textSecondary)),
          ),
          GoldButton3D(
            label: 'Verify',
            width: 120,
            onPressed: () {
              Navigator.pop(ctx);
              _doVerify(context, state, 'business', {
                'name': nameController.text,
                'rc': rcController.text,
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _doVerify(BuildContext context, AppState state, String type, Map<String, dynamic>? extra) async {
    setState(() => _verifying = true);
    try {
      if (type == 'bvn' && extra != null) {
        await ApiService.verifyBVN(extra['bvn']);
      } else if (type == 'business' && extra != null) {
        await ApiService.verifyBusiness(extra['name'], extra['rc']);
      } else {
        // NIN verification
      }
      await state.refreshProfile();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ ${type == 'bvn' ? 'BVN' : type == 'business' ? 'Business' : 'NIN'} verified successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: SafePayColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              NeumorphicIcon(icon: icon, size: 22, containerSize: 48, color: color),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: SafePayText.heading4(color: color))),
              const Icon(Iconsax.arrow_right_3, color: SafePayColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
