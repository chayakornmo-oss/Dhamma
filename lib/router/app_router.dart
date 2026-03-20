import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/navigation/navigation_service.dart';
import '../core/providers/app_state_providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/main_shell.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/birth_date_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/vow/vow_tracker_screen.dart';
import '../screens/vow/add_vow_screen.dart';
import '../screens/fortune/fortune_screen.dart';
import '../screens/prayer/prayer_screen.dart';
import '../screens/prayer/prayer_detail_screen.dart';
import '../screens/donation/donation_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/checkin/daily_checkin_screen.dart';

class AppRoutes {
  // ── Auth ─────────────────────────────────────────────────────────
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // ── Onboarding ───────────────────────────────────────────────────
  static const onboarding = '/onboarding';
  static const birthDate = '/birth-date';

  // ── Main ─────────────────────────────────────────────────────────
  static const checkin = '/checkin';
  static const home = '/home';
  static const vow = '/vow';
  static const addVow = '/vow/add';
  static const fortune = '/fortune';
  static const prayer = '/prayer';
  static const prayerDetail = '/prayer-detail';
  static const donation = '/donation';
  static const profile = '/profile';

  // ── Freemium: routes that require login ──────────────────────────
  static const _restricted = {checkin, vow, fortune, donation, profile};
  static bool isRestricted(String path) =>
      _restricted.any((r) => path == r || path.startsWith('$r/'));
}

// ── RouterNotifier ────────────────────────────────────────────────────
/// Bridges Riverpod state (auth + onboarding) into GoRouter's
/// refreshListenable so route guards re-evaluate on state changes.
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  bool _isOnboarded = false;
  AsyncValue<User?> _auth = const AsyncValue.loading();

  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<bool>>(onboardingProvider, (_, next) {
      _isOnboarded = next.valueOrNull ?? false;
      notifyListeners();
    });
    _ref.listen<AsyncValue<User?>>(authStateStreamProvider, (_, next) {
      _auth = next;
      notifyListeners();
    });
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.toString();

    // ── Still loading Firebase auth → stay on splash ─────────────
    if (_auth.isLoading) {
      return path == AppRoutes.splash ? null : AppRoutes.splash;
    }

    final user = _auth.valueOrNull;
    final isLoggedIn = user != null;

    final isOnSplash = path == AppRoutes.splash;
    final isOnAuthFlow = path == AppRoutes.login ||
        path == AppRoutes.register ||
        path == AppRoutes.forgotPassword;
    final isOnOnboardingFlow =
        path == AppRoutes.onboarding || path == AppRoutes.birthDate;

    // ── Onboarding gate (applies to both guests and logged-in) ───
    // If user hasn't completed onboarding, only allow onboarding screens.
    if (!_isOnboarded && !isOnSplash && !isOnAuthFlow && !isOnOnboardingFlow) {
      return AppRoutes.onboarding;
    }

    // ── Freemium gate: restricted routes require login ────────────
    if (_isOnboarded && !isLoggedIn && AppRoutes.isRestricted(path)) {
      return AppRoutes.login;
    }

    // ── Already authenticated → skip auth/onboarding screens ─────
    if (isLoggedIn && _isOnboarded) {
      if (isOnSplash || isOnAuthFlow || isOnOnboardingFlow) {
        return AppRoutes.home;
      }
    }

    // ── Onboarded guest on splash → go home ──────────────────────
    if (!isLoggedIn && _isOnboarded && isOnSplash) {
      return AppRoutes.home;
    }

    return null;
  }
}

final _routerNotifierProvider =
    ChangeNotifierProvider<_RouterNotifier>((ref) => _RouterNotifier(ref));

// ── GoRouter Provider ─────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  final router = GoRouter(
    navigatorKey: NavigationService.navigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // ── Auth ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Onboarding ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.birthDate,
        builder: (context, state) => const BirthDateScreen(),
      ),

      // ── Daily check-in (full-screen, no shell) ──────────────────
      GoRoute(
        path: AppRoutes.checkin,
        builder: (context, state) => const DailyCheckinScreen(),
      ),

      // ── Main shell (bottom nav) ──────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.prayer,
            builder: (context, state) => const PrayerScreen(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) => const PrayerDetailScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.vow,
            builder: (context, state) => const VowTrackerScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddVowScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.fortune,
            builder: (context, state) => const FortuneScreen(),
          ),
          GoRoute(
            path: AppRoutes.donation,
            builder: (context, state) => const DonationScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );

  NavigationService.setRouter(router);
  return router;
});
