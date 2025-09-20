import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Paleta de colores
  static const Color primaryColor = Color(
    0xFF2C3E50,
  ); // Azul oscuro (como en tu header)
  static const Color backgroundColor = Color(0xFFF2F2F2); // Gris claro
  static const Color accentColor = Colors.black87;

  // 📖 Tipografía
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle sutittleStyle = TextStyle(
    fontSize: 16,
    color: primaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: titleStyle,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      bodyLarge: bodyStyle,
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.black54,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );
}
