import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════
// SafePay Premium UI System v3.0
// Inspired by PayPal, Payoneer, Stripe — professional fintech design
// Fonts: Playfair Display (brand/luxury), Sora (headings),
//        Inter (body), DM Mono (numbers/money)
// ═══════════════════════════════════════════════════════════════

class SafePayColors {
  static const Color bg = Color(0xFF060A14);
  static const Color bgMid = Color(0xFF0A0F1C);
  static const Color bgLight = Color(0xFF0F1525);
  static const Color bgLighter = Color(0xFF141B2E);
  static const Color surface = Color(0xFF1A2238);

  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8C547);
  static const Color goldDark = Color(0xFFB8941F);

  static const Color green = Color(0xFF00A878);
  static const Color greenLight = Color(0xFF1ABC9C);
  static const Color red = Color(0xFFE84855);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueDark = Color(0xFF1E40AF);

  static const Color textPrimary = Color(0xFFF0F2F5);
  static const Color textSecondary = Color(0xFF8892A6);
  static const Color textMuted = Color(0xFF5A6478);

  static const Color glassSurface = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  static const Color neumorphDark = Color(0xFF040710);
  static const Color neumorphLight = Color(0xFF121830);
}

// ─── Typography System ────────────────────────────────────────
class SafePayText {
  // Playfair Display for brand name — luxury serif
  static TextStyle brand({Color? color, FontWeight weight = FontWeight.w700, double size = 32}) =>
    GoogleFonts.playfairDisplay(color: color ?? SafePayColors.gold, fontSize: size, fontWeight: weight, letterSpacing: 1.5);

  // Sora for headings — geometric, modern
  static TextStyle heading1({Color? color, FontWeight weight = FontWeight.w700}) =>
    GoogleFonts.sora(color: color ?? SafePayColors.textPrimary, fontSize: 28, fontWeight: weight, letterSpacing: -0.5);

  static TextStyle heading2({Color? color, FontWeight weight = FontWeight.w600}) =>
    GoogleFonts.sora(color: color ?? SafePayColors.textPrimary, fontSize: 22, fontWeight: weight, letterSpacing: -0.3);

  static TextStyle heading3({Color? color, FontWeight weight = FontWeight.w600}) =>
    GoogleFonts.sora(color: color ?? SafePayColors.textPrimary, fontSize: 18, fontWeight: weight);

  static TextStyle heading4({Color? color, FontWeight weight = FontWeight.w500}) =>
    GoogleFonts.sora(color: color ?? SafePayColors.textPrimary, fontSize: 15, fontWeight: weight);

  // Inter for body
  static TextStyle body({Color? color, FontWeight weight = FontWeight.w400}) =>
    GoogleFonts.inter(color: color ?? SafePayColors.textPrimary, fontSize: 14, fontWeight: weight, height: 1.5);

  static TextStyle bodySmall({Color? color, FontWeight weight = FontWeight.w400}) =>
    GoogleFonts.inter(color: color ?? SafePayColors.textSecondary, fontSize: 12, fontWeight: weight, height: 1.4);

  static TextStyle label({Color? color, FontWeight weight = FontWeight.w500}) =>
    GoogleFonts.inter(color: color ?? SafePayColors.textSecondary, fontSize: 13, fontWeight: weight, letterSpacing: 0.3);

  static TextStyle caption({Color? color}) =>
    GoogleFonts.inter(color: color ?? SafePayColors.textMuted, fontSize: 11, fontWeight: FontWeight.w400);

  // DM Mono for numbers/money — tabular, monospace, premium
  static TextStyle money({Color? color, FontWeight weight = FontWeight.w700, double size = 24}) =>
    GoogleFonts.dmMono(color: color ?? SafePayColors.gold, fontSize: size, fontWeight: weight, letterSpacing: -0.5);

  static TextStyle button({Color? color, FontWeight weight = FontWeight.w600}) =>
    GoogleFonts.inter(color: color ?? SafePayColors.bg, fontSize: 15, fontWeight: weight, letterSpacing: 0.5);
}

// ─── Animated Mesh Gradient Background ─────────────────────────
/// Premium animated radial mesh gradient — slowly shifting glows
class MeshGradientBg extends StatefulWidget {
  final Widget child;
  final bool showGoldGlow;

  const MeshGradientBg({
    super.key,
    required this.child,
    this.showGoldGlow = true,
  });

