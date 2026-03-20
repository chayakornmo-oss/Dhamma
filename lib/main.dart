import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_env.dart';
import 'router/app_router.dart';
import 'services/log_service.dart';
import 'services/notification_service.dart';
import 'theme/dhamma_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Orientation ──────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ── Environment Variables ────────────────────────────────────────
  await AppEnv.load();

  // ── Firebase ─────────────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      options: kIsWeb
          ? FirebaseOptions(
              apiKey: AppEnv.firebaseWebApiKey,
              appId: AppEnv.firebaseWebAppId,
              messagingSenderId: AppEnv.firebaseWebMessagingSenderId,
              projectId: AppEnv.firebaseWebProjectId,
              storageBucket: AppEnv.firebaseWebStorageBucket,
              authDomain: AppEnv.firebaseWebAuthDomain,
            )
          : null,
    );
  } on FirebaseException catch (e) {
    debugPrint('[Firebase] Initialization failed: ${e.message}');
    runApp(_FirebaseErrorApp(
        message: e.message ?? 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้'));
    return;
  } catch (e) {
    debugPrint('[Firebase] Unexpected init error: $e');
  }

  // ── Firestore offline persistence ────────────────────────────────
  // Keeps a local cache so the app works without internet and shows
  // stale data gracefully while re-fetching from the network.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // ── Logging / Crashlytics / Analytics ────────────────────────────
  await LogService.initialize();

  // ── Notifications (mobile only) ───────────────────────────────────
  if (!kIsWeb) {
    await NotificationService.initialize();
  }

  runApp(const ProviderScope(child: DhammaPlusApp()));
}

class DhammaPlusApp extends ConsumerWidget {
  const DhammaPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ธรรมะ+',
      debugShowCheckedModeBanner: false,
      theme: DhammaTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        final mediaData = MediaQuery.of(context);
        final clamped = mediaData.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: mediaData.copyWith(textScaler: clamped),
          child: child!,
        );
      },
    );
  }
}

// ── Fatal Firebase Error Screen ───────────────────────────────────────
class _FirebaseErrorApp extends StatelessWidget {
  final String message;
  const _FirebaseErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: DhammaTheme.ink,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪷', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 24),
                const Text(
                  'ไม่สามารถเริ่มต้นแอปได้',
                  style: TextStyle(
                    color: DhammaTheme.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
