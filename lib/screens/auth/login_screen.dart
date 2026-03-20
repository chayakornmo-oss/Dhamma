import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_state_providers.dart';
import '../../router/app_router.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/log_service.dart';
import '../../theme/dhamma_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    LogService.logScreen('login');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Post-sign-in: check if returning user ─────────────────────────
  Future<void> _afterSignIn(dynamic user) async {
    if (user == null || !mounted) return;
    // If this user already has a Firestore profile they are onboarded
    final profile = await ref
        .read(firestoreServiceProvider)
        .getUserProfileOnce(user.uid as String);
    if (profile != null && mounted) {
      await ref.read(onboardingProvider.notifier).setOnboarded();
      await LogService.setUser(user.uid as String);
    }
    // If no profile → router redirect will send to /onboarding
  }

  // ── Email Sign-In ─────────────────────────────────────────────────
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true);

    final result = await ref.read(authServiceProvider).signInWithEmail(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );

    _setLoading(false);
    if (!mounted) return;

    if (result.isSuccess) {
      await _afterSignIn(result.user);
    } else if (result.errorMessage != null) {
      _showError(result.errorMessage!);
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    _setLoading(true);
    final result = await ref.read(authServiceProvider).signInWithGoogle();
    _setLoading(false);
    if (!mounted) return;

    if (result.isSuccess) {
      await _afterSignIn(result.user);
    } else if (result.errorMessage != null) {
      _showError(result.errorMessage!);
    }
  }

  // ── Apple Sign-In ─────────────────────────────────────────────────
  Future<void> _signInWithApple() async {
    _setLoading(true);
    final result = await ref.read(authServiceProvider).signInWithApple();
    _setLoading(false);
    if (!mounted) return;

    if (result.isSuccess) {
      await _afterSignIn(result.user);
    } else if (result.errorMessage != null) {
      _showError(result.errorMessage!);
    }
  }

  // ── Continue as Guest ─────────────────────────────────────────────
  Future<void> _continueAsGuest() async {
    _setLoading(true);
    final result = await ref.read(authServiceProvider).signInAnonymously();
    _setLoading(false);
    if (!mounted) return;

    if (!result.isSuccess && result.errorMessage != null) {
      _showError(result.errorMessage!);
    }
    // Success → router redirect handles navigation
  }

  void _setLoading(bool v) {
    if (mounted) setState(() => _isLoading = v);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.sarabun()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [DhammaTheme.ink, Color(0xFF1A1035), Color(0xFF0F1A10)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // ── Logo ──────────────────────────────────────────
                  const Text('🪷', style: TextStyle(fontSize: 64))
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.5, 0.5)),

                  const SizedBox(height: 16),

                  Text(
                    'ธรรมะ+',
                    style: GoogleFonts.notoSerifThai(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: DhammaTheme.gold,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  Text(
                    'ยินดีต้อนรับกลับบ้าน',
                    style: GoogleFonts.sarabun(
                      fontSize: 16,
                      color: Colors.white54,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 48),

                  // ── Form ─────────────────────────────────────────
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _DhammaTextField(
                          controller: _emailCtrl,
                          label: 'อีเมล',
                          hint: 'example@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'กรุณากรอกอีเมล';
                            }
                            if (!v.contains('@')) {
                              return 'รูปแบบอีเมลไม่ถูกต้อง';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),

                        const SizedBox(height: 16),

                        _DhammaTextField(
                          controller: _passwordCtrl,
                          label: 'รหัสผ่าน',
                          hint: '••••••••',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white38,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'กรุณากรอกรหัสผ่าน';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                        const SizedBox(height: 8),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.forgotPassword),
                            child: Text(
                              'ลืมรหัสผ่าน?',
                              style: GoogleFonts.sarabun(
                                color: DhammaTheme.gold2,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 450.ms),

                        const SizedBox(height: 8),

                        // Sign-in button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signInWithEmail,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: DhammaTheme.ink,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'เข้าสู่ระบบ',
                                    style: GoogleFonts.notoSerifThai(
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ).animate().fadeIn(delay: 500.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Divider ───────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.12))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'หรือ',
                          style: GoogleFonts.sarabun(color: Colors.white38),
                        ),
                      ),
                      Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.12))),
                    ],
                  ).animate().fadeIn(delay: 550.ms),

                  const SizedBox(height: 20),

                  // ── Social buttons ────────────────────────────────
                  _SocialButton(
                    label: 'เข้าสู่ระบบด้วย Google',
                    icon: '𝐆',
                    onPressed: _isLoading ? null : _signInWithGoogle,
                  ).animate().fadeIn(delay: 600.ms),

                  if (AuthService.isAppleSignInAvailable) ...[
                    const SizedBox(height: 12),
                    _SocialButton(
                      label: 'เข้าสู่ระบบด้วย Apple',
                      icon: '',
                      iconWidget:
                          const Icon(Icons.apple, color: Colors.white, size: 20),
                      onPressed: _isLoading ? null : _signInWithApple,
                    ).animate().fadeIn(delay: 650.ms),
                  ],

                  const SizedBox(height: 24),

                  // ── Continue as guest ─────────────────────────────
                  TextButton(
                    onPressed: _isLoading ? null : _continueAsGuest,
                    child: Text(
                      'ดำเนินการต่อโดยไม่ล็อกอิน',
                      style: GoogleFonts.sarabun(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 16),

                  // ── Register link ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ยังไม่มีบัญชี? ',
                        style: GoogleFonts.sarabun(color: Colors.white54),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: Text(
                          'สมัครสมาชิก',
                          style: GoogleFonts.sarabun(
                            color: DhammaTheme.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 750.ms),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Form Field ─────────────────────────────────────────────────
class _DhammaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _DhammaTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sarabun(
              color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: DhammaTheme.gold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Social Sign-In Button ─────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final String icon;
  final Widget? iconWidget;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    this.iconWidget,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget ??
                Text(icon,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.sarabun(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
