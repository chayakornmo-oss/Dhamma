import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/dhamma_theme.dart';
import '../../router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BirthDateScreen extends StatefulWidget {
  const BirthDateScreen({super.key});

  @override
  State<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends State<BirthDateScreen> {
  DateTime? _selectedDate;
  String _showResult = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 7300)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: DhammaTheme.gold,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _showResult = _calculateElement(picked);
      });
    }
  }

  String _calculateElement(DateTime date) {
    const elements = ['ดิน', 'น้ำ', 'ลม', 'ไฟ', 'ทอง', 'ไม้'];
    final element = elements[date.year % elements.length];
    const weekdays = ['อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์'];
    final weekday = weekdays[date.weekday % 7];
    return 'เกิดวัน$weekday\nธาตุ$element 🌟';
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', true);
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhammaTheme.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == 1 ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index <= 1 ? DhammaTheme.gold : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
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
                style: GoogleFonts.sarabun(fontSize: 16, color: Colors.white70),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),
              
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DhammaTheme.gold.withOpacity(0.5)),
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
                          color: _selectedDate == null ? Colors.white54 : Colors.white,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: DhammaTheme.gold),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),
              
              if (_showResult.isNotEmpty) ...[
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DhammaTheme.gold.withOpacity(0.1),
                      border: Border.all(color: DhammaTheme.gold.withOpacity(0.3)),
                    ),
                    child: Text(
                      _showResult,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerifThai(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: DhammaTheme.gold2,
                        height: 1.5,
                      ),
                    ),
                  ).animate().scale(delay: 100.ms, curve: Curves.easeOutBack),
                ),
              ],
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedDate == null ? null : _completeOnboarding,
                  child: const Text('เข้าสู่ ธรรมะ+'),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
