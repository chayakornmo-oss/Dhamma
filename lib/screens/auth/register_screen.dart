import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_state_providers.dart';
import '../../router/app_router.dart';
import '../../services/auth_service.dart';
import '../../services/log_service.dart';
import '../../theme/dhamma_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    LogService.logScreen('register');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Password strength ─────────────────────────────────────────────
  double _passwordStrength(String pw) {
    if (pw.isEmpty) return 0;
    double strength = 0;
    if (pw.length >= 6) strength += 0.2;
    if (pw.length >= 10) strength += 0.2;
    if (pw.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (pw.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (pw.contains(RegExp(r'[!@#\$%^&*]'))) strength += 0.2;
    return strength;
  }

  Color _strengthColor(double s) {
    if (s < 0.4) return Colors.redAccent;
    if (s < 0.7) return Colors.orangeAccent;
    return DhammaTheme.sage;
  }

  String _strengthLabel(double s) {
    if (s < 0.4) return 'อ่อน';
    if (s < 0.7) return 'พอใช้';
    return 'แข็งแกร่ง';
  }

  // ── Register ──────────────────────────────────────────────────────
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ref.read(authServiceProvider).registerWithEmail(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result.isSuccess) {
      // Pre-populate onboarding with the name the user just entered
      ref.read(onboardingInputProvider.notifier).state = OnboardingInput(
        name: _nameCtrl.text.trim(),
        goals: const [],
      );
      // Router will redirect to /onboarding because no Firestore profile yet
    } else if (result.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage!, style: GoogleFonts.sarabun()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pw = _passwordCtrl.text;
    final strength = _passwordStrength(pw);

    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white54),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สมัครสมาชิก',
              style: GoogleFonts.notoSerifThai(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: DhammaTheme.gold,
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            Text(
              'สร้างบัญชีเพื่อบันทึกความก้าวหน้าของคุณ',
              style: GoogleFonts.sarabun(color: Colors.white54, fontSize: 14),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 32),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name
                  _Field(
                    controller: _nameCtrl,
                    label: 'ชื่อ-นามสกุล',
                    hint: 'ชื่อของคุณ',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'กรุณากรอกชื่อ'
                        : null,
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 16),

                  // Email
                  _Field(
                    controller: _emailCtrl,
                    label: 'อีเมล',
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'กรุณากรอกอีเมล';
                      }
                      if (!v.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                      return null;
                    },
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 16),

                  // Password
                  _Field(
                    controller: _passwordCtrl,
                    label: 'รหัสผ่าน',
                    hint: 'อย่างน้อย 6 ตัวอักษร',
                    obscureText: _obscurePassword,
                    onChanged: (_) => setState(() {}),
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
                      if (v == null || v.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                      if (v.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                      return null;
                    },
                  ).animate().fadeIn(delay: 250.ms),

                  // Strength bar
                  if (pw.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: strength,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _strengthColor(strength)),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _strengthLabel(strength),
                          style: GoogleFonts.sarabun(
                            color: _strengthColor(strength),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),
                  ],

                  const SizedBox(height: 16),

                  // Confirm password
                  _Field(
                    controller: _confirmCtrl,
                    label: 'ยืนยันรหัสผ่าน',
                    hint: '••••••••',
                    obscureText: _obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white38,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v != _passwordCtrl.text) {
                        return 'รหัสผ่านไม่ตรงกัน';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
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
                              'สมัครสมาชิก',
                              style: GoogleFonts.notoSerifThai(
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'มีบัญชีอยู่แล้ว? ',
                        style: GoogleFonts.sarabun(color: Colors.white54),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'เข้าสู่ระบบ',
                          style: GoogleFonts.sarabun(
                            color: DhammaTheme.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable field ────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.sarabun(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
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
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: DhammaTheme.gold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
