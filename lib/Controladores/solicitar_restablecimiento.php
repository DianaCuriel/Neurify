<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header('Content-Type: application/json');

require_once 'Conexion.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;
require 'vendor/autoload.php'; // PHPMailer vía Composer

try {
  $raw = file_get_contents('php://input');
  $data = json_decode($raw, true) ?? [];
  $correo = isset($data['correo']) ? trim($data['correo']) : '';

  if ($correo === '') {
    echo json_encode(['success' => false, 'mensaje' => 'El correo es obligatorio.']);
    exit;
  }

  // 1) Buscar id_credenciales por correo (empresario -> credenciales)
  $sql = "
    SELECT c.id_credenciales, e.correo
    FROM empresario e
    INNER JOIN credenciales c ON c.id_credenciales = e.id_credenciales
    WHERE e.correo = ?
    LIMIT 1
  ";
  $stmt = $conn->prepare($sql);
  $stmt->bind_param('s', $correo);
  $stmt->execute();
  $res = $stmt->get_result();

  // Respuesta neutra por seguridad
  if ($res->num_rows === 0) {
    echo json_encode([
      'success' => true,
      'mensaje' => 'Si el correo existe, te enviaremos un código de verificación.'
    ]);
    exit;
  }

  $row = $res->fetch_assoc();
  $idCredenciales = (int) $row['id_credenciales'];

  // 2) Borrar códigos previos (opcional) e insertar uno nuevo
  $del = $conn->prepare("DELETE FROM password_resets WHERE id_credenciales = ?");
  $del->bind_param('i', $idCredenciales);
  $del->execute();

  $codigo = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
  $expira = (new DateTime('+15 minutes'))->format('Y-m-d H:i:s');

  $ins = $conn->prepare("
    INSERT INTO password_resets (id_credenciales, email, code, expires_at)
    VALUES (?, ?, ?, ?)
  ");
  $ins->bind_param('isss', $idCredenciales, $correo, $codigo, $expira);
  $ins->execute();

  // 3) Enviar correo
  $mail = new PHPMailer(true);
  try {
    $mail->isSMTP();
    $mail->Host = 'smtp.tu-proveedor.com';
    $mail->SMTPAuth = true;
    $mail->Username = 'no-reply@tu-dominio.com';
    $mail->Password = 'TU_PASSWORD_SMTP';
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;

    $mail->setFrom('no-reply@tu-dominio.com', 'Neurify');
    $mail->addAddress($correo);

    $mail->isHTML(true);
    $mail->Subject = 'Código para restablecer tu contraseña';
    $mail->Body = "
      <p>Hola,</p>
      <p>Tu código para restablecer la contraseña es:</p>
      <h2 style='letter-spacing:3px;'>$codigo</h2>
      <p>Este código es válido por <b>15 minutos</b>.</p>
      <p>Si no solicitaste este cambio, ignora este mensaje.</p>
    ";

    $mail->send();
  } catch (Exception $e) {
    // Opcional: registrar error $e->getMessage()
  }

  echo json_encode([
    'success' => true,
    'mensaje' => 'Si el correo existe, te enviaremos un código de verificación.'
  ]);
} catch (Throwable $e) {
  echo json_encode(['success' => false, 'mensaje' => 'Error interno del servidor.']);
}
