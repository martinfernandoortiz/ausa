#pip install pandas, pyarrow, requests
import requests
import xml.etree.ElementTree as ET
import pandas as pd
from datetime import datetime
import time
import os

# URL del feed de Waze
FEED_URL = "https://www.waze.com/row-partnerhub-api/partners/18865151823/waze-feeds/c73c7a3c-fe6d-4062-a225-1a379619d767?format=2"

# Definir los namespaces
NAMESPACES = {
    'georss': 'http://www.georss.org/georss',
    'linqmap': 'http://www.linqmap.com'
}

# Función para descargar y parsear el XML con reintentos
def fetch_and_parse_xml(url, retries=3, delay=5):
    attempt = 0
    while attempt < retries:
        try:
            response = requests.get(url)
            if response.status_code == 200:
                return ET.fromstring(response.content)
            else:
                raise Exception(f"Error al descargar el XML. Código HTTP: {response.status_code}")
        except Exception as e:
            print(f"Error en intento {attempt + 1}: {e}")
            time.sleep(delay)
            attempt += 1
    raise Exception("No se pudo descargar el XML después de varios intentos.")

# Función para procesar alerts
def process_alerts(root):
    alerts = []
    for item in root.findall('.//item[title="alert"]', NAMESPACES):
        alert = {
            "pub_date": item.findtext('pubDate', ''),
            "point": item.findtext('georss:point', '', NAMESPACES),
            "uuid": item.findtext('linqmap:uuid', '', NAMESPACES),
            "magvar": item.findtext('linqmap:magvar', '', NAMESPACES),
            "type": item.findtext('linqmap:type', '', NAMESPACES),
            "subtype": item.findtext('linqmap:subtype', '', NAMESPACES),
            "street": item.findtext('linqmap:street', '', NAMESPACES),
            "city": item.findtext('linqmap:city', '', NAMESPACES),
            "country": item.findtext('linqmap:country', '', NAMESPACES),
            "municipality": item.findtext('linqmap:reportByMunicipalityUser', '', NAMESPACES),
            "roadtype": item.findtext('linqmap:roadType', '', NAMESPACES),
            "reportranking": item.findtext('linqmap:linqmap:reportRating', '', NAMESPACES),
            "confidence": item.findtext('confidence', ''),
            "reliability": item.findtext('linqmap:reliability', '', NAMESPACES),
        }
        alerts.append(alert)
    return pd.DataFrame(alerts)

# Función para procesar jams
def process_jams(root):
    jams = []
    for item in root.findall('.//item[title="jam"]', NAMESPACES):
        jam = {
            "pub_date": item.findtext('pubDate', ''),
            "type": item.findtext('linqmap:type', '',NAMESPACES),
            "line": item.findtext('georss:line', '', NAMESPACES),
            "id": item.findtext('linqmap:id', '', NAMESPACES),
            "uuid": item.findtext('linqmap:uuid', '', NAMESPACES),
            "speed": item.findtext('linqmap:speedKMH', '', NAMESPACES),
            "level": item.findtext('linqmap:level', '', NAMESPACES),
            "turn_type": item.findtext('linqmap:turnType', '', NAMESPACES),         
            "length": item.findtext('linqmap:length', '', NAMESPACES),
            "delay": item.findtext('linqmap:delay', '', NAMESPACES),
            "street": item.findtext('linqmap:street', '', NAMESPACES),
            "city": item.findtext('linqmap:city', '', NAMESPACES),
            "country": item.findtext('linqmap:country', '', NAMESPACES),
            "roadtype": item.findtext('linqmap:roadType', '', NAMESPACES),
            "alertID": item.findtext('linqmap:blockingAlertUuid', '', NAMESPACES),
        }
        jams.append(jam)
    return pd.DataFrame(jams)

