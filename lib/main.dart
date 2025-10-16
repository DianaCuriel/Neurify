// #1.1
import 'package:flutter/material.dart';
import 'package:neurify/Visuales/login_screen.dart';
import 'Fijo/app_theme.dart';

//1.2
void main() {
  runApp(const MyApp());
}

//1.3
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Neurify App",
      theme: AppTheme.themeData,
      home: const LoginScreen(),
    );
  }
}
