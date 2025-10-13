# Video cut

Corta y divide los videos. Sirve para eliminar fuera de traza o en los casos donde en un video hay varios tramos. 


Funcionalidad Principal
Corte de Video (Base): Permite especificar un tiempo de inicio (-start) y/o un tiempo de finalización (-end) absolutos (en formato HH:MM:SS) para extraer un segmento del video.

División de Video (Split): Si se usa el argumento -split, divide el rango de tiempo especificado por -start y -end en dos archivos de salida distintos, nombrando cada uno con los argumentos -o1 y -o2.

Llamada a Script Secundario: Después de un corte (simple o dividido) exitoso, llama y ejecuta un script Python externo llamado clean_data.py, pasándole los nombres del video original, los tiempos de corte y los nombres de los nuevos videos como argumentos.

### Considerar
<li>Carpeta input: dispone el video en cuestión
<li>Carpeta video_cut: donde van a guardarse los videos editados
<li>Formato de tiempo: **HH:MM:SS** (ej. `00:01:30`).

### Ejemplo de ejecución en consola
Desde la carpeta gopro2geo
<li> ``` python + video_cut.py ```  Ejecución de python y archivo
<li> ``` <<nombredevideo.mp4>>
  ```
<li>-start 00:00:10  Segundos iniciales a removar
<li>-end 00:01:12 Duración máxima del video. Es decir al minuto 1 con 12 segundos el video se corta y elimina todo lo posterior
<li>-split 00:00:30 Divide al video en el segundo 30
<li>-o1 nombrevideo1.mp4 
<li>-o2 nombrevideo2.mp4

Ejemplo
''' python video_cut.py 240108-AU9-RAE-A-SUBIDACALIFORNIA.MP4 -start 00:00:15 -end 00:01:26 -split 00:00:58 -o1 240108-AU9-RAE-A-SUBIDACALIFORNIA.mp4 -o2 2240108-AU9-RAE-A-BAJADASUAREZ.mp4 ''' 



## ⚠️ Consideración Importante: Metadata

El script utiliza el modo de **copia de *stream*** (`-c copy`) de FFmpeg. Este método asegura una **velocidad máxima** y **cero pérdida de calidad** al evitar la recodificación.

Sin embargo, debido a este proceso, la **metadata original** (datos de la cámara, historial EXIF, etc.) **no se conserva** en los archivos de salida, sino que es reemplazada por nueva metadata de sistema (fecha de exportación, etc.).
