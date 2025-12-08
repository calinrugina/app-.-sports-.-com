import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData light() {
    const defaultFont = 'Roboto';
    return ThemeData(
      fontFamily: defaultFont,
      textTheme: AppTextStyles.lightTextTheme(defaultFont),
      //     .apply(
      //   displayColor: AppColors.white, // Culoarea primară pentru textul de afișare
      //   bodyColor: AppColors.white,
      // ),
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
    const defaultFont = 'Roboto';
    return ThemeData(
      fontFamily: defaultFont,
      textTheme: AppTextStyles.darkTextTheme(defaultFont),
      //     .apply(
      //   displayColor: AppColors.darkTextPrimary, // Culoarea primară pentru textul de afișare
      // //   bodyColor: AppColors.darkTextPrimary,
      // ),
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
class AppTextStyles {
  // Styles pentru tema LIGHT
  static TextTheme lightTextTheme(String? fontFamily) {
    return TextTheme(
      // 1. sectionTitle (Ex: UEFA CHAMPIONS LEAGUE - Mare, Bold, ALL CAPS, 16px)
      headlineLarge: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextPrimary,
        letterSpacing: 1,
      ),

      // 2. itemTitle (Ex: Osimhen hits CL hat-trick - Titlul principal al elementului, Bold, 16px)
      titleLarge: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        // letterSpacing: .8,
        color: AppColors.lightTextPrimary,
        // height: 1.00, // Asigură spațiu pentru 2 linii
      ),

      // 3. itemDescription (Ex: UEFA CHAMPIONS LEAGUE - Textul subtitlu/sursă, 14px)
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextSecondary,
        height: 1.2,
      ),

      // 4. itemDate (Ex: 6 DAYS AGO - Data/durata, 12px, Subțire/Semi-Bold, ALL CAPS, Gri)
      labelSmall: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.gray60,
        // letterSpacing: 0.8,
      ),
    );
  }

  // Styles pentru tema DARK
  static TextTheme darkTextTheme(String? fontFamily) {
    return TextTheme(
      // 1. sectionTitle
      headlineLarge: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color:AppColors.white,
        letterSpacing: 0.5,
      ),

      // 2. itemTitle
      titleLarge: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: .8,
        color: AppColors.darkTextPrimary,
        height: 1.25,
      ),

      // 3. itemDescription
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: AppColors.darkTextPrimary,
        height: 1,
      ),

      // 4. itemDate
      labelSmall: const TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}