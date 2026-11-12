import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.midnightNavy,
      primaryColor: AppColors.premiumGold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.premiumGold,
        secondary: AppColors.lightGold,
        surface: AppColors.deepNavy,
        background: AppColors.midnightNavy,
        error: AppColors.error,
        onPrimary: AppColors.midnightNavy,
        onSecondary: AppColors.midnightNavy,
        onSurface: AppColors.pureWhite,
        onBackground: AppColors.pureWhite,
        onError: AppColors.pureWhite,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.pureWhite,
            letterSpacing: -0.5,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            color: AppColors.pureWhite,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            color: AppColors.mutedGrey,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.midnightNavy,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.premiumGold),
        titleTextStyle: TextStyle(
          color: AppColors.pureWhite,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.deepNavy,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderGrey, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.midnightNavy,
        selectedItemColor: AppColors.premiumGold,
        unselectedItemColor: AppColors.mutedGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.deepNavy,
        hintStyle: const TextStyle(color: AppColors.mutedGrey, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.premiumGold, width: 1.5),
        ),
      ),
    );
  }
}
