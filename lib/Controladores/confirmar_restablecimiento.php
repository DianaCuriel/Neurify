<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header('Content-Type: application/json');

require_once 'Conexion.php';

// Usa la MISMA clave que el Login (Opción AES_ENCRYPT)
$AES_SECRET = 'mi_clave_secreta';

try {
  $raw  = file_get_contents('php://input');
  $data = json_decode($raw, true) ?? [];

  $correo = trim($data['correo'] ?? '');
  $codigo = trim($data['codigo'] ?? '');
  $nueva  = $data['nueva_contrasena'] ?? '';

  if ($correo === '' || $codigo === '' || $nueva === '') {
    echo json_encode(['success' => false, 'mensaje' => 'Datos incompletos.']);
    exit;
  }

  // 1) Buscar el último código válido para ese correo
  $stmt = $conn->prepare("
    SELECT pr.id, pr.id_credenciales, pr.expires_at, pr.used_at
    FROM password_resets pr
    WHERE pr.email = ? AND pr.code = ?
    ORDER BY pr.id DESC
    LIMIT 1
  ");
  $stmt->bind_param('ss', $correo, $codigo);
  $stmt->execute();
  $res = $stmt->get_result();

  if ($res->num_rows === 0) {
    echo json_encode(['success' => false, 'mensaje' => 'Código inválido.']);
    exit;
  }

  $row = $res->fetch_assoc();

  if (!is_null($row['used_at'])) {
    echo json_encode(['success' => false, 'mensaje' => 'Este código ya fue utilizado.']);
    exit;
  }

  if (new DateTime() > new DateTime($row['expires_at'])) {
    echo json_encode(['success' => false, 'mensaje' => 'El código ha expirado.']);
    exit;
  }

  $idCredenciales = (int)$row['id_credenciales'];

  // 2) Actualizar contraseña C I F R A N D O con AES_ENCRYPT (columna `contraseña`)
  $upd = $conn->prepare("
    UPDATE credenciales
    SET `contraseña` = AES_ENCRYPT(?, ?)
    WHERE id_credenciales = ?
  ");
  $upd->bind_param('ssi', $nueva, $AES_SECRET, $idCredenciales);
  $upd->execute();

  // 3) Marcar el código como usado (o eliminar todos para ese usuario)
  $used = $conn->prepare("UPDATE password_resets SET used_at = NOW() WHERE id = ?");
  $used->bind_param('i', $row['id']);
  $used->execute();

  echo json_encode(['success' => true, 'mensaje' => 'Contraseña actualizada correctamente.']);
} catch (Throwable $e) {
  echo json_encode(['success' => false, 'mensaje' => 'Error interno del servidor.']);
}
