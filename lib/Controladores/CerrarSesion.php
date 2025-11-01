<?php
header('Content-Type: application/json');
include 'conexion.php'; // contiene $conn

// Verifica que la conexión esté activa
if ($conn && $conn->ping()) {
    $conn->close(); // 🔹 Cierra la conexión con MySQL
    echo json_encode([
        'success' => true,
        'mensaje' => 'Conexión cerrada correctamente.'
    ]);
} else {
    echo json_encode([
        'success' => false,
        'mensaje' => 'No hay conexión activa o ya está cerrada.'
    ]);
}
?>