  @override
  State<MeshGradientBg> createState() => _MeshGradientBgState();
}

class _MeshGradientBgState extends State<MeshGradientBg>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // Slowly shift positions
        final blueX = -80.0 + (t * 60);
        final goldX = -100.0 + (t * -40);
        final goldY = -50.0 + (t * 30);

        return Container(
          decoration: const BoxDecoration(color: SafePayColors.bg),
          child: Stack(
            children: [
              // Blue glow — top left, shifting
              Positioned(
                top: -100,
                left: blueX,
                child: Container(
                  width: 380, height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        SafePayColors.blue.withOpacity(0.10 + t * 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Gold glow — top right, shifting
              if (widget.showGoldGlow)
                Positioned(
                  top: goldY,
                  right: goldX,
                  child: Container(
                    width: 320, height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          SafePayColors.gold.withOpacity(0.08 + t * 0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              // Third glow — center, subtle green
              Positioned(
                bottom: -150 + (t * 40),
                right: -50,
                child: Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        SafePayColors.greenLight.withOpacity(0.04 + t * 0.02),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom gradient
              Positioned(
                bottom: -200,
                left: 0,
                right: 0,
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        SafePayColors.bgMid.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

// ─── Premium Glass Container ──────────────────────────────────
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? tint;
  final LinearGradient? gradient;
  final bool showBorder;
  final bool showShadow;
  final double? width;

  const GlassContainer({
    super.key,
    this.child,
    this.blur = 12,
    this.opacity = 0.06,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.tint,
    this.gradient,
    this.showBorder = true,
    this.showShadow = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient ??
            LinearGradient(
              colors: [
                (tint ?? Colors.white).withOpacity(opacity),
                (tint ?? SafePayColors.glassSurface).withOpacity(opacity * 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        border: showBorder
            ? Border.all(color: SafePayColors.glassBorder, width: 0.5)
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                  spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: child,
        ),
      ),
    );
  }
}

// ─── Neumorphic Container ─────────────────────────────────────
class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? baseColor;
  final bool concave;
  final double distance;

  const NeumorphicContainer({
    super.key,
    this.child,
    this.borderRadius = 14,
    this.padding,
    this.margin,
    this.baseColor,
    this.concave = false,
    this.distance = 6,
  });

  @override
  Widget build(BuildContext context) {
    final base = baseColor ?? SafePayColors.bgLight;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: concave
            ? [
                BoxShadow(
                  color: SafePayColors.neumorphDark.withOpacity(0.5),
                  blurRadius: distance,
                  spreadRadius: -2,
                  offset: Offset(-distance / 2, -distance / 2),
                ),
                BoxShadow(
                  color: SafePayColors.bgLighter.withOpacity(0.2),
                  blurRadius: distance,
                  spreadRadius: -2,
                  offset: Offset(distance / 2, distance / 2),
                ),
              ]
            : [
                BoxShadow(
                  color: SafePayColors.neumorphDark.withOpacity(0.4),
                  blurRadius: distance * 2,
                  spreadRadius: -3,
                  offset: Offset(distance / 2, distance / 2),
                ),
                BoxShadow(
                  color: SafePayColors.bgLighter.withOpacity(0.1),
                  blurRadius: distance,
                  spreadRadius: -1,
                  offset: Offset(-distance / 2, -distance / 2),
                ),
              ],
      ),
      child: child,
    );
  }
}

// ─── Premium Card ─────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final bool glass;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.glass = true,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = glass
        ? GlassContainer(
            margin: margin ?? const EdgeInsets.only(bottom: 10),
            borderRadius: borderRadius,
            padding: padding,
            gradient: gradient,
            child: child,
          )
        : NeumorphicContainer(
            margin: margin ?? const EdgeInsets.only(bottom: 10),
            borderRadius: borderRadius,
            padding: padding,
            child: child,
          );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

// ─── Premium 3D Gold Button with Shimmer ──────────────────────
class GoldButton3D extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final double width;
  final Color? color;

  const GoldButton3D({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.width = double.infinity,
    this.color,
  });

  @override
  State<GoldButton3D> createState() => _GoldButton3DState();
}

class _GoldButton3DState extends State<GoldButton3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btnColor = widget.color ?? SafePayColors.gold;
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: btnColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.loading ? null : widget.onPressed,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Base gradient
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [btnColor, btnColor.withOpacity(0.85)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: widget.loading
                      ? SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                            color: SafePayColors.bg, strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                            Icon(widget.icon, color: SafePayColors.bg, size: 18),
                              const SizedBox(width: 8),
                            ],
                            Text(widget.label, style: SafePayText.button()),
                          ],
                        ),
                ),
                // Shimmer sweep overlay
                if (!widget.loading)
                  AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (_, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          final t = _shimmerAnimation.value;
                          return LinearGradient(
                            begin: Alignment(t * 0.5 - 0.5, 0),
                            end: Alignment(t * 0.5, 0),
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0),
                            ],
                          ).createShader(bounds);
                        },
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.transparent, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(widget.label, style: SafePayText.button(color: Colors.transparent)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Premium Input Field ──────────────────────────────────────
class GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboard;
  final bool obscure;
  final String? Function(String?)? validator;
  final int maxLines;

  const GlassInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.keyboard,
    this.obscure = false,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SafePayText.label()),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                spreadRadius: -2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboard,
                obscureText: obscure,
                validator: validator,
                maxLines: maxLines,
                style: SafePayText.body(),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.inter(color: SafePayColors.textMuted, fontSize: 14),
                  prefixIcon: icon != null
                      ? Icon(icon, color: SafePayColors.gold, size: 20)
                      : null,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: SafePayColors.gold, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Neumorphic Icon ──────────────────────────────────────────
class NeumorphicIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final double containerSize;
  final bool pressed;

  const NeumorphicIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 20,
    this.containerSize = 42,
    this.pressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      borderRadius: containerSize / 2,
      padding: EdgeInsets.zero,
      concave: pressed,
      distance: 4,
      child: SizedBox(
        width: containerSize, height: containerSize,
        child: Center(
          child: Icon(icon, color: color ?? SafePayColors.gold, size: size),
        ),
      ),
    );
  }
}

