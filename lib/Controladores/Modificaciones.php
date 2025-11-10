<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Content-Type: application/json; charset=utf-8');

// Manejar preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Si se accede desde navegador o GET, muestra un mensaje simple
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    header('Content-Type: text/plain; charset=utf-8');
    echo "API de Modificaciones funcionando correctamente.\n";
    echo "Usa POST con JSON, por ejemplo:\n";
    echo '{ "accion": "listar" }';
    exit;
}

include 'Conexion.php';

$input = json_decode(file_get_contents('php://input'), true);
error_log("Datos recibidos (Bloqueos): " . json_encode($input));

$accion = $input['accion'] ?? '';

switch ($accion) {

    /* LISTAR BLOQUEOS */
    case 'listar':
        $sql = "SELECT * FROM bloqueos ORDER BY creado_en DESC";
        $result = $conn->query($sql);

        $bloqueos = [];
        if ($result && $result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                $bloqueos[] = [
                    'id_bloqueo'     => (int)$row['id_bloqueo'],
                    'titulo_bloqueo' => $row['titulo_bloqueo'] ?? '',
                    'tipo_bloqueo'   => $row['tipo_bloqueo'] ?? '',
                    'dia_semana'     => $row['dia_semana'] ?? '',
                    'fecha_unica'    => $row['fecha_unica'] ?? '',
                    'fecha_inicio'   => $row['fecha_inicio'] ?? '',
                    'fecha_final'    => $row['fecha_final'] ?? '',
                    'hora_inicio'    => $row['hora_inicio'] ?? '',
                    'hora_fin'       => $row['hora_fin'] ?? '',
                    'creado_en'      => $row['creado_en'] ?? '',
                ];
            }
        }

        echo json_encode(['success' => true, 'bloqueos' => $bloqueos]);
        break;

    /* AÑADIR BLOQUEO */
    case 'añadir':
        $titulo       = $input['titulo_bloqueo'] ?? null;
        $tipo         = $input['tipo_bloqueo'] ?? null;
        $dia          = $input['dia_semana'] ?? null;
        $fecha_unica  = $input['fecha_unica'] ?? null;
        $fecha_inicio = $input['fecha_inicio'] ?? null;
        $fecha_final  = $input['fecha_final'] ?? null;
        $hora_inicio  = $input['hora_inicio'] ?? null;
        $hora_fin     = $input['hora_fin'] ?? null;

        if (empty($titulo) || empty($tipo) || empty($hora_inicio) || empty($hora_fin)) {
            echo json_encode(['success' => false, 'mensaje' => 'Faltan campos obligatorios']);
            exit;
        }

        $stmt = $conn->prepare("
            INSERT INTO bloqueos 
            (titulo_bloqueo, tipo_bloqueo, dia_semana, fecha_unica, fecha_inicio, fecha_final, hora_inicio, hora_fin, creado_en)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ");

        if (!$stmt) {
            echo json_encode(['success' => false, 'mensaje' => 'Error preparando consulta: ' . $conn->error]);
            exit;
        }

        $stmt->bind_param(
            "ssssssss",
            $titulo,
            $tipo,
            $dia,
            $fecha_unica,
            $fecha_inicio,
            $fecha_final,
            $hora_inicio,
            $hora_fin
        );

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'mensaje' => 'Bloqueo añadido correctamente']);
        } else {
            echo json_encode(['success' => false, 'mensaje' => 'Error al añadir bloqueo: ' . $stmt->error]);
        }

        $stmt->close();
        break;

    /* ELIMINAR BLOQUEO */
    case 'eliminar':
        $id_bloqueo = $input['id_bloqueo'] ?? 0;

        if ($id_bloqueo == 0) {
            echo json_encode(['success' => false, 'mensaje' => 'ID no válido']);
            exit;
        }

        $stmt = $conn->prepare("DELETE FROM bloqueos WHERE id_bloqueo = ?");
        $stmt->bind_param("i", $id_bloqueo);

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'mensaje' => 'Bloqueo eliminado correctamente']);
        } else {
            echo json_encode(['success' => false, 'mensaje' => 'Error al eliminar bloqueo: ' . $stmt->error]);
        }

        $stmt->close();
        break;

    default:
        echo json_encode(['success' => false, 'mensaje' => 'Acción no válida']);
        break;
}

$conn->close();
?>
