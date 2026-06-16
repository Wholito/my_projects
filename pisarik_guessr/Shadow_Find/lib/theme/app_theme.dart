import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color softRed = Color(0xFFE07A7A);
  static const Color softRedDim = Color(0xFFB85C5C);
  static const Color black = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF161616);
  static const Color surfaceElevated = Color(0xFF222020);
  static const Color outline = Color(0xFF3D3232);

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: softRed,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF3D2424),
      onPrimaryContainer: Color(0xFFFFD6D6),
      secondary: softRedDim,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF2E1C1C),
      onSecondaryContainer: Color(0xFFF0C8C8),
      tertiary: Color(0xFF8B6B6B),
      onTertiary: Colors.white,
      error: Color(0xFFFF8A80),
      onError: Colors.black,
      surface: surface,
      onSurface: Color(0xFFF2EAEA),
      onSurfaceVariant: Color(0xFFB8A8A8),
      outline: outline,
      outlineVariant: Color(0xFF2E2828),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFF2EAEA),
      onInverseSurface: black,
      inversePrimary: softRedDim,
      surfaceTint: softRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: black,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Color(0xFFF2EAEA),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outline, width: 0.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: softRed.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? softRed : const Color(0xFF9A8888),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? softRed : const Color(0xFF9A8888),
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.primaryContainer.withValues(alpha: 0.6),
        labelStyle: const TextStyle(color: Color(0xFFFFD6D6)),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: softRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: softRed, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFFB8A8A8)),
      ),
      dividerTheme: const DividerThemeData(color: outline),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(color: Color(0xFFF2EAEA)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Color scoreColor(int score) {
    if (score >= 4000) return const Color(0xFF81C784);
    if (score >= 2000) return const Color(0xFFE0A060);
    return softRed;
  }
}
