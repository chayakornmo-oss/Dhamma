import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/dhamma_theme.dart';
import '../../router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final List<String> _goals = [
    'เริ่มวันดีๆ', 'หาบทสวด', 'ติดตามการขอพร',
    'เช็คดวง', 'ทำบุญ', 'ท่องเที่ยววัด'
  ];
  final Set<String> _selectedGoals = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
                  width: index == 0 ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == 0 ? DhammaTheme.gold : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              const SizedBox(height: 48),
              Text(
                'แอปนี้จะช่วยคุณได้ยังไง?',
                style: GoogleFonts.notoSerifThai(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: DhammaTheme.gold,
                ),
              ).animate().fadeIn().slideY(),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ชื่อของคุณ',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: DhammaTheme.gold),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),
              Text(
                'เลือกเป้าหมายของคุณ (เลือกได้หลายข้อ)',
                style: GoogleFonts.sarabun(fontSize: 14, color: Colors.white70),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final isSelected = _selectedGoals.contains(goal);
                    return GestureDetector(
                      onTap: () => setState(() {
                        isSelected ? _selectedGoals.remove(goal) : _selectedGoals.add(goal);
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? DhammaTheme.gold.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: isSelected ? DhammaTheme.gold : Colors.white10,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          goal,
                          style: GoogleFonts.sarabun(
                            color: isSelected ? DhammaTheme.gold : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 400.ms),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      context.push(AppRoutes.birthDate);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณากรอกชื่อของคุณก่อนไปต่อครับ')),
                      );
                    }
                  },
                  child: const Text('ต่อไป'),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
