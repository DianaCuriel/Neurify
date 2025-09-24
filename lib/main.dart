import 'package:flutter/material.dart';
import 'package:neurify/Calendario.dart';
import 'Fijo/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Mi App",
      theme: AppTheme.themeData, // 🌟 aquí aplicamos el tema
      home: const CalendarioPage(),
    );
  }
}
