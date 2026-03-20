import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router/app_router.dart';
import 'theme/dhamma_theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Firebase init
  try {
    await Firebase.initializeApp(
      options: kIsWeb
          ? const FirebaseOptions(
              apiKey: 'demo-api-key',
              appId: '1:000000000000:web:0000000000000000000000',
              messagingSenderId: '000000000000',
              projectId: 'demo-project',
            )
          : null,
    );
  } catch (_) {}

  // Notifications init (not supported on web)
  if (!kIsWeb) {
    await NotificationService.initialize();
  }

  // Check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final isOnboarded = prefs.getBool('is_onboarded') ?? false;
  final isLoggedIn = prefs.getString('user_id') != null;

  runApp(
    ProviderScope(
      child: DhammaPlusApp(
        isOnboarded: isOnboarded,
        isLoggedIn: isLoggedIn,
      ),
    ),
  );
}

class DhammaPlusApp extends ConsumerWidget {
  final bool isOnboarded;
  final bool isLoggedIn;

  const DhammaPlusApp({
    super.key,
    required this.isOnboarded,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ธรรมะ+',
      debugShowCheckedModeBanner: false,
      theme: DhammaTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
    );
  }
}