# Función para procesar irregularities
def process_irregularities(root):
    irregularities = []
    for item in root.findall('.//item[title="irregularity"]', NAMESPACES):
        irregularity = {
            "iid": item.findtext('linqmap:id', '',NAMESPACES),
            "detection_date": item.findtext('detectionDate', ''),
            "detection_millis": item.findtext('detectionDateMillis', ''),
            "update_date": item.findtext('updateDate', ''),
            "update_millis": item.findtext('updateDateMillis', ''),            
            "line": item.findtext('georss:line', '', NAMESPACES),
            "type": item.findtext('linqmap:type', '', NAMESPACES),
            "traffic_speed": item.findtext('linqmap:speed', '', NAMESPACES),
            "regular_speed": item.findtext('linqmap:regularSpeed', '', NAMESPACES),
            "delay_seconds": item.findtext('linqmap:delaySeconds', '', NAMESPACES),
            "seconds": item.findtext('linqmap:seconds', '', NAMESPACES),            
            "length": item.findtext('linqmap:length', '', NAMESPACES),
            "trend": item.findtext('linqmap:trend', '', NAMESPACES),                                    
            "uuid": item.findtext('linqmap:uuid', '', NAMESPACES),
            "severity": item.findtext('linqmap:severity', '', NAMESPACES),
            "jam_level": item.findtext('linqmap:jamLevel', '', NAMESPACES),
            "drivers_count": item.findtext('linqmap:driversCount', '', NAMESPACES),
            "street": item.findtext('linqmap:street', '', NAMESPACES),
            "city": item.findtext('linqmap:city', '', NAMESPACES),
            "country": item.findtext('linqmap:country', '', NAMESPACES),
            "highway": item.findtext('linqmap:highway', '', NAMESPACES),
        }
        irregularities.append(irregularity)
    return pd.DataFrame(irregularities)

# Función para convertir fechas a un formato estándar
def convert_dates(df, date_columns):
    for col in date_columns:
        if col in df:
            print(f"Convirtiendo fechas en la columna {col}")
            df[col] = pd.to_datetime(df[col], errors='coerce', utc=True)
    return df

# Función para validar fechas antes de la conversión
def validate_dates(df, date_columns):
    for col in date_columns:
        if col in df:
            print(f"Validando fechas en la columna {col}")
            print(df[col].head())  # Muestra algunas fechas para validarlas
    return df

# Función para crear la carpeta si no existe
def create_folder(folder_name):
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)

# Función para guardar los archivos solo si el DataFrame no está vacío
def save_if_not_empty(df, folder, filename):
    if not df.empty:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        #df.to_csv(f"{folder}/{filename}_{timestamp}.csv", index=False)
        df.to_parquet(f"{folder}/{filename}_{timestamp}.parquet", index=False)
        print(f"Archivo {filename} guardado correctamente.")
    else:
        print(f"El DataFrame para {filename} está vacío, no se guardará.")

# Main
def main():
    # Descargar y parsear el XML
    root = fetch_and_parse_xml(FEED_URL)

    # Crear las carpetas para cada tipo de ítem
    create_folder("data/alerts")
    create_folder("data/jams")
    create_folder("data/irregularities")

    # Procesar cada tipo de dato
    print("Procesando alertas...")
    alerts_df = process_alerts(root)
    print(f"Se procesaron {len(alerts_df)} alertas.")
    save_if_not_empty(alerts_df, "/home/waze/data/alerts", "alerts")

    print("Procesando jams...")
    jams_df = process_jams(root)
    print(f"Se procesaron {len(jams_df)} jams.")
    save_if_not_empty(jams_df, "/home/waze/data/jams", "jams")

    print("Procesando irregularidades...")
    irregularities_df = process_irregularities(root)
    print(f"Se procesaron {len(irregularities_df)} irregularidades.")
    save_if_not_empty(irregularities_df, "/home/waze/data/irregularities", "irregularities")

    # Validar fechas antes de la conversión
    validate_dates(alerts_df, ["pub_date"])
    validate_dates(jams_df, ["pub_date"])
    validate_dates(irregularities_df, ["detection_date", "update_date"])

    # Convertir fechas
    alerts_df = convert_dates(alerts_df, ["pub_date"])
    jams_df = convert_dates(jams_df, ["pub_date"])
    irregularities_df = convert_dates(irregularities_df, ["detection_date", "update_date"])

    print("Procesamiento y exportación completados.")

if __name__ == "__main__":
    main()
