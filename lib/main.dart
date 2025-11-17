// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// //  Usa SIEMPRE imports absolutos y misma carpeta en minúsculas.
// import 'package:neurify/modelos/estadisticas_modelo.dart';
// import 'package:neurify/modelos/calendario_model.dart';
// import 'package:neurify/modelos/modificaciones_model.dart';

// import 'fijo/app_theme.dart';
// import 'visuales/login_screen.dart';

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => EstadisticasModelo()),
//         ChangeNotifierProvider(create: (_) => CalendarioModel()),
//         ChangeNotifierProvider(create: (_) => ModificacionesModel()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Nota: esto es seguro; el árbol de providers envuelve a MyApp.
//     try {
//       final calendario = Provider.of<CalendarioModel>(context, listen: false);
//       // Por qué: útil para confirmar que el provider está arriba.
//       // ignore: avoid_print
//       print("CalendarioModel disponible en MyApp: $calendario");
//     } catch (e) {
//       // ignore: avoid_print
//       print("CalendarioModel NO está disponible en MyApp: $e");
//     }

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Neurify App",
//       theme: AppTheme.themeData,
//       home: const LoginScreen(),
//     );
//   }
// }

// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neurify/modelos/estadisticas_modelo.dart';
import 'package:neurify/modelos/calendario_model.dart';
import 'package:neurify/modelos/modificaciones_model.dart';

import 'fijo/app_theme.dart';
import 'visuales/login_screen.dart';
import 'visuales/calendario.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EstadisticasModelo()),
        ChangeNotifierProvider(create: (_) => CalendarioModel()),
        ChangeNotifierProvider(create: (_) => ModificacionesModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Neurify App",
      theme: AppTheme.themeData,
      home: const AuthGate(), //  aquí va el gate
    );
  }
}

/// Checa SharedPreferences y manda a Login o Calendario.
/// Muestra un splashcito mientras carga.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('logged_in') == true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final logged = snap.data!;
        return logged ? const CalendarioPage() : const LoginScreen();
      },
    );
  }
}
