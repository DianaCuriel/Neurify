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

  /*──────────────────────────────
   🔹 Crear objeto desde JSON (PHP → Flutter)
  ──────────────────────────────*/
  factory Cita.fromJson(Map<String, dynamic> json) {
    print(' [fromJson] Recibiendo JSON: $json');
    try {
      // Si PHP envía 'fecha' y 'hora' separados
      final fecha = json['fecha'] ?? '';
      final hora = json['hora'] ?? '00:00:00';
      final fechaHora =
          DateTime.tryParse('$fecha $hora') ??
          DateTime.now(); // fallback si hay error

      return Cita(
        idCitas: int.tryParse(json['id_citas'].toString()),
        idCliente: int.tryParse(json['id_cliente'].toString()),
        idEmpresario: int.tryParse(json['id_empresario'].toString()) ?? 3,
        nombreCliente: json['nombre_cliente'] ?? '',
        telefono: json['telefono'] ?? '',
        correo: json['correo'] ?? '',
        motivo: json['motivo'] ?? '',
        estado: json['estado'] ?? '',
        fechaHora: fechaHora,
      );
    } catch (e) {
      print('[fromJson] Error al parsear cita: $e');
      rethrow;
    }
  }

  /*──────────────────────────────
   🔹 Convertir a JSON (Flutter → PHP)
  ──────────────────────────────*/
  Map<String, dynamic> toJson({required String accion}) {
    final fecha = fechaHora.toIso8601String().split('T')[0];
    final hora = fechaHora.toIso8601String().split('T')[1].split('.')[0];

    final jsonMap = {
      'accion': accion,
      if (idCitas != null) 'id_citas': idCitas,
      if (idCliente != null) 'id_cliente': idCliente,
      'id_empresario': idEmpresario,
      'nombre_cliente': nombreCliente,
      'telefono': telefono,
      'correo': correo,
      'motivo': motivo,
      'estado': estado,
      'fecha': fecha,
      'hora': hora,
    };

    print('[toJson:$accion] Datos preparados: $jsonMap');
    return jsonMap;
  }

  /*──────────────────────────────
   🔹 Copiar cita modificando campos
  ──────────────────────────────*/
  Cita copyWith({
    int? idCitas,
    int? idCliente,
    int? idEmpresario,
    String? nombreCliente,
    String? telefono,
    String? correo,
    String? motivo,
    String? estado,
    DateTime? fechaHora,
  }) {
    print('[copyWith] Creando copia modificada...');
    return Cita(
      idCitas: idCitas ?? this.idCitas,
      idCliente: idCliente ?? this.idCliente,
      idEmpresario: idEmpresario ?? this.idEmpresario,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      motivo: motivo ?? this.motivo,
      estado: estado ?? this.estado,
      fechaHora: fechaHora ?? this.fechaHora,
    );
  }
}

class CalendarioModel extends ChangeNotifier {
  final String apiUrl =
      'http://servidor-morales11.sytes.net:5050/Calendario.php';

  List<Cita> _citas = [];
  List<Cita> get citas => List.unmodifiable(_citas);

  /*──────────────────────────────
   🔹 OBTENER CITAS
  ──────────────────────────────*/
  Future<void> fetchCitas() async {
    print('📡 [fetchCitas] Solicitando lista de citas...');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'accion': 'listar'}),
      );
      print('[fetchCitas] Código HTTP: ${response.statusCode}');
      print('[fetchCitas] Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['citas'] is List) {
          _citas =
              (data['citas'] as List)
                  .map((json) => Cita.fromJson(json))
                  .toList();
          print(' [fetchCitas] ${_citas.length} citas cargadas.');
          notifyListeners();
        } else {
          print(' [fetchCitas] Respuesta inesperada: $data');
        }
      } else {
        print(' [fetchCitas] Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print(' [fetchCitas] Error: $e');
    }
  }

  /*──────────────────────────────
   🔹 AÑADIR NUEVA CITA + CLIENTE
  ──────────────────────────────*/
  Future<void> addCita(Cita cita) async {
    print(' [addCita] Enviando nueva cita...');
    final jsonBody = cita.toJson(accion: 'añadir');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonBody),
      );

      print(' [addCita] Código HTTP: ${response.statusCode}');
      print(' [addCita] Respuesta: ${response.body}');

      final data = json.decode(response.body);
      if (data['success'] == true) {
        print('[addCita] Cita añadida con éxito');
        await fetchCitas();
      } else {
        print(' [addCita] Error: ${data['mensaje']}');
      }
    } catch (e) {
      print(' [addCita] Excepción: $e');
    }
  }

  /*──────────────────────────────
   🔹 MODIFICAR CITA + CLIENTE
  ──────────────────────────────*/
  Future<void> updateCita(Cita cita) async {
    if (cita.idCitas == null) {
      print(' [updateCita] idCitas es null, no se puede actualizar.');
      return;
    }

    print(' [updateCita] Enviando cita ID: ${cita.idCitas}');
    final jsonBody = cita.toJson(accion: 'modificar');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonBody),
      );

      print(' [updateCita] Código HTTP: ${response.statusCode}');
      print(' [updateCita] Respuesta: ${response.body}');

      final data = json.decode(response.body);
      if (data['success'] == true) {
        print(' [updateCita] Cita actualizada correctamente.');
        await fetchCitas();
      } else {
        print(' [updateCita] Error: ${data['mensaje']}');
      }
    } catch (e) {
      print(' [updateCita] Error: $e');
    }
  }

  /*──────────────────────────────
   🔹 CANCELAR CITA (Actualizar estado a "Cancelada")
  ──────────────────────────────*/
  Future<void> cancelarCita(Cita cita) async {
    if (cita.idCitas == null) {
      print(' [cancelarCita] idCitas es null.');
      return;
    }

    print(' [cancelarCita] Cancelando cita ID: ${cita.idCitas}');
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        // Enviamos la acción "borrar", que el PHP ahora interpreta como "cancelar"
        body: json.encode({'accion': 'cancelar', 'id_citas': cita.idCitas}),
      );

      print(' [cancelarCita] Código HTTP: ${response.statusCode}');
      print(' [cancelarCita] Respuesta: ${response.body}');

      final data = json.decode(response.body);
      if (data['success'] == true) {
        print(' [cancelarCita] Cita cancelada correctamente.');
        await fetchCitas(); // Recarga la lista de citas actualizadas
      } else {
        print(' [cancelarCita] Error: ${data['mensaje']}');
      }
    } catch (e) {
      print(' [cancelarCita] Error: $e');
    }
  }
}
