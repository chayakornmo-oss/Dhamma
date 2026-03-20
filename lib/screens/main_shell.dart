import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/dhamma_theme.dart';
import '../router/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: DhammaTheme.ink,
        selectedItemColor: DhammaTheme.gold,
        unselectedItemColor: Colors.white30,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        items: const [
          BottomNavigationBarItem(icon: Text('🏠'), label: 'หน้าหลัก'),
          BottomNavigationBarItem(icon: Text('📿'), label: 'บทสวด'),
          BottomNavigationBarItem(icon: Text('📍'), label: 'ขอพร'),
          BottomNavigationBarItem(icon: Text('✨'), label: 'ดวง'),
          BottomNavigationBarItem(icon: Text('💚'), label: 'บริจาค'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/prayer')) return 1;
    if (location.startsWith('/vow')) return 2;
    if (location.startsWith('/fortune')) return 3;
    if (location.startsWith('/donation')) return 4;
    return 0; // Default Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go(AppRoutes.home); break;
      case 1: context.go(AppRoutes.prayer); break;
      case 2: context.go(AppRoutes.vow); break;
      case 3: context.go(AppRoutes.fortune); break;
      case 4: context.go(AppRoutes.donation); break;
    }
  }
}
