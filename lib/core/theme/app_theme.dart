import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  // Am redenumit light() în lightTheme()
  static ThemeData lightTheme() {
    const defaultFont = 'Roboto';
    final baseTextTheme = AppTextStyles.lightTextTheme(defaultFont);

    return ThemeData(
      fontFamily: defaultFont,
      textTheme: baseTextTheme.apply(
        displayColor: AppColors.lightTextPrimary,
        bodyColor: AppColors.lightTextPrimary,
      ),
      brightness: Brightness.light,
      cardTheme: const CardThemeData(
        color: AppColors.white
      ),
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryRed,
        secondary: AppColors.gray60,
        background: AppColors.white,
        surface: AppColors.white,
        error: AppColors.errorRed,
      ),
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.smoke,
        hintStyle: TextStyle(color: AppColors.gray60, fontFamily:  defaultFont, fontSize: 11),
        labelStyle: TextStyle(color: AppColors.gray60, fontFamily:  defaultFont, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(color: AppColors.gray60, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2.0),
        ),
      ),
      useMaterial3: true,
    );
  }

  // Am redenumit dark() în darkTheme()
  static ThemeData darkTheme() {
    const defaultFont = 'Roboto';
    final baseTextTheme = AppTextStyles.darkTextTheme(defaultFont);

    return ThemeData(
      fontFamily: defaultFont,
      textTheme: baseTextTheme.apply(
        displayColor: AppColors.darkTextPrimary,
        bodyColor: AppColors.darkTextPrimary,
      ),
      brightness: Brightness.dark,
      cardTheme: const CardThemeData(
          color: Colors.black
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryRed,
        secondary: AppColors.white,
        background: AppColors.primaryBlack,
        surface: AppColors.primaryBlack,
        error: AppColors.errorRed,
      ),
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkTabs,
        hintStyle: TextStyle(color: AppColors.gray60, fontFamily:  defaultFont, fontSize: 11),
        labelStyle: TextStyle(color: AppColors.gray60, fontFamily:  defaultFont, fontSize: 12),
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
class AppTextStyles {
  // Styles pentru tema LIGHT
  static TextTheme lightTextTheme(String? fontFamily) {
    return TextTheme(
      // 1. sectionTitle (Bebas Neue, ajustat de la 20 la 18 pentru dispozitive mici)
      headlineLarge: const TextStyle(
        fontFamily:  'Bebas Neue',
        fontSize: 20.0, // AJUSTAT PENTRU ECRANE MICI
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextPrimary,
        letterSpacing: -0.1,
      ),

      // 2. itemTitle (Bebas Neue, 18px)
      titleLarge: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 16,
        fontWeight: FontWeight.w100,
        color: AppColors.lightTextPrimary,
        letterSpacing: -0.2,
        // height: 1,
      ),

      // 3. itemDescription (bodyMedium - Condensat)
      bodyMedium: TextStyle(
        fontFamily:  fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: AppColors.lightTextPrimary,
        height: 1.1,
        letterSpacing: -0.3, // CONDENSARE
      ),

      // 4. itemDate (labelSmall)
      labelSmall: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.gray20,
        // letterSpacing: 0.5,
        height: .9,
      ),
    );
  }

  // Styles pentru tema DARK
  static TextTheme darkTextTheme(String? fontFamily) {
    return TextTheme(
      // 1. sectionTitle
      headlineLarge: const TextStyle(
        fontFamily:  'Bebas Neue',
        fontSize: 20.0, // AJUSTAT PENTRU ECRANE MICI
        fontWeight: FontWeight.w400,
        color: AppColors.white,
        letterSpacing: -0.1,
      ),

      // 2. itemTitle
      titleLarge: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 16,
        fontWeight: FontWeight.w100,
        color: AppColors.darkTextPrimary,
        letterSpacing: -0.2,
        // height: 1,
      ),

      // 3. itemDescription (bodyMedium - Condensat)
      bodyMedium: TextStyle(
        fontFamily:  fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: AppColors.darkTextPrimary,
        height: 1.1,
        letterSpacing: -0.3, // CONDENSARE
      ),

      // 4. itemDate
      labelSmall: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.gray20,
        // letterSpacing: 0.5,
        height: .9,
      ),
    );
  }
}