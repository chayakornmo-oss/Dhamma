import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/providers/app_state_providers.dart';
import '../router/app_router.dart';
import '../theme/dhamma_theme.dart';

/// Splash screen that actively resolves auth + onboarding state then
/// navigates itself. Falls back after 3 s so the app never freezes even
/// if Firebase auth stream is slow or SharedPreferences hangs.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _resolveAndNavigate();
  }

  Future<void> _resolveAndNavigate() async {
    // Wait for both providers — each capped at 3 s so we never get stuck.
    await Future.wait([
      ref
          .read(authStateStreamProvider.future)
          .timeout(const Duration(seconds: 3), onTimeout: () => null),
      ref
          .read(onboardingProvider.future)
          .timeout(const Duration(seconds: 3), onTimeout: () => false),
    ]);

    if (!mounted) return;

    final isOnboarded = ref.read(onboardingProvider).valueOrNull ?? false;

    if (isOnboarded) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onboarding);
    }
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
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                    begin: -10,
                    end: 10,
                    duration: 2.seconds,
                    curve: Curves.easeInOut),
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
              style: GoogleFonts.sarabun(fontSize: 18, color: Colors.white70),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
