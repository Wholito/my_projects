import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkWarm {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFB347), // золотистый акцент
        brightness: Brightness.dark,
        primary: const Color(0xFFFFB347),      // яркий жёлтый
        secondary: const Color(0xFFFF8C42),    // оранжевый
        tertiary: const Color(0xFFFF6B6B),     // красный
        surface: const Color(0xFF1E1A15),      // тёмный тёплый серый
      ),
      scaffoldBackgroundColor: const Color(0xFF12100E), // очень тёмный фон
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: const Color(0xFFF5E6D3),
        displayColor: const Color(0xFFFFF0E0),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1E1A15), // совпадает с surface
        titleTextStyle: TextStyle(
          color: Color(0xFFFFB347),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Color(0xFFFFB347)),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF25201A), // чуть светлее фона для глубины
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A241E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Color(0xFFE6B87E)),
        labelStyle: const TextStyle(color: Color(0xFFFFB347)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8C42),
          foregroundColor: const Color(0xFF12100E),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFFB347),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1A15),
        selectedItemColor: Color(0xFFFFB347),
        unselectedItemColor: Color(0xFFE6B87E),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFFFFB347),
      ),
    );
  }
}