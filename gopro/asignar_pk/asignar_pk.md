# Asignar pk
 
Se encarga de leer archivos CSV con datos GPS y cargar esos puntos georreferenciados en una tabla específica de una base de datos PostGIS, utilizando la librería GDAL/OGR. <br>

## Síntesis de la Funcionalidad
El script realiza los siguientes pasos principales:

### Configuración de Rutas
Define las carpetas de trabajo: gps (donde busca los archivos CSV de entrada) y old_processed_csv (donde mueve los archivos una vez procesados).

### Búsqueda de Archivos
Localiza todos los archivos CSV que terminan en _gps.csv dentro de la carpeta gps.

### Conexión a la Base de Datos
Establece una conexión con una base de datos PostGIS utilizando la cadena de conexión proporcionada (a host=xxxx, dbname=ausagis, etc.).

### Procesamiento de Datos

<li>Itera sobre cada archivo CSV encontrado.
<li>Abre el archivo y lo lee fila por fila.

#### Para cada fila:

<li>Extrae las coordenadas de longitud (lon) y latitud (lat).
<li>Crea un objeto geométrico de tipo Punto (Point) con esas coordenadas, asumiendo el sistema de referencia WGS84 (EPSG:4326).
<li>Crea un registro (feature) en la capa (gopro2geo.input_offline) de la base de datos.
<li>Copia todos los demás campos del CSV al registro de la base de datos, con manejo especial para el campo fecha (reemplazando dos puntos por guiones).
<li>Inserta el registro con la geometría en la tabla PostGIS.

### Limpieza
Tras procesar e insertar exitosamente los datos de un CSV, mueve ese archivo de la carpeta gps a la carpeta old_processed_csv.

### Finalización
Cierra la conexión a la base de datos al finalizar.

#########################################################################################################################

Al insertar en la base de datos se ejecuta un trigger que busca la pk más cercana.
Esto se puede ver en fn_asignar_pk.sql
