<?php
header('Content-Type: application/json');

// Datos de conexión a la base de datos
$servername = "servidor-morales11.sytes.net"; // 192.168.1.200
// $port = 3306;
$username = "appmovil";
$password = "AppMovil2025!";
$dbname = "neurify_db";


// Conexión
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'mensaje' => 'Error de conexión a la BD']));
}

?>