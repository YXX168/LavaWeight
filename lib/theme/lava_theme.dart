import 'package:flutter/material.dart';

class LavaTheme {
  static const background = Color(0xFF16071D);
  static const backgroundAubergine = Color(0xFF281330);
  static const lavaPink = Color(0xFFF4ABE5);
  static const lavaPeach = Color(0xFFFFB2C4);
  static const lavaOrange = Color(0xFFFF9B76);
  static const textPrimary = Color(0xFFFCF2FC);
  static const textSecondary = Color(0xFFD9BDD9);
  static const textMuted = Color(0xFFB09AB6);
  static const glassFill = Color(0x243D2046);
  static const glassBorder = Color(0x559E6AA7);
  static const glassBorderSubtle = Color(0x338E6A99);
  static const success = lavaPink;
  static const warning = lavaPeach;
  static const buttonGlowShadow = [
    BoxShadow(color: Color(0x337F235F), blurRadius: 24, offset: Offset(0, 5)),
  ];
  static const cardShadow = [
    BoxShadow(color: Color(0x19000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const chartFillGradient = LinearGradient(
    colors: [Color(0x30F4ABE5), Color(0x00F4ABE5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: lavaPink,
      secondary: lavaPeach,
      surface: backgroundAubergine,
      onPrimary: background,
      onSurface: textPrimary,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
      bodySmall: TextStyle(color: textSecondary, fontSize: 12),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0x25281530),
      border: OutlineInputBorder(borderSide: BorderSide(color: glassBorder)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: backgroundAubergine,
      contentTextStyle: TextStyle(color: textPrimary),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
