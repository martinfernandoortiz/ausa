<?php

// Script php para evitar la saturación del servidor kobo


// Para debugear
/*
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
*/

// Extiendo el límite de tiempo de ejecución, a pesar del Gateway timeout de AUSA
set_time_limit(600);

// Obtengo parámetros de conexión a la BBDD
require_once("../configurabd.inc.php");
require_once("../configuraktb.inc.php");
require_once("../funciones.inc.php");
require_once("./makePdf.php");
require_once("./getImages.php");
require_once("./manejarPermisos.php");
require_once("./makeZip.php");

// Valido parámetros de URL
if (isset($_REQUEST['api_id'])) {
    $apiID = $_REQUEST['api_id']; // Obtengo el valor de api_id
}

// Voy a la BBDD y me fijo la tabla en la cual insertar
try {
    $connection = new PDO(PDO_CONN, PDO_USR, PDO_PSW);

    $sql = 'SELECT * FROM formularios.forms WHERE activo=true AND api_id = :apiID';
    $stmt = $connection->prepare($sql);
    $stmt->bindParam(':apiID', $apiID, PDO::PARAM_INT);
    $stmt->execute();
    
    while ($row = $stmt->fetch()) {
        $formid = $row['id'];
        $form_name = $row['form_nombre'];
        $local_schema = $row['local_schema'];
        $local_table = $row['local_table'];
        $form_asset = $row['kb_asset'];
    }
    $connection = null;
} catch (PDOException $e) {
    die("Error message: " . $e->getMessage());
}

// Asigno permisos al usuario anónimo en KoboToolBox
$borrarpermiso1 = asignarPermisoVerForm($form_asset);
$borrarpermiso2 = asignarPermisoVerEnvios($form_asset);

// Inicializo cURL para descargar el JSON
$curl = curl_init();
curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 60); // Timeout en segundos
curl_setopt($curl, CURLOPT_TIMEOUT, 120); // Timeout en segundos
curl_setopt($curl, CURLOPT_URL, "https://kc.kobotoolbox.org/api/v1/data/".$apiID.".json");
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true); // Para guardar el JSON en una variable

// Envío headers con el token
$header = array();
$header[] = 'Content-length: 0';
$header[] = 'Content-type: application/json';
$header[] = 'Authorization: Token '.KB_TOKEN;
curl_setopt($curl, CURLOPT_HTTPHEADER, $header);

// Ejecutando cURL
$response = curl_exec($curl);
if ($response === false) {
    echo 'Ejecución de cURL fallida: ' . curl_error($curl) . '<br>';
    curl_close($curl);
    exit();
} else {
    echo 'Ejecución OK<br>';
}

// Defino la carpeta temporal donde se guardará el JSON
$tmpDir = __DIR__ . '/tmp'; // __DIR__ da el directorio actual donde está el archivo PHP

// Verifico si la carpeta "tmp" existe, si no, la creo
if (!is_dir($tmpDir)) {
    mkdir($tmpDir, 0777, true); // Crea la carpeta "tmp" si no existe
}

// Defino el nombre temporal para el archivo JSON dentro de la carpeta "tmp"
$tempFile = $tmpDir . '/kobo_data_' . $apiID . '.json';

/*
// Guardo el JSON en el archivo temporal
file_put_contents($tempFile, $response);
*/


// Leer el archivo JSON desde el servidor local en lugar de hacerlo directamente desde KoboToolBox
$decodedData = json_decode(file_get_contents($tempFile), true);
if (json_last_error() !== JSON_ERROR_NONE) {
    echo 'Error al decodificar JSON: ' . json_last_error_msg() . '<br>';
    unlink($tempFile); // Eliminar el archivo temporal
    exit();
}

