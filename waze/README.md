# Waze
## Sets de scripts para procesar el feed de waze

### waze_script.py
Parsea el xml y genera alerts, jams e irregularities. <br>
Se ejecuta cada 5 minutos con un crontab. Para configurarlo:<br>
` crontab -e ` <br>
` */5 * * * * /bin/bash -c 'source /home/waze/bin/activate && python /home/waze/waze_script.py' ` <br>

### waze_unificar.py
Unifica todos los archivos descargados, borra y va nucleando toda la información en un solo lugar. El crontab se ejecuta 23:56
`57 23 * * * /bin/bash -c 'source /home/waze/bin/activate && python3 /home/waze/waze_unificar.py'`

