<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include 'Conexion.php';
header('Content-Type: application/json');


$fecha_inicio = $_GET['fecha_inicio'] ?? '';
$fecha_fin = $_GET['fecha_fin'] ?? '';

if (!$fecha_inicio || !$fecha_fin) {
    echo json_encode([
        "estado" => "error",
        "mensaje" => "Faltan parámetros: fecha_inicio y fecha_fin"
    ]);
    exit;
}


$fecha_inicio = substr($fecha_inicio, 0, 10);
$fecha_fin = substr($fecha_fin, 0, 10);


$sql1 = "SELECT COUNT(*) AS total FROM citas
        WHERE DATE(fecha) BETWEEN ? AND ? AND estado='Confirmada'";
$stmt1 = $conn->prepare($sql1);
$stmt1->bind_param("ss", $fecha_inicio, $fecha_fin);
$stmt1->execute();
$confirmadas = $stmt1->get_result()->fetch_assoc()['total'] ?? 0;

$sql2 = "SELECT COUNT(*) AS total FROM citas
        WHERE DATE(fecha) BETWEEN ? AND ? AND estado='Cancelada'";
$stmt2 = $conn->prepare($sql2);
$stmt2->bind_param("ss", $fecha_inicio, $fecha_fin);
$stmt2->execute();
$canceladas = $stmt2->get_result()->fetch_assoc()['total'] ?? 0;


echo json_encode([
    "estado" => "ok",
    "datos" => [
        "confirmadas" => intval($confirmadas),
        "canceladas" => intval($canceladas)
    ]
]);
?>