// ─── Price Tag with 3D effect ─────────────────────────────────
class PriceTag3D extends StatelessWidget {
  final String price;
  final Color? color;
  final double fontSize;

  const PriceTag3D({
    super.key,
    required this.price,
    this.color,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? SafePayColors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [c.withOpacity(0.12), c.withOpacity(0.04)],
        ),
        border: Border.all(color: c.withOpacity(0.25), width: 0.5),
      ),
      child: Text(price, style: SafePayText.money(color: c, size: fontSize)),
    );
  }
}

// ─── Glass Toggle ─────────────────────────────────────────────
class GlassToggle extends StatelessWidget {
  final bool value;
  final String leftLabel;
  final String rightLabel;
  final ValueChanged<bool> onChanged;

  const GlassToggle({
    super.key,
    required this.value,
    required this.leftLabel,
    required this.rightLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 10,
      padding: const EdgeInsets.all(4),
      blur: 8,
      showShadow: false,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: value ? SafePayColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: value
                      ? [BoxShadow(color: SafePayColors.gold.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  leftLabel,
                  textAlign: TextAlign.center,
                  style: SafePayText.button(
                    color: value ? SafePayColors.bg : SafePayColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !value ? SafePayColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: !value
                      ? [BoxShadow(color: SafePayColors.gold.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  rightLabel,
                  textAlign: TextAlign.center,
                  style: SafePayText.button(
                    color: !value ? SafePayColors.bg : SafePayColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────
class StatusBadge3D extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const StatusBadge3D({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Verification Badge ────────────────────────────────────────
class VerifiedBadge extends StatelessWidget {
  final String label;
  final bool verified;

  const VerifiedBadge({
    super.key,
    required this.label,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    final color = verified ? SafePayColors.green : SafePayColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(verified ? Icons.verified : Icons.pending, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: SafePayText.heading3()),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: SafePayText.label(color: SafePayColors.gold, weight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ─── Gold Accent Card ─────────────────────────────────────────
/// Card with gold gradient border for premium content
class GoldAccentCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const GoldAccentCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            SafePayColors.gold.withOpacity(0.08),
            SafePayColors.goldLight.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: SafePayColors.gold.withOpacity(0.3),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: SafePayColors.gold.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Premium Chip ─────────────────────────────────────────────
class PremiumChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;

  const PremiumChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? SafePayColors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? c.withOpacity(0.15) : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? c.withOpacity(0.4) : Colors.white.withOpacity(0.06),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: selected ? c : SafePayColors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              color: selected ? c : SafePayColors.textSecondary,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
