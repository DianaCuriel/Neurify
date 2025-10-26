// #1.1
import 'package:flutter/material.dart';
import 'package:neurify/Visuales/login_screen.dart';
import 'Fijo/app_theme.dart';

// --- AÑADE ESTOS IMPORTS ---
import 'package:provider/provider.dart';
// Asegúrate que la ruta a tu modelo sea correcta
import 'package:neurify/modelos/estadisticas_modelo.dart';

//1.2
void main() {
  // --- MODIFICA LA FUNCIÓN main() ---
  runApp(
    // 1. Envuelve tu app con el Provider
    ChangeNotifierProvider(
      // 2. Crea la instancia de tu modelo
      create: (context) => EstadisticasModelo(),
      // 3. El hijo sigue siendo tu app
      child: const MyApp(),
    ),
  );
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
