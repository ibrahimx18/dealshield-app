import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/auth_service.dart';
import '../services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../widgets/glass_ui.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await AuthService.login(
          emailOrPhone: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        await AuthService.register(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      }
      if (context.mounted) {
        await context.read<AppState>().initData();
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFFF4757),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MeshGradientBg(
      child: Scaffold(
        backgroundColor: SafePayColors.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // 3D Logo — glass container with gold glow
                GlassContainer(
                  width: 90,
                  blur: 20,
                  opacity: 0.1,
                  borderRadius: 24,
                  padding: const EdgeInsets.all(18),
                  tint: SafePayColors.gold,
                  child: const Icon(Iconsax.shield, size: 48, color: SafePayColors.gold),
                ),
                const SizedBox(height: 20),
                // Brand name in Playfair Display — luxury serif
                Text('SafePay', style: SafePayText.brand(size: 36)),
                const SizedBox(height: 6),
                Text('No more heartache. Guaranteed.', style: SafePayText.body(color: SafePayColors.gold)),
                const SizedBox(height: 48),

                // Glass toggle
                GlassToggle(
                  value: _isLogin,
                  leftLabel: 'Login',
                  rightLabel: 'Register',
                  onChanged: (v) => setState(() => _isLogin = v),
                ),
                const SizedBox(height: 24),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        GlassInput(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          hint: 'Geralt Revia',
                          icon: Iconsax.user,
                          validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 16),
                        GlassInput(
                          controller: _phoneCtrl,
                          label: 'Phone',
                          hint: '+234 803 XXX XXXX',
                          icon: Iconsax.call,
                          keyboard: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? 'Enter your phone' : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      GlassInput(
                        controller: _emailCtrl,
                        label: 'Email or Phone',
                        hint: 'you@example.com',
                        icon: Iconsax.sms,
                        validator: (v) => v!.isEmpty ? 'Enter email or phone' : null,
                      ),
                      const SizedBox(height: 16),
                      GlassInput(
                        controller: _passwordCtrl,
                        label: 'Password',
                        hint: '••••••••',
                        icon: Iconsax.lock,
                        obscure: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter password';
                          if (v.length < 8) return 'Password must be at least 8 characters';
                          if (!v.contains(RegExp(r'[A-Za-z]')) || !v.contains(RegExp(r'[0-9]'))) {
                            return 'Must contain letters and numbers';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // 3D Gold Button
                GoldButton3D(
                  label: _isLogin ? 'Login' : 'Create Account',
                  loading: _loading,
                  icon: _isLogin ? Iconsax.login : Iconsax.user_add,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                      ? "Don't have an account? Register"
                      : 'Already have an account? Login',
                    style: const TextStyle(color: SafePayColors.gold),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
