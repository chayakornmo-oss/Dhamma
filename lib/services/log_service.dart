import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralised logging, analytics and crash-reporting service.
///
/// Usage:
///   LogService.info('user signed in');
///   LogService.logEvent(LogEvent.signIn, params: {'method': 'google'});
///   LogService.error(e, stack);
class LogService {
  LogService._();

  static final _analytics = FirebaseAnalytics.instance;
  static FirebaseCrashlytics? get _crashlytics =>
      kIsWeb ? null : FirebaseCrashlytics.instance;

  // ── Initialise (call after Firebase.initializeApp) ───────────────
  static Future<void> initialize() async {
    if (!kIsWeb) {
      // Enable Crashlytics only in release builds
      await _crashlytics!
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      // Catch Flutter framework errors
      FlutterError.onError =
          _crashlytics!.recordFlutterFatalError;

      // Catch async errors outside the Flutter framework
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics!.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // Disable analytics collection in debug mode to avoid polluting data
    await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);
  }

  // ── User Identity ────────────────────────────────────────────────
  static Future<void> setUser(String uid) async {
    await Future.wait([
      _analytics.setUserId(id: uid),
      if (_crashlytics != null) _crashlytics!.setUserIdentifier(uid),
    ]);
  }

  static Future<void> clearUser() async {
    await _analytics.setUserId(id: null);
  }

  // ── Screen Tracking ──────────────────────────────────────────────
  static Future<void> logScreen(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
    _log('SCREEN', screenName);
  }

  // ── Structured Events ────────────────────────────────────────────
  static Future<void> logEvent(
    String name, {
    Map<String, Object>? params,
  }) async {
    _log('EVENT', '$name ${params ?? ''}');
    await _analytics.logEvent(name: name, parameters: params);
  }

  // ── Auth Events (pre-named for Analytics dashboards) ─────────────
  static Future<void> logSignIn(String method) async {
    _log('AUTH', 'sign_in method=$method');
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp(String method) async {
    _log('AUTH', 'sign_up method=$method');
    await _analytics.logSignUp(signUpMethod: method);
  }

  static Future<void> logSignOut() async {
    _log('AUTH', 'sign_out');
    await logEvent('sign_out');
    await clearUser();
  }

  // ── Business Events ──────────────────────────────────────────────
  static Future<void> logCheckin(String mood) async =>
      logEvent('daily_checkin', params: {'mood': mood});

  static Future<void> logVowAdded(String templeName) async =>
      logEvent('vow_added', params: {'temple': templeName});

  static Future<void> logDonation(double amount, String orgName) async =>
      logEvent('donation_made',
          params: {'amount': amount.toInt(), 'org': orgName});

  static Future<void> logPremiumUpgradeTap() async =>
      logEvent('premium_upgrade_tapped');

  // ── Error & Warning ──────────────────────────────────────────────
  static void info(String message) => _log('INFO', message);

  static void warning(String message) {
    _log('WARN', message);
    _crashlytics?.log('[WARN] $message');
  }

  static Future<void> error(
    Object error,
    StackTrace stack, {
    bool fatal = false,
    String? context,
  }) async {
    _log('ERROR', '${context != null ? "[$context] " : ""}$error');
    await _crashlytics?.recordError(
      error,
      stack,
      fatal: fatal,
      reason: context,
    );
  }

  // ── Internal ──────────────────────────────────────────────────────
  static void _log(String level, String message) {
    if (kDebugMode) {
      debugPrint('[${level.padRight(5)}] $message');
    }
  }
}

/// Named events to avoid typos across the codebase.
class LogEvent {
  static const signIn = 'sign_in';
  static const signUp = 'sign_up';
  static const signOut = 'sign_out';
  static const checkin = 'daily_checkin';
  static const vowAdded = 'vow_added';
  static const vowUpdated = 'vow_updated';
  static const prayerViewed = 'prayer_viewed';
  static const fortuneViewed = 'fortune_viewed';
  static const donationMade = 'donation_made';
  static const premiumTapped = 'premium_upgrade_tapped';
  static const notificationTapped = 'notification_tapped';
  static const passwordReset = 'password_reset_sent';
}
