<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit; }

include 'Conexion.php';

const SECRET_KEY = 'mi_clave_secreta'; 

$raw = file_get_contents('php://input');
$input = json_decode($raw, true);
if (!is_array($input)) {
  http_response_code(400);
  echo json_encode(['success' => false, 'mensaje' => 'JSON inválido']);
  exit;
}

$usuario    = trim($input['usuario'] ?? '');
$contrasena = trim($input['contraseña'] ?? '');

if ($usuario === '' || $contrasena === '') {
  echo json_encode(['success' => false, 'mensaje' => 'Campos vacíos']);
  exit;
}

try {
  $sql = "
    SELECT id_credenciales, usuario, rol
    FROM credenciales
    WHERE usuario = ?
      AND contraseña = AES_ENCRYPT(?, ?)
    LIMIT 1
  ";

  $stmt = $conn->prepare($sql);
  if (!$stmt) throw new Exception('Error al preparar: '.$conn->error);

  $secret = SECRET_KEY;
  // orden: usuario, contraseñaPlano, clave
  $stmt->bind_param('sss', $usuario, $contrasena, $secret);

  if (!$stmt->execute()) throw new Exception('Error al ejecutar: '.$stmt->error);

  $res = $stmt->get_result();
  if ($res && $res->num_rows === 1) {
    $user = $res->fetch_assoc();
    echo json_encode(['success' => true, 'mensaje' => 'Login exitoso', 'usuario' => $user]);
  } else {
    echo json_encode(['success' => false, 'mensaje' => 'Usuario o contraseña incorrectos']);
  }

  $stmt->close();
  $conn->close();

} catch (Throwable $e) {
  http_response_code(500);
  echo json_encode(['success' => false, 'mensaje' => 'Error del servidor', 'detalle' => $e->getMessage()]);
}
 ?>