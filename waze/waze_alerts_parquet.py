import requests
import os
import pandas as pd
import schedule
import time
from datetime import datetime

# URL del archivo JSON
JSON_URL = "https://www.waze.com/row-partnerhub-api/partners/18865151823/waze-feeds/c73c7a3c-fe6d-4062-a225-1a379619d767?format=2-"

# Función para descargar el JSON
def fetch_json():
    try:
        print(f"[{datetime.now()}] Descargando JSON...")
        response = requests.get(JSON_URL)
        response.raise_for_status()

        if not response.content.strip():
            print(f"[{datetime.now()}] Error: La respuesta está vacía.")
            return None

        print(f"[{datetime.now()}] JSON descargado con éxito.")
        return response.json()
    except Exception as e:
        print(f"[{datetime.now()}] Error al descargar el JSON: {e}")
        return None

# Función para procesar puntos
def process_points(alerts):
    points_data = []

    for alert in alerts:
        if 'location' in alert:
            latitude = alert['location']['y']
            longitude = alert['location']['x']
            point = {
                'unique_id': alert.get('uuid', None),
                'geometry': f"POINT({longitude} {latitude})",
                **{key: alert.get(key, None) for key in alert.keys() if key != 'location'}
            }
            points_data.append(point)

    points_df = pd.DataFrame(points_data)
    return points_df

# Función para procesar líneas de irregularidades
def process_lines_irregularities(irregularities):
    lines_data = []

    for irregularity in irregularities:
        if 'line' in irregularity:
            # Generar la geometría de tipo LINESTRING
            coordinates = irregularity['line']
            line_string = "LINESTRING("
            line_string += ", ".join(f"{coord['x']} {coord['y']}" for coord in coordinates)
            line_string += ")"
            
            line = {
                'unique_id': irregularity.get('uuid', None),
                'geometry': line_string,
                **{key: irregularity.get(key, None) for key in irregularity.keys() if key != 'line'}
            }
            lines_data.append(line)

    lines_df = pd.DataFrame(lines_data)
    return lines_df

# Función para procesar líneas de jams
def process_lines_jams(jams):
    lines_data = []

    for jam in jams:
        if 'line' in jam:
            # Generar la geometría de tipo LINESTRING
            coordinates = jam['line']
            line_string = "LINESTRING("
            line_string += ", ".join(f"{coord['x']} {coord['y']}" for coord in coordinates)
            line_string += ")"
            
            line = {
                'unique_id': jam.get('uuid', None),
                'geometry': line_string,
                **{key: jam.get(key, None) for key in jam.keys() if key != 'line'}
            }
            lines_data.append(line)

    lines_df = pd.DataFrame(lines_data)
    return lines_df

# Función para guardar DataFrame en Parquet
def save_to_parquet(df, prefix, directory):
    if df.empty:
        print(f"[{datetime.now()}] No hay datos para guardar en {prefix}.")
        return

    try:
        # Crear el directorio si no existe
        os.makedirs(directory, exist_ok=True)
        
        # Generar un nombre único usando la marca de tiempo
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_name = f"{prefix}_{timestamp}.parquet"
        file_path = os.path.join(directory, file_name)
        
        # Guardar el DataFrame en formato Parquet
        df.to_parquet(file_path, index=False)
        print(f"[{datetime.now()}] Datos guardados en {file_path}.")
    except Exception as e:
        print(f"[{datetime.now()}] Error al guardar {prefix} en Parquet: {e}")
        


# Función principal
def run_task():
    print(f"[{datetime.now()}] Iniciando tarea...")
    data = fetch_json()
    if not data:
        print("No se pudo procesar el JSON.")
        return
    #Directorios
    points_directory = "waze_points"
    irregularities_directory = "waze_lines_irregularities"
    jams_directory = "waze_lines_jams"
    
    # Extraer datos del JSON
    alerts = data.get('alerts', [])
    irregularities = data.get('irregularities', [])
    jams = data.get('jams', [])

    # Procesar y guardar puntos
    points_df = process_points(alerts)
    save_to_parquet(points_df, "waze_points", points_directory)

    # Procesar y guardar líneas de irregularidades
    lines_df_irregularities = process_lines_irregularities(irregularities)
    save_to_parquet(lines_df_irregularities, "waze_lines_irregularities",irregularities_directory)

    # Procesar y guardar líneas de jams
    lines_df_jams = process_lines_jams(jams)
    save_to_parquet(lines_df_jams, "waze_lines_jams",jams_directory)

# Programar la tarea
schedule.every(5).minutes.do(run_task)

print("Iniciando el script...")
run_task()  # Primera ejecución inmediata

while True:
    schedule.run_pending()
    time.sleep(1)
