import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central accessor for all environment variables.
/// Throws [StateError] if a required key is missing, so misconfiguration
/// surfaces immediately at startup rather than silently at runtime.
class AppEnv {
  AppEnv._();

  static Future<void> load() async {
    await dotenv.load(fileName: 'env.txt');
  }

  // ── Firebase Web ─────────────────────────────────────────────────
  static String get firebaseWebApiKey =>
      _require('FIREBASE_WEB_API_KEY');

  static String get firebaseWebAppId =>
      _require('FIREBASE_WEB_APP_ID');

  static String get firebaseWebMessagingSenderId =>
      _require('FIREBASE_WEB_MESSAGING_SENDER_ID');

  static String get firebaseWebProjectId =>
      _require('FIREBASE_WEB_PROJECT_ID');

  static String get firebaseWebStorageBucket =>
      _require('FIREBASE_WEB_STORAGE_BUCKET');

  static String get firebaseWebAuthDomain =>
      _require('FIREBASE_WEB_AUTH_DOMAIN');

  // ── AI Service ───────────────────────────────────────────────────
  static String get aiServiceBaseUrl =>
      dotenv.env['AI_SERVICE_BASE_URL'] ??
      'https://api.dhamma-plus.app/api/ai';

  // ── Internal ──────────────────────────────────────────────────────
  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required environment variable: $key\n'
        'Please add it to your env.txt file.',
      );
    }
    return value;
  }
}
