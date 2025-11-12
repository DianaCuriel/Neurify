import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl =
    "http://servidor-morales11.sytes.net:5050/Modificaciones.php";

enum TipoModificacion { unica, rangoDiario, semanal }

class Modificacion {
  final int idBloqueo;
  final String titulo;
  final TipoModificacion tipo;
  final String? diaSemana;
  final DateTime? fechaUnica;
  final DateTime? fechaInicio;
  final DateTime? fechaFinal;
  final DateTime? horaInicio;
  final DateTime? horaFin;

  Modificacion({
    required this.idBloqueo,
    required this.titulo,
    required this.tipo,
    this.diaSemana,
    this.fechaUnica,
    this.fechaInicio,
    this.fechaFinal,
    this.horaInicio,
    this.horaFin,
  });

  factory Modificacion.fromJson(Map<String, dynamic> json) {
    debugPrint("----> [fromJson] Recibiendo JSON: $json");

    TipoModificacion tipo;
    switch (json['tipo_bloqueo']) {
      case 'Única':
        tipo = TipoModificacion.unica;
        break;
      case 'Semanal':
        tipo = TipoModificacion.semanal;
        break;
      default:
        tipo = TipoModificacion.rangoDiario;
    }

    final mod = Modificacion(
      idBloqueo: int.tryParse(json['id_bloqueo'].toString()) ?? 0,
      titulo: json['titulo_bloqueo'] ?? '',
      tipo: tipo,
      diaSemana: json['dia_semana'],
      fechaUnica: _parseDateTime(json['fecha_unica'], json['hora_inicio']),
      fechaInicio: _parseDateTime(json['fecha_inicio'], json['hora_inicio']),
      fechaFinal: _parseDateTime(json['fecha_final'], json['hora_fin']),
      horaInicio: _parseDateTime(null, json['hora_inicio']),
      horaFin: _parseDateTime(null, json['hora_fin']),
    );

    debugPrint("----> [fromJson] Objeto creado: ${mod.toJson()}");
    return mod;
  }

  Map<String, dynamic> toJson() {
    debugPrint("----> [toJson] Convirtiendo objeto a JSON");

    String? fechaUnicaStr = _getFecha(fechaUnica);
    String? horaUnicaStr = _getHora(fechaUnica);
    String? fechaInicioStr = _getFecha(fechaInicio);
    String? horaInicioStr = _getHora(horaInicio);
    String? fechaFinalStr = _getFecha(fechaFinal);
    String? horaFinalStr = _getHora(horaFin);

    final data = {
      'id_bloqueo': idBloqueo,
      'titulo_bloqueo': titulo,
      'tipo_bloqueo': _tipoToString(tipo),
      'dia_semana': diaSemana,
      'fecha_unica': fechaUnicaStr,
      'fecha_inicio': fechaInicioStr,
      'fecha_final': fechaFinalStr,
      'hora_inicio': horaInicioStr,
      'hora_fin': horaFinalStr,
    };

    debugPrint("----> [toJson] Resultado: $data");
    return data;
  }

  static String _tipoToString(TipoModificacion tipo) {
    switch (tipo) {
      case TipoModificacion.unica:
        return 'Única';
      case TipoModificacion.semanal:
        return 'Semanal';
      case TipoModificacion.rangoDiario:
        return 'Diario';
    }
  }

  static DateTime? _parseDateTime(dynamic fecha, dynamic hora) {
    debugPrint("----> [_parseDateTime] fecha=$fecha, hora=$hora");
    if ((fecha == null || fecha.toString().isEmpty) &&
        (hora == null || hora.toString().isEmpty)) {
      debugPrint("----> [_parseDateTime] Ambos valores nulos");
      return null;
    }

    final f =
        fecha != null && fecha.toString().isNotEmpty
            ? fecha.toString()
            : DateTime.now().toIso8601String().split('T')[0];

    final h =
        hora != null && hora.toString().isNotEmpty
            ? hora.toString()
            : "00:00:00";

    final dt = DateTime.tryParse("$f $h");
    debugPrint("----> [_parseDateTime] Resultado: $dt");
    return dt;
  }

  static String? _getFecha(DateTime? dt) =>
      dt == null ? null : dt.toIso8601String().split('T')[0];

  static String? _getHora(DateTime? dt) =>
      dt == null ? null : dt.toIso8601String().split('T')[1].split('.')[0];
}

