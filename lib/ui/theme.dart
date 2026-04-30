import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color obsidian = Color(0xFF0A0A0A);
  static const Color deepCharcoal = Color(0xFF1A1A1A);
  static const Color champagneGold = Color(0xFFD4AF37);
  static const Color softGold = Color(0xFFFFD700);
  static const Color boardDark = Color(0xFF2C2C2C);
  static const Color boardLight = Color(0xFFE0E0E0);
  static const Color glassWhite = Color(0x1AFFFFFF);

  static Map<String, List<Color>> get boardThemes => {
    'obsidian': [boardLight, boardDark],
    'classic': [const Color(0xFFEEEED2), const Color(0xFF769656)],
    'ocean': [const Color(0xFFE1EEF6), const Color(0xFF4A7397)],
    'wood': [const Color(0xFFF0D9B5), const Color(0xFFB58863)],
  };

  static Color getLightSquare(String theme) {
    return boardThemes[theme]?[0] ?? boardLight;
  }

  static Color getDarkSquare(String theme) {
    return boardThemes[theme]?[1] ?? boardDark;
  }

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: obsidian,
    primaryColor: champagneGold,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      color: deepCharcoal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    ),
  );
}
