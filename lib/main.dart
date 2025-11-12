import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neurify/modelos/estadisticas_modelo.dart';
import 'modelos/Calendario_model.dart';
import 'modelos/Modificaciones_model.dart';
import 'Fijo/app_theme.dart';
import 'Visuales/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EstadisticasModelo()),
        ChangeNotifierProvider(create: (_) => CalendarioModel()),
        ChangeNotifierProvider(create: (_) => ModificacionesModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Neurify App",
      theme: AppTheme.themeData,
      home: LoginScreen(),
    );
  }
}
