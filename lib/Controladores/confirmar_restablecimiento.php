<?php
header('Content-Type: application/json');
require_once 'Conexion.php';

try {
  $raw = file_get_contents('php://input');
  $data = json_decode($raw, true);

  $correo = trim($data['correo'] ?? '');
  $codigo = trim($data['codigo'] ?? '');
  $nueva  = $data['nueva_contrasena'] ?? '';

  if ($correo === '' || $codigo === '' || $nueva === '') {
    echo json_encode(['success' => false, 'mensaje' => 'Datos incompletos.']); exit;
  }

  // Buscar último reset válido
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
    echo json_encode(['success' => false, 'mensaje' => 'Código inválido.']); exit;
  }
  $row = $res->fetch_assoc();

  if (!is_null($row['used_at'])) {
    echo json_encode(['success' => false, 'mensaje' => 'Este código ya fue utilizado.']); exit;
  }
  if (new DateTime() > new DateTime($row['expires_at'])) {
    echo json_encode(['success' => false, 'mensaje' => 'El código ha expirado.']); exit;
  }

  $idCredenciales = (int)$row['id_credenciales'];

  // Hashear la contraseña (recomendado)
  $hash = password_hash($nueva, PASSWORD_DEFAULT);

  // Actualizar credenciales.password
  $upd = $conn->prepare("UPDATE credenciales SET password = ? WHERE id_credenciales = ?");
  $upd->bind_param('si', $hash, $idCredenciales);
  $upd->execute();

  // Marcar código como usado
  $used = $conn->prepare("UPDATE password_resets SET used_at = NOW() WHERE id = ?");
  $used->bind_param('i', $row['id']);
  $used->execute();

  echo json_encode(['success' => true, 'mensaje' => 'Contraseña actualizada correctamente.']);
} catch (Throwable $e) {
  echo json_encode(['success' => false, 'mensaje' => 'Error interno del servidor.']);
}
