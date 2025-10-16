<?php
header('Content-Type: application/json');

// Datos de conexión a la base de datos
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "";

// Conexión
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'mensaje' => 'Error de conexión a la BD']));
}

// Obtener datos POST
$input = json_decode(file_get_contents('php://input'), true);
$usuario = $input['usuario'] ?? '';
$contraseña = $input['contraseña'] ?? '';

if ($usuario == '' || $contraseña == '') {
    echo json_encode(['success' => false, 'mensaje' => 'Usuario o contraseña vacíos']);
    exit();
}

// Preparar consulta
$stmt = $conn->prepare("SELECT id, usuario, correo, puntaje FROM usuario WHERE usuario=? AND contraseña=?");
$stmt->bind_param("ss", $usuario, $contraseña);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $datos = $result->fetch_assoc();
    echo json_encode(['success' => true, 'mensaje' => 'Login exitoso', 'datos' => $datos]);
} else {
    echo json_encode(['success' => false, 'mensaje' => 'Usuario o contraseña incorrectos']);
}

$stmt->close();
$conn->close();
?>