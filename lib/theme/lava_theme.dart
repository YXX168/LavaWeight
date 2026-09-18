import 'dart:ui';
import 'package:flutter/material.dart';

class LavaTheme {
  // Brand & Background Colors
  static const Color background = Color(0xFF13071A);
  static const Color backgroundAubergine = Color(0xFF1A0B22);
  static const Color backgroundCard = Color(0x382A0F38);

  // Lava Glow Accents
  static const Color lavaOrange = Color(0xFFFF6D3B);
  static const Color lavaPeach = Color(0xFFFF9E79);
  static const Color lavaPink = Color(0xFFFF2A85);
  static const Color lavaMagenta = Color(0xFFBA1B7A);
  static const Color lavaViolet = Color(0xFF8B2FC9);

  // Glassmorphic Accents
  static const Color glassBorder = Color(0x40FF6BB3);
  static const Color glassBorderSubtle = Color(0x22FFFFFF);
  static const Color glassFill = Color(0x2E240B30);
  static const Color glassHighlight = Color(0x1FFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD6C8E0);
  static const Color textMuted = Color(0xFF8F80A0);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);

  // Linear Gradients
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFFFF2A85), Color(0xFFFF6D3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x30FF2A85), Color(0x1013071A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient chartFillGradient = LinearGradient(
    colors: [Color(0x66FF2A85), Color(0x0513071A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static const List<BoxShadow> buttonGlowShadow = [
    BoxShadow(
      color: Color(0x66FF2A85),
      blurRadius: 18,
      spreadRadius: 1,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // ThemeData
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: lavaPink,
      colorScheme: const ColorScheme.dark(
        primary: lavaPink,
        secondary: lavaOrange,
        surface: backgroundAubergine,
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
    );
  }
}
import 'package:flutter/material.dart';

class LavaTheme {
  // Brand & Background Colors
  static const Color background = Color(0xFF13071A);
  static const Color backgroundAubergine = Color(0xFF1A0B22);
  static const Color backgroundCard = Color(0x382A0F38);

  // Lava Glow Accents
  static const Color lavaOrange = Color(0xFFFF6D3B);
  static const Color lavaPeach = Color(0xFFFF9E79);
  static const Color lavaPink = Color(0xFFFF2A85);
  static const Color lavaMagenta = Color(0xFFBA1B7A);
  static const Color lavaViolet = Color(0xFF8B2FC9);

  // Glassmorphic Accents
  static const Color glassBorder = Color(0x40FF6BB3);
  static const Color glassBorderSubtle = Color(0x22FFFFFF);
  static const Color glassFill = Color(0x2E240B30);
  static const Color glassHighlight = Color(0x1FFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD6C8E0);
  static const Color textMuted = Color(0xFF8F80A0);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);

  // Linear Gradients
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFFFF2A85), Color(0xFFFF6D3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x30FF2A85), Color(0x1013071A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient chartFillGradient = LinearGradient(
    colors: [Color(0x66FF2A85), Color(0x0513071A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static const List<BoxShadow> buttonGlowShadow = [
    BoxShadow(
      color: Color(0x66FF2A85),
      blurRadius: 18,
      spreadRadius: 1,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // ThemeData
  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: lavaPink,
      colorScheme: const ColorScheme.dark(
        primary: lavaPink,
        secondary: lavaOrange,
        surface: backgroundAubergine,
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
    );
  }
}
