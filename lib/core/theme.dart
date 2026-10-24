import 'package:flutter/material.dart';

abstract final class CinemaColors {
  static const background = Color(0xFF201F28);
  static const panel = Color(0xFF19162B);
  static const purple = Color(0xFF252140);
  static const yellow = Color(0xFFFFD818);
  static const muted = Color(0xFF96959E);
  static const line = Color(0xFF45444E);
  static const blue = Color(0xFF6484FF);
  static const seat = Color(0xFF696D70);
  static const selected = Color(0xFF0088FF);
  static const couple = Color(0xFFED0967);
}

ThemeData cinemaTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: CinemaColors.background,
  colorScheme: const ColorScheme.dark(
    primary: CinemaColors.yellow,
    secondary: CinemaColors.blue,
    surface: CinemaColors.background,
    onPrimary: CinemaColors.background,
  ),
  fontFamily: 'Futura',
  useMaterial3: true,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 14, height: 1.45),
    bodySmall: TextStyle(fontSize: 12, color: CinemaColors.muted, height: 1.4),
  ),
  dividerTheme: const DividerThemeData(
    color: CinemaColors.line,
    thickness: 0.6,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: CinemaColors.muted, fontSize: 14),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: CinemaColors.muted),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: CinemaColors.yellow),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 14),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: CinemaColors.purple,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(foregroundColor: Colors.white),
  ),
);
