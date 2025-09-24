//2.a.1
import 'package:flutter/material.dart';

//2.a.2
class AppTheme {
  // 2.a.2.1
  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color backgroundColor = Color(0xFFF2F2F2); // Gris claro
  static const Color accentColor = Colors.black87;
  static const Color caja = Colors.white;

  // 2.a.2.2
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

  static const TextStyle TituloBoton = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  //2.a.2.3
  static Widget subtitleText(String text) {
    return Text(text, style: sutittleStyle, textAlign: TextAlign.center);
  }

  static Widget tituloBoton(String text) {
    return Text(text, style: TituloBoton);
  }

  //2.a.2.4
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
