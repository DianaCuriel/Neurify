import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Fijo/app_theme.dart';
import 'Calendario.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  static const String _demoUser = 'isaac';
  static const String _demoPass = '1234';

  void _login() async {
    // Se valida el formulario antes de la operación asíncrona
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_usernameController.text == _demoUser &&
        _passwordController.text == _demoPass) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // --- CORRECCIÓN 1: 'use_build_context_synchronously' ---
      // Se comprueba si el widget todavía está en pantalla antes de usar su BuildContext.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CalendarioPage()),
        );
      }
    } else {
      // --- CORRECCIÓN 1: 'use_build_context_synchronously' ---
      // También se aplica aquí, ya que está en el mismo scope asíncrono.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario o contraseña incorrectos'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  void _goToCalendario() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CalendarioPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/images/logo.png', // Ruta de tu logo
                          height: 150, // Puedes ajustar este valor
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Iniciar sesión',
                          style: AppTheme.titleStyle.copyWith(
                            fontSize: 18,
                            // --- CORRECCIÓN 2: 'deprecated_member_use' ---
                            // Se reemplaza withOpacity por withAlpha
                            color: Colors.white.withAlpha((255 * 0.7).round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 40,
                      ),
                      decoration: const BoxDecoration(
                        color: AppTheme.caja,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Nombre',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              textAlign: TextAlign.center,
                              textInputAction:
                                  TextInputAction
                                      .next, // <- Mueve al siguiente campo
                              onFieldSubmitted: (_) {
                                FocusScope.of(
                                  context,
                                ).nextFocus(); // <- Salta al campo de contraseña
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator:
                                  (value) =>
                                      (value == null || value.isEmpty)
                                          ? 'Ingrese su nombre'
                                          : null,
                            ),

                            const SizedBox(height: 20),
                            const Text(
                              'Contraseña',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppTheme.primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator:
                                  (value) =>
                                      (value == null || value.isEmpty)
                                          ? 'Ingrese su contraseña'
                                          : null,
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _goToCalendario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // Asumiendo que corregirás esto en app_theme.dart
                              child: AppTheme.tituloBoton('Entrar'),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: TextButton(
                                onPressed: _goToForgotPassword,
                                child: const Text(
                                  'Olvisate tu contraseña?',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
