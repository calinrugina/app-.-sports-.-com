import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      // Fundal principal deschis (din paleta AppColors.smoke sau white)
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        // Folosim Black pentru AppBar în ambele teme, conform imaginii
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.light(
        // Roșu principal ca culoare primară
        primary: AppColors.primaryRed,
        // O nuanță de gri pentru secundar sau un alt accent
        secondary: AppColors.gray60,
        // Alb pentru fundalul cardurilor/suprafețelor
        background: AppColors.white,
        surface: AppColors.white,
        // Albastru pentru focus/selecție, roșu pentru erori
        error: AppColors.errorRed,
      ),
      // Setări pentru text (exemplu: textul principal ar fi primaryBlack)
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.primaryBlack),
        // Aici ar trebui definite și stilurile de font din imagini, dar e complex
      ),
      // Stilul pentru butoane (dedus din imagini)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0), // Colțuri ușor rotunjite
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      // Stilul pentru Input Fields (dedus din imagini)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.smoke,
        hintStyle: TextStyle(color: AppColors.gray60),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(color: AppColors.focusBlue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2.0),
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      // Fundal principal întunecat (din paleta AppColors.headerNav sau primaryBlack)
      scaffoldBackgroundColor: AppColors.headerNav,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        // Roșu principal ca culoare primară
        primary: AppColors.primaryRed,
        // Alb ca secundar pentru contrast
        secondary: AppColors.white,
        // Negru primar pentru fundalul cardurilor/suprafețelor
        background: AppColors.primaryBlack,
        surface: AppColors.primaryBlack,
        error: AppColors.errorRed,
      ),
      // Setări pentru text (exemplu: textul principal ar fi white)
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.white),
      ),
      // Stilul pentru butoane (similar cu cel light, dar fundalul pentru Primary ar fi același)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      // Stilul pentru Input Fields (dedus din imagini)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkTabs, // O culoare mai deschisă ca fundal de input
        hintStyle: TextStyle(color: AppColors.gray60),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(color: AppColors.focusBlue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2.0),
        ),
      ),
      useMaterial3: true,
    );
  }
}
