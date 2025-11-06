<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

include 'Conexion.php';

// Leer JSON recibido desde Flutter
$input = json_decode(file_get_contents('php://input'), true);
error_log("Datos recibidos: " . json_encode($input));
$accion = $input['accion'] ?? '';

switch ($accion) {

    /* LISTAR CITAS CON DATOS DE CLIENTE */
   case 'listar':
    $sql = "SELECT c.id_citas, c.id_cliente, cl.nombre_cliente, cl.telefono, cl.correo,
                   c.id_empresario, c.fecha, c.hora, c.motivo, c.estado
            FROM citas c
            INNER JOIN clientes cl ON c.id_cliente = cl.id_cliente";

    $result = $conn->query($sql);

    $citas = []; 
    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $citas[] = [
                'id_citas' => (int)$row['id_citas'],
                'id_cliente' => (int)$row['id_cliente'],
                'id_empresario' => (int)$row['id_empresario'],
                'nombre_cliente' => (string)$row['nombre_cliente'],
                'telefono' => (string)$row['telefono'],
                'correo' => (string)$row['correo'],
                'motivo' => (string)$row['motivo'],
                'estado' => (string)$row['estado'],
                'fecha' => (string)$row['fecha'],
                'hora' => (string)$row['hora'],
            ];
        }
    }

    // si no hay resultados, devolver lista vacía
    echo json_encode(['success' => true, 'citas' => $citas]);
    break;


    /* AÑADIR NUEVO CLIENTE + CITA */
  case 'añadir':
    $nombre = $input['nombre_cliente'] ?? '';
    $telefono = $input['telefono'] ?? '';
    $correo = $input['correo'] ?? '';
    $motivo = $input['motivo'] ?? '';
    $estado = $input['estado'] ?? 'Pendiente';
    $fecha = $input['fecha'] ?? '';
    $hora = $input['hora'] ?? '';
    $id_empresario = $input['id_empresario'] ?? 2; // fijo por ahora

    // Validar campos
    if ($nombre == '' || $motivo == '' || $fecha == '' || $hora == '') {
        echo json_encode(['success' => false, 'mensaje' => 'Faltan campos obligatorios']);
        exit;
    }

    // Insertar cliente
    $stmt = $conn->prepare("INSERT INTO clientes (nombre_cliente, telefono, correo) VALUES (?, ?, ?)");
    if (!$stmt) {
        echo json_encode(['success' => false, 'mensaje' => 'Error en la preparación del cliente: ' . $conn->error]);
        exit;
    }
    $stmt->bind_param("sss", $nombre, $telefono, $correo);
    $stmt->execute();
    $id_cliente = $conn->insert_id;
    $stmt->close();

    error_log(" Datos recibidos en añadir: " . json_encode($input));
error_log(" Fecha: $fecha | Hora: $hora | Motivo: $motivo | Estado: $estado | Empresario: $id_empresario");


    // Insertar cita
    $stmt2 = $conn->prepare("INSERT INTO citas (id_cliente, id_empresario, fecha, hora, motivo, estado)
                            VALUES (?, ?, ?, ?, ?, ?)");
    if (!$stmt2) {
        echo json_encode(['success' => false, 'mensaje' => 'Error en la preparación de la cita: ' . $conn->error]);
        exit;
    }
    $stmt2->bind_param("iissss", $id_cliente, $id_empresario, $fecha, $hora, $motivo, $estado);

    if ($stmt2->execute()) {
        echo json_encode(['success' => true, 'mensaje' => 'Cliente y cita añadidos correctamente']);
    } else {
        echo json_encode(['success' => false, 'mensaje' => 'Error al añadir cita: ' . $stmt2->error]);
    }

    $stmt2->close();
    break;

    /*  MODIFICAR CITA Y CLIENTE */
    case 'modificar':
        $id_citas = $input['id_citas'] ?? 0;
        $id_cliente = $input['id_cliente'] ?? 0;
        $nombre = $input['nombre_cliente'] ?? '';
        $telefono = $input['telefono'] ?? '';
        $correo = $input['correo'] ?? '';
        $motivo = $input['motivo'] ?? '';
        $estado = $input['estado'] ?? '';
        $fecha = $input['fecha'] ?? '';
        $hora = $input['hora'] ?? '';

        if ($id_citas == 0 || $id_cliente == 0 || $motivo == '' || $fecha == '' || $hora == '') {
            echo json_encode(['success' => false, 'mensaje' => 'Faltan campos']);
            exit;
        }

        // 1️⃣ Actualizar cliente
        $stmt = $conn->prepare("UPDATE clientes SET nombre_cliente=?, telefono=?, correo=? WHERE id_cliente=?");
        $stmt->bind_param("sssi", $nombre, $telefono, $correo, $id_cliente);
        $stmt->execute();
        $stmt->close();

        // 2️⃣ Actualizar cita
        $stmt2 = $conn->prepare("UPDATE citas SET fecha=?, hora=?, motivo=?, estado=? WHERE id_citas=?");
        $stmt2->bind_param("ssssi", $fecha, $hora, $motivo, $estado, $id_citas);

        if ($stmt2->execute()) {
            echo json_encode(['success' => true, 'mensaje' => 'Cita y cliente modificados']);
        } else {
            echo json_encode(['success' => false, 'mensaje' => 'Error al modificar cita']);
        }

        $stmt2->close();
        break;

    /*  ELIMINAR CITA Y SU CLIENTE */
    case 'borrar':
        $id_citas = $input['id_citas'] ?? 0;

        if ($id_citas == 0) {
            echo json_encode(['success' => false, 'mensaje' => 'ID no válido']);
            exit;
        }

        // Buscar cliente asociado
        $res = $conn->query("SELECT id_cliente FROM citas WHERE id_citas = $id_citas");
        if ($res->num_rows == 0) {
            echo json_encode(['success' => false, 'mensaje' => 'Cita no encontrada']);
            exit;
        }
        $row = $res->fetch_assoc();
        $id_cliente = $row['id_cliente'];

        // 1️⃣ Eliminar cita
        $stmt = $conn->prepare("DELETE FROM citas WHERE id_citas=?");
        $stmt->bind_param("i", $id_citas);
        $stmt->execute();
        $stmt->close();

        // 2️⃣ Eliminar cliente vinculado
        $stmt2 = $conn->prepare("DELETE FROM clientes WHERE id_cliente=?");
        $stmt2->bind_param("i", $id_cliente);

        if ($stmt2->execute()) {
            echo json_encode(['success' => true, 'mensaje' => 'Cita y cliente eliminados']);
        } else {
            echo json_encode(['success' => false, 'mensaje' => 'Error al eliminar cliente']);
        }

        $stmt2->close();
        break;

    /* ACCIÓN NO VÁLIDA */
    default:
        echo json_encode(['success' => false, 'mensaje' => 'Acción no válida']);
        break;
}

$conn->close();
?>
