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

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final List<String> _goals = [
    'เริ่มวันดีๆ',
    'หาบทสวด',
    'ติดตามการขอพร',
    'เช็คดวง',
    'ทำบุญ',
    'ท่องเที่ยววัด',
  ];
  final Set<String> _selectedGoals = {};

  @override
  void initState() {
    super.initState();
    LogService.logScreen('onboarding');
    // Pre-populate name from:
    // 1. Previously stored onboarding input (e.g. from RegisterScreen)
    // 2. Firebase Auth displayName (Google/Apple sign-in)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stored = ref.read(onboardingInputProvider).name;
      if (stored.isNotEmpty) {
        _nameController.text = stored;
      } else {
        final displayName =
            ref.read(authServiceProvider).currentUser?.displayName;
        if (displayName != null && displayName.isNotEmpty) {
          _nameController.text = displayName;
        }
      }
    });
  }

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
                    width: i == 0 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 0 ? DhammaTheme.gold : Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
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
                style: GoogleFonts.sarabun(
                    fontSize: 14, color: Colors.white70),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
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
                        isSelected
                            ? _selectedGoals.remove(goal)
                            : _selectedGoals.add(goal);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DhammaTheme.gold.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: isSelected
                                ? DhammaTheme.gold
                                : Colors.white10,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          goal,
                          style: GoogleFonts.sarabun(
                            color: isSelected
                                ? DhammaTheme.gold
                                : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
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
                  onPressed: _onNext,
                  child: const Text('ต่อไป'),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _onNext() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อของคุณก่อนไปต่อครับ')),
      );
      return;
    }

    // Store name and goals in the provider so BirthDateScreen can read them
    ref.read(onboardingInputProvider.notifier).state = OnboardingInput(
      name: name,
      goals: _selectedGoals.toList(),
    );

    context.push(AppRoutes.birthDate);
  }
}
