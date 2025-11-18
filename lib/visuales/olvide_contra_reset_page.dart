import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:neurify/fijo/app_theme.dart';

class RestablecerContrasenaScreen extends StatefulWidget {
  final String correo;
  const RestablecerContrasenaScreen({super.key, required this.correo});

  @override
  State<RestablecerContrasenaScreen> createState() =>
      _RestablecerContrasenaScreenState();
}

class _RestablecerContrasenaScreenState
    extends State<RestablecerContrasenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();
  final _pass1Ctrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _enviando = false;
  bool _ver = false;

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _pass1Ctrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _restablecer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pass1Ctrl.text.trim() != _pass2Ctrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    setState(() => _enviando = true);
    final url = Uri.parse(
      'http://servidor-morales11.sytes.net:5050/confirmar_restablecimiento.php',
    );

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'correo': widget.correo.trim(),
          'codigo': _codigoCtrl.text.trim(),
          'nueva_contrasena': _pass1Ctrl.text.trim(),
        }),
      );
      final data = jsonDecode(res.body);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['mensaje'] ?? 'Resultado recibido.')),
      );

      if (data['success'] == true) {
        Navigator.pop(
          context,
        ); // volver a la pantalla anterior (login o forgot)
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
      appBar: AppBar(title: const Text('Restablecer contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Enviamos un código a: ${widget.correo}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código de verificación',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ingresa el código'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pass1Ctrl,
                obscureText: !_ver,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_ver ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _ver = !_ver),
                  ),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ingresa la nueva contraseña'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pass2Ctrl,
                obscureText: !_ver,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Confirma la contraseña'
                            : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _enviando ? null : _restablecer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white, // texto e íconos en blanco
                  textStyle: const TextStyle(
                    // estilo del texto (opcional)
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child:
                    _enviando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Restablecer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
