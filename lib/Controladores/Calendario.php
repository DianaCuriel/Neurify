<?php
header('Content-Type: application/json');
include 'Conexion.php';
// Leer JSON recibido desde Flutter
$input = json_decode(file_get_contents('php://input'), true);
$accion = $input['accion'] ?? '';

switch ($accion) {
    case 'listar': // Seleccionar todas las citas
        $result = $conn->query("SELECT * FROM citas");
        $citas = [];

        while ($row = $result->fetch_assoc()) {
            // Combinar fecha y hora en un solo campo datetime 
            $row['fechaHora'] = $row['fecha'] . ' ' . $row['hora'];
            unset($row['fecha']);
            unset($row['hora']);
            $citas[] = $row;
        }

        echo json_encode(['success' => true, 'citas' => $citas]);
        break;

    case 'añadir': // Añadir nueva cita
        $id_cliente = $input['id_cliente'] ?? 0;
        $id_empresario = $input['id_empresario'] ?? 0;
        $motivo = $input['motivo'] ?? '';
        $estado = $input['estado'] ?? 'pendiente';
        $fechaHora = $input['fechaHora'] ?? '';

        if ($id_cliente == 0 || $id_empresario == 0 || $motivo == '' || $fechaHora == '') {
            echo json_encode(['success' => false, 'mensaje' => 'Faltan campos']);
            exit;
        }

        // Separar fecha y hora desde el formato ISO que manda Flutter
        $fecha = date('Y-m-d', strtotime($fechaHora));
        $hora = date('H:i:s', strtotime($fechaHora));

        $stmt = $conn->prepare("INSERT INTO citas (id_cliente, id_empresario, fecha, hora, motivo, estado) VALUES (?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("iissss", $id_cliente, $id_empresario, $fecha, $hora, $motivo, $estado);

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'mensaje' => 'Cita añadida', 'id' => $stmt->insert_id]);
        } else {
            echo json_encode(['success' => false, 'mensaje' => 'Error al añadir cita']);
        }

        $stmt->close();
        break;

    case 'modificar': // Modificar una cita existente
        $id_citas = $input['id_citas'] ?? 0;
        $id_cliente = $input['id_cliente'] ?? 0;
        $id_empresario = $input['id_empresario'] ?? 0;
        $motivo = $input['motivo'] ?? '';
        $estado = $input['estado'] ?? '';
        $fechaHora = $input['fechaHora'] ?? '';

        if ($id_citas == 0 || $id_cliente == 0 || $id_empresario == 0 || $motivo == '' || $fechaHora == '') {
            echo json_encode(['success' => false, 'mensaje' => 'Faltan campos']);
            exit;
        }

        $fecha = date('Y-m-d', strtotime($fechaHora));
        $hora = date('H:i:s', strtotime($fechaHora));

        $stmt = $conn->prepare("UPDATE citas SET id_cliente=?, id_empresario=?, fecha=?, hora=?, motivo=?, estado=? WHERE id_citas=?");
        $stmt->bind_param("iissssi", $id_cliente, $id_empresario, $fecha, $hora, $motivo, $estado, $id_citas);

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'mensaje' => 'Cita modificada']);
        } else {
            echo json_encode(['success' => false, 'mensaje' => 'Error al modificar cita']);
        }

        $stmt->close();
        break;

    case 'borrar': 
        $id_citas = $input['id_citas'] ?? 0;

        if ($id_citas == 0) {
            echo json_encode(['success' => false, 'mensaje' => 'ID no válido']);
            exit;
        }

        $stmt = $conn->prepare("DELETE FROM citas WHERE id_citas=?");
        $stmt->bind_param("i", $id_citas);

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'mensaje' => 'Cita borrada']);
        } else {
            echo json_encode(['success' => false, 'mensaje' => 'Error al borrar cita']);
        }

        $stmt->close();
        break;

    default:
        echo json_encode(['success' => false, 'mensaje' => 'Acción no válida']);
        break;
}

$conn->close();
?>
