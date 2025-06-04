import 'package:flutter/material.dart';

class AppTheme {
  // VS Code renklerini tanımlama
  static const Color vsCodeBackground = Color(0xFF1E1E1E);
  static const Color vsCodeForeground = Color(0xFFD4D4D4);
  static const Color vsCodeBlue = Color(0xFF569CD6);
  static const Color vsCodeLightBlue = Color(0xFF9CDCFE);
  static const Color vsCodeYellow = Color(0xFFDCDC37);
  static const Color vsCodeOrange = Color(0xFFCE9178);
  static const Color vsCodeGreen = Color(0xFF6A9955);
  static const Color vsCodePurple = Color(0xFFC586C0);
  static const Color vsCodeRed = Color(0xFFF44747);
  static const Color vsCodeDarkGrey = Color(0xFF333333);
  static const Color vsCodeLightGrey = Color(0xFF505050);

  // Temayı oluştur
  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: vsCodeBackground,
      primaryColor: vsCodeBlue,
      colorScheme: const ColorScheme.dark(
        primary: vsCodeBlue,
        secondary: vsCodePurple,
        surface: vsCodeDarkGrey,
        background: vsCodeBackground,
        error: vsCodeRed,
        onPrimary: vsCodeForeground,
        onSecondary: vsCodeForeground,
        onSurface: vsCodeForeground,
        onBackground: vsCodeForeground,
        onError: vsCodeForeground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: vsCodeDarkGrey,
        foregroundColor: vsCodeForeground,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: vsCodeBlue,
        foregroundColor: Colors.white,
      ),
      textTheme: Typography.material2018().white.copyWith(
        bodyLarge: const TextStyle(color: vsCodeForeground),
        bodyMedium: const TextStyle(color: vsCodeForeground),
        titleMedium: const TextStyle(color: vsCodeLightBlue),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: vsCodeDarkGrey,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: vsCodeLightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: vsCodeBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: vsCodeLightGrey),
        ),
        labelStyle: const TextStyle(color: vsCodeLightBlue),
        hintStyle: const TextStyle(color: vsCodeLightGrey),
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: vsCodeBackground,
        textColor: vsCodeForeground,
      ),
      dividerColor: vsCodeLightGrey,
      cardTheme: CardThemeData(
        color: vsCodeDarkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
} 