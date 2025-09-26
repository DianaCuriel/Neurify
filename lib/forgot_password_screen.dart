import 'package:flutter/material.dart';
import 'Fijo/app_theme.dart'; // Usamos el tema principal que ya tienes

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. FONDO COHERENTE: Usamos el mismo color primario del login.
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        // 2. APPBAR LIMPIO: Lo hacemos transparente para que se fusione con el fondo.
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // 3. ICONO VISUAL: Un ícono grande para centrar la atención.
              const Icon(Icons.lock_reset, size: 80, color: Colors.white),
              const SizedBox(height: 30),

              // 4. TEXTOS CLAROS: Título y subtítulo con buen contraste.
              Text(
                'Recuperar Contraseña',
                textAlign: TextAlign.center,
                style: AppTheme.titleStyle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 15),
              Text(
                'Ingresa tu email y te enviaremos un enlace para restablecerla.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              // 5. CAMPO DE TEXTO MODERNO: Con fondo blanco e ícono.
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'tu@email.com',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 6. BOTÓN QUE RESALTA: Con colores invertidos para llamar a la acción.
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enlace de recuperación enviado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.caja, // Fondo blanco
                  foregroundColor: AppTheme.primaryColor, // Texto azul
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Enviar Enlace',
                  style: AppTheme.TituloBoton.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
