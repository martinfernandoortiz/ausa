# Como adaptar las nubes para convertir a 3d tiles?

* Desde cloud compare exportar en format las 1.2
* En windows ejecutar consola OSG4Wshell .
* Desde la consola de osgeo ir al directorio donde se encuentra el archivo .las y copiar tanto el archivo config.py como el archivo config.json
* Ejecutar en la consola ``` python3 config.py nombreDeArchivo.las ```
* A partir de ahora vamos a utilizar el archivo de ``` python3 run_pipeline.py -i entrada.las -o salida.las -e EPSG:5348 ```
O sino desde el config json completamos los nombres de entrada salida y epsg y ejecutamos ``` pdal pipeline config.json ```

