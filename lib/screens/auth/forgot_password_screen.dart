import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../../services/log_service.dart';
import '../../theme/dhamma_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    LogService.logScreen('forgot_password');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ref
        .read(authServiceProvider)
        .sendPasswordResetEmail(_emailCtrl.text.trim());

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _emailSent = true);
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
    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white54),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        child: _emailSent ? _SuccessView(email: _emailCtrl.text.trim()) : _FormView(
          formKey: _formKey,
          emailCtrl: _emailCtrl,
          isLoading: _isLoading,
          onSend: _send,
        ),
      ),
    );
  }
}

// ── Form View ─────────────────────────────────────────────────────────
class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSend;

  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          '🔑',
          style: const TextStyle(fontSize: 48),
        ).animate().fadeIn().scale(begin: const Offset(0.5, 0.5)),

        const SizedBox(height: 24),

        Text(
          'ลืมรหัสผ่าน?',
          style: GoogleFonts.notoSerifThai(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: DhammaTheme.gold,
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 8),

        Text(
          'กรอกอีเมลที่ใช้สมัครสมาชิก เราจะส่งลิงก์รีเซ็ตรหัสผ่านให้คุณ',
          style: GoogleFonts.sarabun(color: Colors.white60, height: 1.5),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 32),

        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'อีเมล',
                style:
                    GoogleFonts.sarabun(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'กรุณากรอกอีเมล';
                  if (!v.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'example@email.com',
                  hintStyle: const TextStyle(color: Colors.white24),
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
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSend,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: DhammaTheme.ink,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'ส่งลิงก์รีเซ็ตรหัสผ่าน',
                          style: GoogleFonts.notoSerifThai(
                              fontWeight: FontWeight.bold),
                        ),
                ).animate().fadeIn(delay: 300.ms),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Success View ──────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📧', style: TextStyle(fontSize: 72))
              .animate()
              .fadeIn()
              .scale(begin: const Offset(0.3, 0.3), curve: Curves.easeOutBack),

          const SizedBox(height: 24),

          Text(
            'ส่งอีเมลแล้ว!',
            style: GoogleFonts.notoSerifThai(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: DhammaTheme.gold,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 12),

          Text(
            'เราส่งลิงก์รีเซ็ตรหัสผ่านไปที่',
            style: GoogleFonts.sarabun(color: Colors.white60),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          Text(
            email,
            style: GoogleFonts.sarabun(
              color: DhammaTheme.gold2,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 350.ms),

          const SizedBox(height: 8),

          Text(
            'กรุณาตรวจสอบกล่องขยะหากไม่พบอีเมล',
            style: GoogleFonts.sarabun(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(
                'กลับไปหน้าเข้าสู่ระบบ',
                style: GoogleFonts.notoSerifThai(fontWeight: FontWeight.bold),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}
