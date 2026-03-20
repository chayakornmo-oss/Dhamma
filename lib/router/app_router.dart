import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const birthDate = '/birth-date';
  static const checkin = '/checkin';
  static const home = '/home';
  static const vow = '/vow';
  static const addVow = '/add-vow';
  static const fortune = '/fortune';
  static const prayer = '/prayer';
  static const prayerDetail = '/prayer-detail';
  static const donation = '/donation';
  static const profile = '/profile';
}

final appRouterProvider = Provider.family<GoRouter, ({bool isOnboarded, bool isLoggedIn})>((ref, args) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.birthDate,
        builder: (context, state) => const BirthDateScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkin,
        builder: (context, state) => const DailyCheckinScreen(),
      ),
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
            ]
          ),
          GoRoute(
            path: AppRoutes.vow,
            builder: (context, state) => const VowTrackerScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddVowScreen(),
              ),
            ]
          ),
          GoRoute(
            path: AppRoutes.fortune,
            builder: (context, state) => const FortuneScreen(),
          ),
redirect: (context, state) {
      // 1. ถ้าเพิ่งเข้าแอป (หน้า splash) แต่ข้อมูลพร้อมแล้ว ให้พาไป Onboarding
      if (state.uri.path == AppRoutes.splash) {
        if (!args.isOnboarded) {
           return AppRoutes.onboarding;
        } else {
           // ถ้าเคยผ่าน Onboarding แล้ว ก็ข้ามไปหน้า Home เลย
           return AppRoutes.home;
        }
      }

      // 2. ถ้ายังไม่ผ่าน Onboarding ห้ามแอบเข้าหน้าอื่น
      if (!args.isOnboarded && state.uri.path != AppRoutes.onboarding && state.uri.path != AppRoutes.birthDate) {
        return AppRoutes.onboarding; 
      }
      
      return null;
    },
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if (!args.isOnboarded && state.uri.path != AppRoutes.splash && state.uri.path != AppRoutes.onboarding && state.uri.path != AppRoutes.birthDate) {
        return AppRoutes.onboarding; // Temporary
      }
      return null;
    },
  );
});
