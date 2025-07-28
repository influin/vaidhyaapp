import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors from logo
  static const Color primaryBlue = Color(0xFF0037E0);       // Dark blue from logo
  static const Color lightBlue = Color(0xFF64B5F6);         // Light blue from logo
  static const Color primaryGreen = Color(0xFF0DB801);      // Dark green from logo
  static const Color lightGreen = Color(0xFF76FF03);        // Light green from logo
  
  // Additional colors
  static const Color white = Colors.white;
  static const Color black = Colors.black87;
  static const Color grey = Colors.grey;
  static const Color lightGrey = Color(0xFFEEEEEE);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  
  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryGreen,
        surface: white,
        background: lightGrey,
        error: Colors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: white,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryGreen,
        surface: darkSurface,
        background: darkBackground,
        error: Colors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkTextPrimary),
        bodyMedium: TextStyle(color: darkTextSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: darkSurface,
      ),
    );
  }
}