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
        // bodyColor: AppColors.lightTextPrimary,
      ),
      brightness: Brightness.light,
      cardTheme: const CardThemeData(color: AppColors.white),
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
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.gray100,
        foregroundColor: AppColors.gray100,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
      )),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.smoke,
        // MODIFICAT: Setează culoarea hint/label la negru
        hintStyle: const TextStyle(color: AppColors.primaryBlack, fontSize: 16),
        labelStyle: const TextStyle(color: AppColors.primaryBlack, fontSize: 16),
        // Padding vertical crescut pentru a face câmpul mai înalt
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // Colțuri mai rotunjite (8.0)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        // Definirea explicită a enabledBorder pentru a arăta stilul default (fără chenar)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        // Focused border (chenar albastru conform imaginii)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.focusBlue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
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
        // bodyColor: AppColors.darkTextPrimary,
      ),
      brightness: Brightness.dark,
      dividerTheme: const DividerThemeData(color: Colors.black),
      cardTheme: const CardThemeData(color: Colors.black),
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
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.gray100,
            foregroundColor: AppColors.gray100,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            side: const BorderSide(
              color: AppColors.gray100,
              width: 0
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),

            ),
          )),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkTabs, // Culoare de umplere mai închisă
        hintStyle: const TextStyle(color: AppColors.gray60, fontSize: 16),
        labelStyle: const TextStyle(color: AppColors.gray60, fontSize: 16),
        // Padding vertical crescut pentru a face câmpul mai înalt
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // Colțuri mai rotunjite (8.0)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        // Definirea explicită a enabledBorder pentru a arăta stilul default (fără chenar)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        // Focused border (chenar albastru conform imaginii)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.focusBlue, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
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
        fontFamily: 'Bebas Neue',
        fontSize: 22.0, // AJUSTAT PENTRU ECRANE MICI
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextPrimary,
        letterSpacing: 0.2,
      ),

      // 2. itemTitle (Bebas Neue, 18px)
      titleLarge: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 16,
        fontWeight: FontWeight.w100,
        color: AppColors.lightTextPrimary,
        letterSpacing: 0.1,
        // height: 1,
      ),

      // 3. itemDescription (bodyMedium - Condensat)
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: AppColors.lightTextPrimary,
        height: 1.2,
        letterSpacing: -0.1, // CONDENSARE
      ),

      // 4. itemDate (labelSmall)
      labelSmall: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.gray60,
        // letterSpacing: 0.5,
        height: 1,
      ),
    );
  }

  // Styles pentru tema DARK
  static TextTheme darkTextTheme(String? fontFamily) {
    return TextTheme(
      // 1. sectionTitle
      headlineLarge: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 22.0, // AJUSTAT PENTRU ECRANE MICI
        fontWeight: FontWeight.w400,
        color: AppColors.white,
        letterSpacing: 0.2,
      ),

      // 2. itemTitle
      titleLarge: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 16,
        fontWeight: FontWeight.w100,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0.1,
        // height: 1,
      ),

      // 3. itemDescription (bodyMedium - Condensat)
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: AppColors.darkTextPrimary,
        height: 1.2,
        letterSpacing: -0.1, // CONDENSARE
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
