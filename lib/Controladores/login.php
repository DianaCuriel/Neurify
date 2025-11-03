<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header('Content-Type: application/json');

include 'Conexion.php'; 

// Leer JSON recibido desde Flutter
$input = json_decode(file_get_contents('php://input'), true);
$usuario = $input['usuario'] ?? '';
$contraseña = $input['contraseña'] ?? '';

if ($usuario == '' || $contraseña == '') {
    echo json_encode(['success' => false, 'mensaje' => 'Campos vacíos']);
    exit;
}

// Preparar consulta para evitar inyecciones SQL
$stmt = $conn->prepare("SELECT id_credenciales, USER, rol, password FROM credenciales WHERE USER=? AND password=?");
$stmt->bind_param("ss", $usuario, $contraseña);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    echo json_encode([
        'success' => true,
        'mensaje' => 'Login exitoso',
        'usuario' => $user
    ]);
} else {
    echo json_encode([
        'success' => false,
        'mensaje' => 'Usuario o contraseña incorrectos'
    ]);
}

$stmt->close();
$conn->close();
?>
