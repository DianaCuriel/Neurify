import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importamos el paquete
import 'Calendario.dart';
import 'login_screen.dart';
import 'Fijo/app_theme.dart';

void main() async {
  // 1. Aseguramos que Flutter esté listo antes de continuar
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Leemos del dispositivo si el usuario ya había iniciado sesión
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // 3. Pasamos esa información a la app
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  // 4. Nuestro widget principal ahora recibe el estado de la sesión
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Neurify App",
      theme: AppTheme.themeData,
      // 5. Decidimos qué pantalla mostrar basado en si la sesión está activa
      home: isLoggedIn ? const CalendarioPage() : const LoginScreen(),
    );
  }
}
