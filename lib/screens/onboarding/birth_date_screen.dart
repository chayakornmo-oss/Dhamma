import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_state_providers.dart';
import '../../router/app_router.dart';
import '../../services/firestore_service.dart';
import '../../services/fortune_service.dart';
import '../../theme/dhamma_theme.dart';

class BirthDateScreen extends ConsumerStatefulWidget {
  const BirthDateScreen({super.key});

  @override
  ConsumerState<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends ConsumerState<BirthDateScreen> {
  DateTime? _selectedDate;
  bool _isSaving = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 7300)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: DhammaTheme.gold,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _elementResult(DateTime date) {
    final el = FortuneService.elementFromBirthYear(date.year);
    const weekdays = [
      '', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์'
    ];
    final weekday = weekdays[date.weekday];
    return 'เกิดวัน$weekday\n${FortuneService.elementThaiName(el)} 🌟';
  }

  Future<void> _completeOnboarding() async {
    if (_selectedDate == null || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      final input = ref.read(onboardingInputProvider);
      await ref.read(firestoreServiceProvider).createUserProfile(
        name: input.name.isEmpty ? 'ผู้ใช้' : input.name,
        birthDate: _selectedDate!,
        goals: input.goals,
      );

      // Mark onboarding complete via the Riverpod provider
      // (which persists to SharedPreferences and updates the router's redirect)
      await ref.read(onboardingProvider.notifier).setOnboarded();

      // Router redirect will navigate to /home automatically.
      // Explicit push is a safety net.
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == 1 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i <= 1 ? DhammaTheme.gold : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'คุณเกิดวันไหน?',
                style: GoogleFonts.notoSerifThai(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: DhammaTheme.gold,
                ),
              ).animate().fadeIn().slideY(),
              const SizedBox(height: 16),
              Text(
                'เพื่อคำนวณวันมงคลและธาตุประจำตัว',
                style: GoogleFonts.sarabun(
                    fontSize: 16, color: Colors.white70),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: DhammaTheme.gold.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'เลือกวัน/เดือน/ปีเกิด'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: GoogleFonts.sarabun(
                          fontSize: 18,
                          color: _selectedDate == null
                              ? Colors.white54
                              : Colors.white,
                        ),
                      ),
                      const Icon(Icons.calendar_today,
                          color: DhammaTheme.gold),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
              if (_selectedDate != null) ...[
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DhammaTheme.gold.withOpacity(0.1),
                      border: Border.all(
                          color: DhammaTheme.gold.withOpacity(0.3)),
                    ),
                    child: Text(
                      _elementResult(_selectedDate!),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerifThai(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DhammaTheme.gold2,
                        height: 1.5,
                      ),
                    ),
                  ).animate().scale(
                      delay: 100.ms, curve: Curves.easeOutBack),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedDate == null || _isSaving)
                      ? null
                      : _completeOnboarding,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: DhammaTheme.ink,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('เข้าสู่ ธรรมะ+'),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
