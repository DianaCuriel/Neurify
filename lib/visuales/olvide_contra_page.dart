import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:neurify/fijo/app_theme.dart';
import 'olvide_contra_reset_page.dart';

class OlvideContrasenaScreen extends StatefulWidget {
  const OlvideContrasenaScreen({super.key});

  @override
  State<OlvideContrasenaScreen> createState() => _OlvideContrasenaScreenState();
}

class _OlvideContrasenaScreenState extends State<OlvideContrasenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);

    final url = Uri.parse(
      'http://servidor-morales11.sytes.net:5050/solicitar_restablecimiento.php',
    );
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'correo': _correoCtrl.text.trim()}),
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['mensaje'] ??
                'Revisa tu correo si existe una cuenta asociada.',
          ),
        ),
      );

      if (data['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => RestablecerContrasenaScreen(
                  correo: _correoCtrl.text.trim(),
                ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Olvidé mi contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Escribe el correo asociado a tu cuenta. Te enviaremos un código de verificación.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _correoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ingresa tu correo'
                            : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _enviando ? null : _enviarCodigo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor, // color de fondo
                  foregroundColor: Colors.white, // texto e íconos en blanco
                  textStyle: const TextStyle(
                    // estilo del texto (opcional)
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child:
                    _enviando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Enviar código'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
