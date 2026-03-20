import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Holds a reference to the GoRouter so that services outside the widget tree
/// (e.g. NotificationService static callbacks) can trigger navigation.
class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'dhamma_root');

  static GoRouter? _router;

  static void setRouter(GoRouter router) {
    _router = router;
  }

  /// Navigate to [path] using the app's GoRouter instance.
  /// Falls back to [Navigator] push if router is not yet attached.
  static void goTo(String path) {
    if (_router != null) {
      _router!.go(path);
    } else {
      final context = navigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).go(path);
      }
    }
  }
}
