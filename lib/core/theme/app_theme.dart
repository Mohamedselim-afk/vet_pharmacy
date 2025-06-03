// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF2196F3);
  static const Color primaryVariantLight = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF03DAC6);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color errorLight = Color(0xFFB00020);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color warningLight = Color(0xFFFF9800);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF90CAF9);
  static const Color primaryVariantDark = Color(0xFF42A5F5);
  static const Color secondaryDark = Color(0xFF03DAC6);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color errorDark = Color(0xFFCF6679);
  static const Color successDark = Color(0xFF81C784);
  static const Color warningDark = Color(0xFFFFB74D);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: primaryLight,
      fontFamily: 'BahijTheSansArabic',
      
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        primaryContainer: Color(0xFFE3F2FD),
        secondary: secondaryLight,
        secondaryContainer: Color(0xFFE0F2F1),
        surface: surfaceLight,
        background: backgroundLight,
        error: errorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'BahijTheSansArabic',
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'BahijTheSansArabic',
          ),
        ),
      ),

      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceLight,
        shadowColor: Colors.black26,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorLight),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.grey),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontFamily: 'BahijTheSansArabic',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontFamily: 'BahijTheSansArabic',
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontFamily: 'BahijTheSansArabic',
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontFamily: 'BahijTheSansArabic',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontFamily: 'BahijTheSansArabic',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontFamily: 'BahijTheSansArabic',
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[200],
        disabledColor: Colors.grey[300],
        selectedColor: primaryLight,
        secondarySelectedColor: secondaryLight,
        padding: const EdgeInsets.all(8),
        labelStyle: const TextStyle(color: Colors.black87),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: primaryDark,
      fontFamily: 'BahijTheSansArabic',
      
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        primaryContainer: Color(0xFF1976D2),
        secondary: secondaryDark,
        secondaryContainer: Color(0xFF004D40),
        surface: surfaceDark,
        background: backgroundDark,
        error: errorDark,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: surfaceDark,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'BahijTheSansArabic',
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'BahijTheSansArabic',
          ),
        ),
      ),

      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceDark,
        shadowColor: Colors.black54,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorDark),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.grey),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: Colors.black,
        elevation: 4,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'BahijTheSansArabic',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'BahijTheSansArabic',
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'BahijTheSansArabic',
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'BahijTheSansArabic',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontFamily: 'BahijTheSansArabic',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontFamily: 'BahijTheSansArabic',
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[800],
        disabledColor: Colors.grey[700],
        selectedColor: primaryDark,
        secondarySelectedColor: secondaryDark,
        padding: const EdgeInsets.all(8),
        labelStyle: const TextStyle(color: Colors.white),
        secondaryLabelStyle: const TextStyle(color: Colors.black),
        brightness: Brightness.dark,
      ),
    );
  }
}

// Theme Controller
class ThemeController extends GetxController {
  final _isDarkMode = false.obs;
  
  bool get isDarkMode => _isDarkMode.value;
  
  ThemeData get theme => _isDarkMode.value ? AppTheme.dark : AppTheme.light;
  
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeTheme(theme);
    update();
  }
  
  void setTheme(bool isDark) {
    _isDarkMode.value = isDark;
    Get.changeTheme(theme);
    update();
  }
}

// // lib/core/theme/app_theme.dart
// import 'package:flutter/material.dart';

// class AppTheme {
//   static ThemeData get light {
//     return ThemeData(
//       primarySwatch: Colors.blue,
//       fontFamily: 'BahijTheSansArabic',
//       appBarTheme: AppBarTheme(
//         elevation: 0,
//         centerTitle: true,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//       cardTheme: CardTheme(
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),
//       textTheme: TextTheme(
//         titleLarge: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//         titleMedium: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w500,
//         ),
//         bodyLarge: TextStyle(
//           fontSize: 16,
//         ),
//         bodyMedium: TextStyle(
//           fontSize: 14,
//         ),
//       ),
//     );
//   }
// }