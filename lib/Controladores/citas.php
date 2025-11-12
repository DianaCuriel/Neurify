<?php
header("Content-Type: application/json");
include_once 'conexion.php';

//1.0 - obtener los parametros
$fecha_inicio = $_GET['inicio'] ?? null;
$fecha_fin = $_GET['fin'] ?? null;
$estado = $_GET['estado'] ?? null;

//2.0 - consulta a la bd
$Consulta = "SELECT id,fecha,hora,estado FROM citas WHERE 1=1";
$parametros = [];

//3.0 - Filtro por fecha 
if($fecha_inicio){
  $Consulta .= " AND fecha >= ?";
  $parametros[] = $fecha_inicio;
}
if($fecha_fin){
  $Consulta .= " AND fecha <= ?";
  $parametros[] = $fecha_fin;
}

//4.0 - Filtro por estado
if($estado){
    $Consulta .= " AND estado = ?";
    $parametros[] = $estado;
}

//5.0 - preparar y ejecutar la consulta
$sentencia = $conexion->prepare($Consulta);

//5.1 - verificacion 
if($sentencia == false){
    http_response_code(500);
    echo json_encode(["error" => "Error en la preparación de la consulta,siuu"]);
    exit;
}

//6.0 - desempaquetar parametros
if(count($parametros)>0){
    $tipo = str_repeat("s", count($parametros));
    $sentencia-> bind_param($tipo, ...$parametros);
 }

 //7.0 - Ejecutar la consulta
 $sentencia->execute();
 $resultado = $sentencia->get_result();

//8.0 - Arreglo para almacenar las citas
$citas = [];

//9.0 - obtener los resultados
while($fila = $resultado->fetch_assoc()){
    $citas[] = $fila;
}
//10.0 - devolver los resultados en formato json
echo json_encode($citas);

?>