// Si hay datos en la respuesta
if (count($decodedData)) {
    echo '<br>Respuesta de Kobo contiene datos.<br>';

    // Elimino todos los datos previos
    try {
        echo '<br>Se va a ejecutar el truncate table<br>';
        $connection = new PDO(PDO_CONN, PDO_USR, PDO_PSW);
        $sql_truncar = "TRUNCATE TABLE " . $local_schema . "." . $local_table . ";";
        $connection->exec($sql_truncar);
        echo 'Tabla truncada correctamente<br>';
        $connection = null;
    } catch (PDOException $e) {
        echo 'Error al truncar la tabla: ' . $e->getMessage() . '<br>';
    }

    // Procesar registros por lotes para evitar problemas de memoria (opcional)
    $batchSize = 100; // Procesar en lotes de 100 (ajustar según tus necesidades)
    $totalRecords = count($decodedData);
    $numBatches = ceil($totalRecords / $batchSize);

    for ($batch = 0; $batch < $numBatches; $batch++) {
        echo "Procesando lote " . ($batch + 1) . " de " . $numBatches . "<br>";
        
        $start = $batch * $batchSize;
        $end = min(($start + $batchSize), $totalRecords);

        $batchData = array_slice($decodedData, $start, $batchSize);

        foreach ($batchData as $cadaregistro) {
            $arr_values = array();
            foreach ($listacampos_kb as $cadacampokb) {
                if (array_key_exists($cadacampokb[0], $cadaregistro)) {
                    if ($cadacampokb[1] == 'num') {
                        $arr_values[] = $cadaregistro[$cadacampokb[0]] ?: 'null';
                    } elseif ($cadacampokb[1] == 'arr') {
                        $arr_values[] = "'".recursive_implode($cadaregistro[$cadacampokb[0]], ", ")."'";
                    } else {
                        $arr_values[] = "'".$cadaregistro[$cadacampokb[0]]."'";
                    }
                } else {
                    $arr_values[] = 'null';
                }
            }

            // Inserción en la base de datos
            try {
                $connection = new PDO(PDO_CONN, PDO_USR, PDO_PSW);
                $sql_insert = "INSERT INTO " . $local_schema . "." . $local_table . " (" . implode(', ', $listacampos_local) . ") 
                                VALUES (" . implode(', ', $arr_values) . ") ON CONFLICT DO NOTHING;";
                $connection->exec($sql_insert);
                echo 'Inserción de datos OK para el lote ' . ($batch + 1) . '<br>';
                $connection = null;
            } catch (PDOException $e) {
                echo 'Error al insertar en la base de datos: ' . $e->getMessage() . '<br>';
            }
        }
    }
} else {
    echo '<br>Respuesta de Kobo insatisfactoria:<br>' . $response . '<br>';
}

// Elimino el archivo temporal
unlink($tempFile);

// Actualizar vista materializada
try {
    $connection = new PDO(PDO_CONN, PDO_USR, PDO_PSW);
    $sql_update_vista = "REFRESH MATERIALIZED VIEW " . $local_schema . ".v_" . $local_table . " WITH DATA;";
    $connection->exec($sql_update_vista);
    $connection = null;
} catch (PDOException $e) {
    die("Error message: " . $e->getMessage());
}

// Mensaje de proceso completado
echo("Se procesaron los datos de <b>" . $local_schema . "." . $local_table . "</b><br>");

// Descarga y almacenado de adjuntos localmente
obtenerImagenes($apiID);

// Actualizar vista materializada luego de actualizar las imágenes
try {
    $connection = new PDO(PDO_CONN, PDO_USR, PDO_PSW);
    $sql_update_vista = "REFRESH MATERIALIZED VIEW " . $local_schema . ".v_" . $local_table . " WITH DATA;";
    $connection->exec($sql_update_vista);
    $connection = null;
} catch (PDOException $e) {
    die("Error message: " . $e->getMessage());
}

// Creación de los PDFs
hacerPdfs($apiID);

// Remuevo los permisos de acceso anónimo al KoboToolBox
quitarPermisos($form_asset, $borrarpermiso1);
quitarPermisos($form_asset, $borrarpermiso2);

// Mensaje al usuario
echo("<b>Listo</b><br><a href='javascript:window.close();'>Cerrar ventana</a>");

?>
