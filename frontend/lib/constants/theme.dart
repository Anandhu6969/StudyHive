import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF000000);
  static const Color surfaceCard = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF2A2A2A);
  static const Color surfaceInput = Color(0xFF1E1E1E);

  // Gradient colors (purple → cyan)
  static const Color gradientStart = Color(0xFFCC44FF);
  static const Color gradientEnd = Color(0xFF00CCFF);

  // Keep these for any legacy references
  static const Color primaryBlue = Color(0xFFCC44FF);
  static const Color lightBlue = Color(0xFF00CCFF);
  static const Color darkBlue = Color(0xFF9900CC);
  static const Color accentOrange = Color(0xFFCC44FF);
  static const Color lightOrange = Color(0xFF00CCFF);
  static const Color darkOrange = Color(0xFF9900CC);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textHint = Color(0xFF555555);

  // Semantic
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFD740);

  // Main gradient (purple → cyan)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // All gradient references unified to purple→cyan
  static const LinearGradient accentGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient blueOrangeGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Avatar gradient (purple → blue)
  static const LinearGradient avatarGradient = LinearGradient(
    colors: [Color(0xFF9C44FF), Color(0xFF44AAFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.gradientStart,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gradientStart,
        secondary: AppColors.gradientEnd,
        surface: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textHint),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.gradientStart, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIconColor: AppColors.textHint,
        suffixIconColor: AppColors.textHint,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gradientStart,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.gradientStart,
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceElevated,
        thickness: 1,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.gradientStart,
        unselectedLabelColor: AppColors.textHint,
        indicatorColor: AppColors.gradientStart,
      ),
    );
  }
}