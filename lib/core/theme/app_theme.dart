import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores fijos que no cambian entre temas
class AppColors {
  // Primary
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF7C3AED);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Book status
  static const Color statusPending = Color(0xFF6B7280);
  static const Color statusReading = Color(0xFF3B82F6);
  static const Color statusCompleted = Color(0xFF22C55E);

  // Rating
  static const Color starActive = Color(0xFFFBBF24);
}

/// Temas de la app
class AppTheme {
  /// Tema oscuro
  static final ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    background: const Color(0xFF0F0F0F),
    surface: const Color(0xFF1A1A1A),
    surfaceContainer: const Color(0xFF262626),
    textPrimary: const Color(0xFFF5F5F5),
    textSecondary: const Color(0xFFA3A3A3),
    textMuted: const Color(0xFF737373),
    starInactive: const Color(0xFF404040),
  );

  /// Tema claro
  static final ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    background: const Color(0xFFFAFAFA),
    surface: const Color(0xFFFFFFFF),
    surfaceContainer: const Color(0xFFF3F4F6),
    textPrimary: const Color(0xFF111827),
    textSecondary: const Color(0xFF4B5563),
    textMuted: const Color(0xFF9CA3AF),
    starInactive: const Color(0xFFD1D5DB),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceContainer,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required Color starInactive,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      onPrimaryContainer: Colors.white,
      secondary: isDark ? AppColors.primaryLight : AppColors.primaryDark,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceContainer,
      outline: textMuted,
      outlineVariant: starInactive,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: _buildTextTheme(textPrimary, textSecondary, textMuted),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainer,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceContainer : textPrimary,
        contentTextStyle: GoogleFonts.inter(color: isDark ? textPrimary : surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary, Color muted) {
    return TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.bold, color: primary,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28, fontWeight: FontWeight.bold, color: primary,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w600, color: primary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w700, color: primary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, color: primary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, color: primary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: primary,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: primary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: secondary),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: muted),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, color: primary,
      ),
    );
  }
}
