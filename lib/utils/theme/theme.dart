import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

/// [ CustomTheme ] is a class that contains the theme for the app.
class CustomTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'NunitoSans',
        scaffoldBackgroundColor: Colors.transparent,

        /// [ Text Theme ] for the app.
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(fontSize: 24, color: AppColors.disabled),
          titleLarge: TextStyle(
            color: AppColors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.15,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            color: AppColors.disabled,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
          ),
          bodyLarge: TextStyle(
            color: AppColors.black,
            fontSize: 16,
            letterSpacing: 0.15,
          ),
          bodyMedium: TextStyle(
            color: AppColors.darkGrey,
            fontSize: 14,
            letterSpacing: 0.25,
          ),
          bodySmall: TextStyle(
            color: AppColors.black,
            fontSize: 12,
            letterSpacing: 0.4,
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          color: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.transparent),
          foregroundColor: AppColors.black,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          elevation: 0,
          backgroundColor: AppColors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 0,
          backgroundColor: AppColors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
}
