import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Modelos/login_screen.dart';
import 'Fijo/BottomNavigator.dart';
import 'Calendario_card.dart';
import 'Fijo/app_theme.dart';
import 'Modelos/estadisticas_page.dart'; // Asegúrate que la ruta sea correcta

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  int _selectedIndex = 0;

  // Lista de las páginas que se mostrarán.
  final List<Widget> _pages = <Widget>[
    const _CalendarView(),
    const SizedBox.shrink(), // Un espacio vacío para el botón flotante central.
    const EstadisticasPage(),
  ];

  // Esta función se llama cuando se toca un ítem de la barra de navegación.
  void _onItemTapped(int index) {
    if (index == 1) return; // Ignoramos el toque en el espacio del medio.
    setState(() {
      _selectedIndex = index;
    });
  }

  // Lógica para cerrar sesión.
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/neurify_logo.png'),
        ),
        title: Text(_selectedIndex == 0 ? "Calendario" : "Estadísticas"),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: _logout,
          ),
        ],
      ),
      // Muestra la página correspondiente al índice seleccionado.
      body: _pages.elementAt(_selectedIndex),

      // --- TU CÓDIGO ORIGINAL PARA EL MODAL SE MANTIENE INTACTO ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              // ... toda tu lógica de DraggableScrollableSheet y el formulario va aquí ...
              return DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  final TextEditingController nombreController =
                      TextEditingController();
                  final TextEditingController asuntoController =
                      TextEditingController();
                  final TextEditingController numeroController =
                      TextEditingController();
                  final TextEditingController fechaController =
                      TextEditingController();
                  final TextEditingController horaController =
                      TextEditingController();

                  return StatefulBuilder(
                    builder: (context, setStateInModal) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        final datos = {
                                          'nombre': nombreController.text,
                                          'asunto': asuntoController.text,
                                          'numero': numeroController.text,
                                          'fecha': fechaController.text,
                                          'hora': horaController.text,
                                        };
                                        Navigator.pop(context, datos);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                      ),
                                      child: AppTheme.tituloBoton("Guardar"),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                AppTheme.subtitleText('Datos personales'),
                                // ... El resto de tus TextFields ...
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ).then((datos) {
            if (datos != null) {
              // Lógica para manejar los datos guardados
            }
          });
        },
        tooltip: 'Agregar',
        backgroundColor: AppTheme.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // CORRECCIÓN: Ahora le pasamos los parámetros requeridos a MiBottomNav
      bottomNavigationBar: MiBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Widget interno para mantener la vista del calendario limpia.
class _CalendarView extends StatelessWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: FractionallySizedBox(heightFactor: 0.6, child: CalendarCard()),
    );
  }
}
