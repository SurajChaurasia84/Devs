import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Blue Color
  static const Color primaryBlue = Color(0xFF1D9BF0);

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF000000);
  static const Color darkCard = Color(0xFF0A0A0A);
  static const Color darkBorder = Color(0xFF222222);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);

  // Light Theme Colors
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8F9FA);
  static const Color lightBorder = Color(0xFFEFF3F4);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF606060);

  // General Gray Colors
  static const Color grayActive = Color(0xFF536471);
  static const Color grayBorder = Color(0xFFCCCCCC);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      dividerColor: darkBorder,
      primaryColor: primaryBlue,
      hintColor: darkTextSecondary,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryBlue,
        background: darkBg,
        surface: darkCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: darkTextPrimary,
        onSurface: darkTextPrimary,
        outline: darkBorder,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.inter(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.inter(
          color: darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: darkTextPrimary,
          fontSize: 15,
        ),
        bodyMedium: GoogleFonts.inter(
          color: darkTextSecondary,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.inter(
          color: darkTextPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBg,
        selectedItemColor: primaryBlue,
        unselectedItemColor: darkTextSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightCard,
      dividerColor: lightBorder,
      primaryColor: primaryBlue,
      hintColor: lightTextSecondary,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryBlue,
        background: lightBg,
        surface: lightCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: lightTextPrimary,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        titleLarge: GoogleFonts.inter(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.inter(
          color: lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: lightTextPrimary,
          fontSize: 15,
        ),
        bodyMedium: GoogleFonts.inter(
          color: lightTextSecondary,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.inter(
          color: lightTextPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightBg,
        selectedItemColor: primaryBlue,
        unselectedItemColor: lightTextSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
