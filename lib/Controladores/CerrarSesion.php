<?php
include 'conexion.php';
header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);
$id_usuario = $data["id_usuario"];

if ($id_usuario) {
    // Ejemplo: actualizar estado de sesión en la base de datos
    $sql = "UPDATE credenciales SET sesion_activa = 0 WHERE id_credenciales = '$id_usuario'";
    if (mysqli_query($conexion, $sql)) {
        echo json_encode(["success" => true, "mensaje" => "Sesión cerrada correctamente."]);
    } else {
        echo json_encode(["success" => false, "mensaje" => "Error al cerrar sesión."]);
    }
} else {
    echo json_encode(["success" => false, "mensaje" => "Faltan datos."]);
}
