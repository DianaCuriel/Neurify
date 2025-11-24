import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../fijo/app_theme.dart';
import '../visuales/calendario.dart';
import 'olvide_contra_page.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _prefillUser() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString('usuario');
    if (u != null && mounted) {
      setState(() => _usernameController.text = u);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse('http://servidor-morales11.sytes.net:5050/Login.php');
    final body = jsonEncode({
      'usuario': _usernameController.text.trim(),
      'contraseña': _passwordController.text.trim(),
    });

    print("Enviando login: $body");

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: body,
          )
          .timeout(const Duration(seconds: 12));

      print(' Código HTTP: ${response.statusCode}');
      print(' Respuesta: ${response.body}');

      // Evitar crash si el body viene vacío o con JSON inválido
      Map<String, dynamic>? data;
      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          data = null;
          print(' JSON inválido: $e');
        }
      }

      if (response.statusCode == 200 && (data?['success'] == true)) {
        // Puedes extraer info adicional si el PHP la envía
        final usuario = (data!['usuario'] ?? {}) as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('logged_in', true);
        await prefs.setString('usuario', _usernameController.text.trim());
        if (usuario['id_credenciales'] != null) {
          await prefs.setInt(
            'id_credenciales',
            int.tryParse('${usuario['id_credenciales']}') ?? 0,
          );
        }
        if (usuario['rol'] != null) {
          await prefs.setString('rol', '${usuario['rol']}');
        }

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CalendarioPage()),
          (_) => false,
        );
      } else {
        final msg =
            data?['mensaje'] ??
            (response.statusCode >= 500
                ? 'Error del servidor (${response.statusCode}).'
                : 'Usuario o contraseña incorrectos.');
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OlvideContrasenaScreen()),
    );
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
                        Image.asset('assets/images/logo.png', height: 150),
                        const SizedBox(height: 20),
                        Text(
                          'Iniciar sesión',
                          style: AppTheme.titleStyle.copyWith(
                            fontSize: 18,
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
                              'Usuario',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              textAlign: TextAlign.center,
                              textInputAction: TextInputAction.next,
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
                                          ? 'Ingrese su usuario'
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
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : AppTheme.tituloBoton('Entrar'),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: TextButton(
                                onPressed: _goToForgotPassword,
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
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
