import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildGysTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: GysColors.brand500,
    primary: GysColors.brand500,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: GysColors.neutral50,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: GysColors.neutral900,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.white,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: GysColors.neutral900,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: GysColors.neutral400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: GysColors.neutral200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: GysColors.neutral200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: GysColors.brand500, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: GysColors.brand500,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(0, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: GysColors.brand700,
        side: const BorderSide(color: GysColors.neutral200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(0, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: GysColors.brand700,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: GysColors.neutral200),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: GysColors.brand50,
      labelStyle: const TextStyle(color: GysColors.brand700, fontWeight: FontWeight.w600),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: const DividerThemeData(color: GysColors.neutral200, thickness: 1, space: 1),
  );
}
