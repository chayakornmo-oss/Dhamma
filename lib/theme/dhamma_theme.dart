import 'package:flutter/material.dart';

class DhammaTheme {
  static const Color primaryNavy = Color(0xFF0F0A1E);
  static const Color primaryGold = Color(0xFFC8912E);
  static const Color lightGold = Color(0xFFE8B84B);
  static const Color surfaceCream = Color(0xFFFAF6EE);
  static const Color darkGreen = Color(0xFF1B3D2F);
  static const Color urgentRed = Color(0xFF8B0000);
  
  // Colors used in provided screens
  static const Color ink = Color(0xFF0F0A1E);
  static const Color gold = Color(0xFFC8912E);
  static const Color gold2 = Color(0xFFE8B84B);
  static const Color goldPale = Color(0xFFFDF3DC);
  static const Color textLight = Color(0xFFAAAAAA);
  static const Color textMid = Color(0xFF888888);
  static const Color textDark = Color(0xFF333333);
  static const Color lotus = Color(0xFF8B0000);
  static const Color sage = Color(0xFF7BC47B);
  
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryNavy,
      primaryColor: primaryGold,
      fontFamily: 'Sarabun',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: 'NotoSerifThai', color: primaryGold, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontFamily: 'NotoSerifThai', color: surfaceCream, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: 'NotoSerifThai', color: surfaceCream, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: surfaceCream),
        bodyMedium: TextStyle(color: surfaceCream),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: lightGold,
        surface: Color(0xFF1A1528),
        onPrimary: primaryNavy,
        onSurface: surfaceCream,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryGold),
        titleTextStyle: TextStyle(fontFamily: 'NotoSerifThai', color: primaryGold, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF120C24),
        selectedItemColor: primaryGold,
        unselectedItemColor: Colors.grey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: primaryNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
