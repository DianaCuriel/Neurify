import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Cita {
  final int? idCitas;
  final int? idCliente;
  final int idEmpresario;
  final String nombreCliente;
  final String telefono;
  final String correo;
  final String motivo;
  final String estado;
  final DateTime fechaHora;

  Cita({
    this.idCitas,
    this.idCliente,
    required this.idEmpresario,
    required this.nombreCliente,
    required this.telefono,
    required this.correo,
    required this.motivo,
    required this.estado,
    required this.fechaHora,
  });

  /// 🔹 Crear objeto desde JSON (respuesta del PHP)
  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      idCitas: int.tryParse(json['id_citas'].toString()),
      idCliente: int.tryParse(json['id_cliente'].toString()),
      idEmpresario: int.tryParse(json['id_empresario'].toString()) ?? 1,
      nombreCliente: json['nombre_cliente'] ?? '',
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
      motivo: json['motivo'] ?? '',
      estado: json['estado'] ?? '',
      fechaHora: DateTime.parse(json['fechaHora']),
    );
  }

  /// 🔹 Convertir a JSON para enviar al PHP
  Map<String, dynamic> toJson({required String accion}) {
    return {
      'accion': accion,
      if (idCitas != null) 'id_citas': idCitas,
      if (idCliente != null) 'id_cliente': idCliente,
      'id_empresario': idEmpresario,
      'nombre_cliente': nombreCliente,
      'telefono': telefono,
      'correo': correo,
      'motivo': motivo,
      'estado': estado,
      'fechaHora': fechaHora.toIso8601String(),
    };
  }
}

class CalendarioModel extends ChangeNotifier {
  final String apiUrl =
      'http://servidor-morales11.sytes.net:5050/Calendario.php';

  List<Cita> _citas = [];
  List<Cita> get citas => List.unmodifiable(_citas);

  /* ────────────────────────────────
   🔹 OBTENER CITAS
  ───────────────────────────────── */
  Future<void> fetchCitas() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'accion': 'listar'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['citas'] is List) {
          _citas =
              (data['citas'] as List)
                  .map((json) => Cita.fromJson(json))
                  .toList();
          notifyListeners();
        } else {
          print('Error: respuesta inesperada $data');
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchCitas: $e');
    }
  }

  /* ────────────────────────────────
   🔹 AÑADIR NUEVA CITA + CLIENTE
  ───────────────────────────────── */
  Future<void> addCita(Cita cita) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cita.toJson(accion: 'añadir')),
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        await fetchCitas();
      } else {
        print('Error al agregar cita: ${data['mensaje']}');
      }
    } catch (e) {
      print('Error addCita: $e');
    }
  }

  /* ────────────────────────────────
   🔹 MODIFICAR CITA + CLIENTE
  ───────────────────────────────── */
  Future<void> updateCita(Cita cita) async {
    if (cita.idCitas == null) return;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cita.toJson(accion: 'modificar')),
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        await fetchCitas();
      } else {
        print('Error al modificar cita: ${data['mensaje']}');
      }
    } catch (e) {
      print('Error updateCita: $e');
    }
  }

  /* ────────────────────────────────
   🔹 ELIMINAR CITA + CLIENTE
  ───────────────────────────────── */
  Future<void> removeCita(Cita cita) async {
    if (cita.idCitas == null) return;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'accion': 'borrar', 'id_citas': cita.idCitas}),
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        await fetchCitas();
      } else {
        print('Error al borrar cita: ${data['mensaje']}');
      }
    } catch (e) {
      print('Error removeCita: $e');
    }
  }
}
