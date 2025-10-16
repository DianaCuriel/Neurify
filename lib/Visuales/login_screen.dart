import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Usamos almacenamiento seguro
import '../Fijo/app_theme.dart';
import 'Calendario.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- ESTADO Y CONTROLADORES ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage =
      const FlutterSecureStorage(); // Instancia del almacenamiento seguro

  bool _isPasswordVisible = false;
  bool _rememberMe = false; // Estado para el checkbox

  // --- DATOS DE DEMO (para pruebas) ---
  static const String _demoUser = 'isaac';
  static const String _demoPass = '1234';

  @override
  void initState() {
    super.initState();
    _loadUserCredentials(); // Intentar cargar datos guardados al iniciar la pantalla
  }

  // --- LÓGICA DE LA FUNCIONALIDAD ---

  // Carga las credenciales guardadas de forma segura
  Future<void> _loadUserCredentials() async {
    try {
      final username = await _storage.read(key: 'username');
      final password = await _storage.read(key: 'password');

      // Si se encontraron datos, se cargan en los campos
      if (username != null && password != null) {
        setState(() {
          _usernameController.text = username;
          _passwordController.text = password;
          _rememberMe = true;
        });
      }
    } catch (e) {
      // Manejo de errores en caso de que la lectura falle
      debugPrint("Error al leer credenciales guardadas: $e");
    }
  }

  // Procesa el inicio de sesión del usuario
  Future<void> login() async {
    // Primero, valida que los campos no estén vacíos
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Lógica para guardar o borrar las credenciales según el checkbox
    if (_rememberMe) {
      // Si "Recordarme" está activo, guarda el usuario y contraseña
      await _storage.write(key: 'username', value: _usernameController.text);
      await _storage.write(key: 'password', value: _passwordController.text);
    } else {
      // Si no está activo, borra cualquier credencial que estuviera guardada
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'password');
    }

    // Lógica de autenticación (aquí usas tus datos de prueba)
    if (_usernameController.text == _demoUser &&
        _passwordController.text == _demoPass) {
      // Si el login es exitoso, navega a la siguiente pantalla
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CalendarioPage()),
        );
      }
    } else {
      // Si el login falla, muestra un mensaje de error
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

  // Navega a la pantalla de "Olvidé mi contraseña"
  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  // --- CONSTRUCCIÓN DE LA INTERFAZ DE USUARIO ---
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
                  // Sección superior con el logo
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/images/Logo.png', // Ruta corregida sin 'lib/'
                          height: 170,
                        ),
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
                  // Sección inferior con el formulario
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
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted:
                                  (_) => FocusScope.of(context).nextFocus(),
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
                                  onPressed:
                                      () => setState(
                                        () =>
                                            _isPasswordVisible =
                                                !_isPasswordVisible,
                                      ),
                                ),
                              ),
                              validator:
                                  (value) =>
                                      (value == null || value.isEmpty)
                                          ? 'Ingrese su contraseña'
                                          : null,
                            ),

                            // Checkbox para "Recordarme"
                            CheckboxListTile(
                              title: const Text(
                                "Recordarme",
                                style: TextStyle(color: Colors.grey),
                              ),
                              value: _rememberMe,
                              onChanged: (newValue) {
                                setState(() {
                                  _rememberMe = newValue ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 10),

                            // Botón de Entrar
                            ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: AppTheme.tituloBoton('Entrar'),
                            ),
                            const SizedBox(height: 20),
                            // Botón de "Olvidé mi contraseña"
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