class ModificacionesModel extends ChangeNotifier {
  final List<Modificacion> _modificaciones = [];

  List<Modificacion> get modificaciones => List.unmodifiable(_modificaciones);

  Future<void> fetchBloqueos() async {
    debugPrint("----> [fetchBloqueos] Iniciando petición a $apiUrl");
    try {
      final body = jsonEncode({'accion': 'listar'});
      debugPrint("----> [fetchBloqueos] Enviando body: $body");

      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint("----> [fetchBloqueos] Código respuesta: ${res.statusCode}");
      debugPrint("----> [fetchBloqueos] Respuesta: ${res.body}");

      final data = jsonDecode(res.body);
      if (data['success'] == true && data['bloqueos'] != null) {
        _modificaciones
          ..clear()
          ..addAll(
            (data['bloqueos'] as List)
                .map((b) => Modificacion.fromJson(b))
                .toList(),
          );
        debugPrint(
          "----> [fetchBloqueos] ${_modificaciones.length} bloqueos cargados",
        );
        notifyListeners();
      } else {
        debugPrint("----> [fetchBloqueos] Error: ${data['mensaje']}");
      }
    } catch (e, s) {
      debugPrint("----> [fetchBloqueos] Excepción: $e");
      debugPrint(s.toString());
    }
  }

  Future<void> addBloqueo(Modificacion mod) async {
    debugPrint("----> [addBloqueo] Iniciando envío de bloqueo nuevo");
    try {
      final data = {'accion': 'añadir', ...mod.toJson()};
      final body = jsonEncode(data);
      debugPrint("----> [addBloqueo] Body a enviar: $body");

      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint("----> [addBloqueo] Código respuesta: ${res.statusCode}");
      debugPrint("----> [addBloqueo] Respuesta: ${res.body}");

      final resp = jsonDecode(res.body);
      if (resp['success'] == true) {
        debugPrint("----> [addBloqueo] Añadido correctamente. Recargando...");
        await fetchBloqueos();
      } else {
        debugPrint("----> [addBloqueo] Error: ${resp['mensaje']}");
      }
    } catch (e, s) {
      debugPrint("----> [addBloqueo] Excepción: $e");
      debugPrint(s.toString());
    }
  }

  Future<void> removeBloqueo(int idBloqueo) async {
    debugPrint("----> [removeBloqueo] Eliminando id=$idBloqueo");
    try {
      final body = jsonEncode({'accion': 'eliminar', 'id_bloqueo': idBloqueo});
      debugPrint("----> [removeBloqueo] Body: $body");

      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint("----> [removeBloqueo] Código respuesta: ${res.statusCode}");
      debugPrint("----> [removeBloqueo] Respuesta: ${res.body}");

      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        _modificaciones.removeWhere((m) => m.idBloqueo == idBloqueo);
        debugPrint("----> [removeBloqueo] Eliminado correctamente");
        notifyListeners();
      } else {
        debugPrint("----> [removeBloqueo] Error: ${data['mensaje']}");
      }
    } catch (e, s) {
      debugPrint("----> [removeBloqueo] Excepción: $e");
      debugPrint(s.toString());
    }
  }

  Future<void> updateBloqueo(Modificacion mod) async {
    debugPrint(
      "----> [updateBloqueo] Iniciando actualización id=${mod.idBloqueo}",
    );
    try {
      final data = {'accion': 'actualizar', ...mod.toJson()};
      final body = jsonEncode(data);
      debugPrint("----> [updateBloqueo] Body a enviar: $body");

      final res = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint("----> [updateBloqueo] Código respuesta: ${res.statusCode}");
      debugPrint("----> [updateBloqueo] Respuesta: ${res.body}");

      final resp = jsonDecode(res.body);
      if (resp['success'] == true) {
        debugPrint(
          "----> [updateBloqueo] Actualizado correctamente. Recargando...",
        );
        await fetchBloqueos();
      } else {
        debugPrint("----> [updateBloqueo] Error: ${resp['mensaje']}");
      }
    } catch (e, s) {
      debugPrint("----> [updateBloqueo] Excepción: $e");
      debugPrint(s.toString());
    }
  }

  void clear() {
    debugPrint("----> [clear] Limpiando lista local");
    _modificaciones.clear();
    notifyListeners();
  }
}
