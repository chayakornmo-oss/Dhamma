import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/log_service.dart';

// ── Temporary Onboarding Input ─────────────────────────────────────
/// Holds in-progress data as the user moves through the onboarding flow.
/// Cleared after the profile is saved to Firestore.
class OnboardingInput {
  final String name;
  final List<String> goals;

  const OnboardingInput({required this.name, required this.goals});
}

final onboardingInputProvider =
    StateProvider<OnboardingInput>((ref) => const OnboardingInput(name: '', goals: []));

// ── Auth State ───────────────────────────────────────────────────────
/// Streams Firebase auth changes. Sets the Crashlytics / Analytics
/// user identifier whenever the auth state settles on a logged-in user.
final authStateStreamProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges.asyncMap((user) async {
    if (user != null) {
      await LogService.setUser(user.uid);
    } else {
      await LogService.clearUser();
    }
    return user;
  });
});

// ── Onboarding State ─────────────────────────────────────────────────
class OnboardingNotifier extends AsyncNotifier<bool> {
  static const _key = 'is_onboarded';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = const AsyncValue.data(true);
    LogService.info('onboarding completed');
  }
}

final onboardingProvider =
    AsyncNotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

// ── User Profile ─────────────────────────────────────────────────────
/// Streams the Firestore user document for the currently signed-in user.
/// Automatically re-evaluates when auth state changes.
final userProfileProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final authAsync = ref.watch(authStateStreamProvider);
  return authAsync.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(firestoreServiceProvider).getUserProfile(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ── User Display Name ─────────────────────────────────────────────────
/// Convenience provider — returns the user's Thai name or a fallback.
final userNameProvider = Provider.autoDispose<String>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return profile?.name ?? 'คุณ';
});

// ── User Streak ───────────────────────────────────────────────────────
final userStreakProvider = Provider.autoDispose<int>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return profile?.streakDays ?? 0;
});

// ── Premium Status ────────────────────────────────────────────────────
final isPremiumProvider = Provider.autoDispose<bool>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  return profile?.isPremium ?? false;
});
