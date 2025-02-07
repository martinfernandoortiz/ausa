# Waze
## Sets de scripts para procesar el feed de waze

### waze_script.py
Parsea el xml y genera alerts, jams e irregularities. <br>
Se ejecuta cada 5 minutos con un crontab. Para configurarlo:<br>
` crontab -e ` <br>
` */5 * * * * /bin/bash -c 'source /home/waze/bin/activate && python /home/waze/waze_script.py' ` <br>

El resultado de esto son muchos archivos diarios. 

### waze_unificar.py
Unifica todos los archivos descargados, borra y va nucleando toda la información en un solo lugar. El crontab se ejecuta 23:56
`57 23 * * * /bin/bash -c 'source /home/waze/bin/activate && python3 /home/waze/waze_unificar.py'`

Esto unifica todos los archivos diarios creando tres grandes archivos raw  en donde se guardan todos los datos.


### inyect.py
Este archivo empieza a sintetizar la información ya que hay repetidos. Va haciendo "agregaciones" por id, y sacando estadisticas min, max y mediana, y geometria.
A su vez, hace insert into a la base de datos al esquema waze.
Por ultimo, los datos que fueron insertados en la base de datos, son eliminados del archivo raw.
