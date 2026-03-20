import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/dhamma_theme.dart';
import '../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final isOnboarded = prefs.getBool('is_onboarded') ?? false;
      if (mounted) {
        if (isOnboarded) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.onboarding);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DhammaTheme.ink, Color(0xFF2A1550)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DhammaTheme.gold.withOpacity(0.5),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Text('🪷', style: TextStyle(fontSize: 80)),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .moveY(begin: -10, end: 10, duration: 2.seconds, curve: Curves.easeInOut),
            const SizedBox(height: 32),
            Text(
              'ธรรมะ+',
              style: GoogleFonts.notoSerifThai(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: DhammaTheme.gold,
              ),
            ).animate().fadeIn(duration: 1.seconds).slideY(begin: 0.2),
            const SizedBox(height: 16),
            Text(
              'ยินดีต้อนรับกลับบ้าน',
              style: GoogleFonts.sarabun(
                fontSize: 18,
                color: Colors.white70,
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
