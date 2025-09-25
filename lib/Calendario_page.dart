import 'package:flutter/material.dart';
import '../fijo/app_bar.dart'; // Cambiado
import '../fijo/bottom_navigator.dart'; // Cambiado
import 'calendario_card.dart'; // Cambiado
import '../fijo/app_theme.dart';
import '../modelos/calendario_model.dart'; // Cambiado
import '../servicios/auth_service.dart'; // Nuevo

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  bool _isMonthlyView = false;
  List<Cliente> citas = [
    Cliente(
      nombre: "Juan Pérez",
      asunto: 'prueba',
      numero: 'prueba',
      fecha: "22/09/2025",
      hora: "3:00",
    ),
    Cliente(
      nombre: "María López",
      asunto: 'prueba',
      numero: 'prueba',
      fecha: "23/09/2025",
      hora: "1:00",
    ),
  ];

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MiAppBar(),
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height:
              _isMonthlyView
                  ? MediaQuery.of(context).size.height * 0.75
                  : MediaQuery.of(context).size.height * 0.55,
          child: CalendarCard(
            citas: citas,
            initialDate: DateTime.now(),
            isMonthlyView: _isMonthlyView,
            onToggleView: () {
              setState(() {
                _isMonthlyView = !_isMonthlyView;
              });
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ... (tu código del modal existente)
        },
        tooltip: 'Agregar',
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: AppTheme.primaryColor,
      ),
      bottomNavigationBar: const MiBottomNav(),
    );
  }
}
