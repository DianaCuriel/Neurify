import 'package:flutter/material.dart';
import '../Fijo/app_theme.dart'; // Asegúrate de que la ruta a tu tema sea correcta

class EstadisticasPage extends StatelessWidget {
  const EstadisticasPage({super.key});

  // Widget para construir una tarjeta de estadística reutilizable
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Resumen del Mes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap:
                  true, // Para que el GridView quepa dentro del ListView
              physics:
                  const NeverScrollableScrollPhysics(), // Deshabilita el scroll del GridView
              children: [
                _buildStatCard(
                  icon: Icons.calendar_today,
                  title: 'Citas Completadas',
                  value: '42',
                  color: Colors.blue,
                ),
                _buildStatCard(
                  icon: Icons.person_add_alt_1,
                  title: 'Pacientes Nuevos',
                  value: '5',
                  color: Colors.green,
                ),
                _buildStatCard(
                  icon: Icons.attach_money,
                  title: 'Ingresos',
                  value: '\$2,100',
                  color: Colors.amber,
                ),
                _buildStatCard(
                  icon: Icons.cancel_outlined,
                  title: 'Cancelaciones',
                  value: '3',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
