import os
import pandas as pd
import geopandas as gpd
from shapely import wkt

# Ruta de la carpeta con los CSV
CSV_FOLDER = "ruta/a/tu/carpeta"  # Cambia esto a la ruta de tu carpeta
PROCESSED_FOLDER = "ruta/a/carpeta_procesada"  # Carpeta donde guardarás los archivos únicos

# Crear carpeta de procesados si no existe
os.makedirs(PROCESSED_FOLDER, exist_ok=True)

# Función para procesar un archivo CSV
def process_csv(file_path, gdf_list):
    try:
        # Obtener el nombre del archivo y extraer timestamp
        file_name = os.path.basename(file_path)
        timestamp_str = file_name.split("_")[-1].replace(".csv", "")
        timestamp = pd.to_datetime(timestamp_str, format="%Y%m%d_%H%M%S")

        # Leer el archivo CSV
        df = pd.read_csv(file_path)

        # Convertir geometría a objetos Shapely
        if 'geometry' in df.columns:
            df['geometry'] = df['geometry'].apply(wkt.loads)

        # Crear un GeoDataFrame
        gdf = gpd.GeoDataFrame(df, geometry='geometry')

        # Agregar el campo timestamp
        gdf['timestamp'] = timestamp

        # Agregar al listado correspondiente
        gdf_list.append(gdf)

    except Exception as e:
        print(f"Error al procesar {file_path}: {e}")

# Función para calcular estadísticas y eliminar duplicados
def aggregate_and_deduplicate(gdf, group_by_field="unique_id"):
    if gdf.empty:
        return gdf

    try:
        # Asegurar que timestamp esté en formato datetime
        gdf['timestamp'] = pd.to_datetime(gdf['timestamp'])

        # Calcular estadísticas agrupadas por el campo `unique_id`
        aggregated = (
            gdf.groupby(group_by_field)
            .agg(
                min_speedKMH=('speedKMH', 'min'),
                max_speedKMH=('speedKMH', 'max'),
                avg_speedKMH=('speedKMH', 'mean'),
                min_delay=('delay', 'min'),
                max_delay=('delay', 'max'),
                avg_delay=('delay', 'mean'),
                min_length=('length', 'min'),
                max_length=('length', 'max'),
                avg_length=('length', 'mean'),
                start_time=('timestamp', 'min'),
                end_time=('timestamp', 'max'),
            )
            .reset_index()
        )

        # Calcular la duración del evento en segundos
        aggregated['event_duration_sec'] = (aggregated['end_time'] - aggregated['start_time']).dt.total_seconds()

        # Mergear con las geometrías originales (si es necesario)
        gdf_unique = gdf.drop_duplicates(subset=[group_by_field]).set_index(group_by_field)
        aggregated = aggregated.set_index(group_by_field)
        result = aggregated.join(gdf_unique[['geometry']]).reset_index()

        return result

    except Exception as e:
        print(f"Error al agregar estadísticas: {e}")
        return gdf

# Función principal para procesar los CSV
def combine_and_process_csv():
    # Listados para almacenar los GeoDataFrames por tipo
    points_list = []
    jams_list = []
    irregularities_list = []

    # Iterar sobre los archivos en la carpeta
    for file_name in os.listdir(CSV_FOLDER):
        file_path = os.path.join(CSV_FOLDER, file_name)

        if not file_name.endswith(".csv"):
            continue

        # Clasificar el archivo según el prefijo
        if "points" in file_name:
            process_csv(file_path, points_list)
        elif "jams" in file_name:
            process_csv(file_path, jams_list)
        elif "irregularities" in file_name:
            process_csv(file_path, irregularities_list)

    # Combinar, agregar estadísticas y eliminar duplicados por tipo
    if points_list:
        points_gdf = gpd.GeoDataFrame(pd.concat(points_list, ignore_index=True))
        points_gdf = aggregate_and_deduplicate(points_gdf)
        points_gdf.to_csv(os.path.join(PROCESSED_FOLDER, "processed_points.csv"), index=False)
        print(f"Puntos procesados guardados en processed_points.csv")

    if jams_list:
        jams_gdf = gpd.GeoDataFrame(pd.concat(jams_list, ignore_index=True))
        jams_gdf = aggregate_and_deduplicate(jams_gdf)
        jams_gdf.to_csv(os.path.join(PROCESSED_FOLDER, "processed_jams.csv"), index=False)
        print(f"Jams procesados guardados en processed_jams.csv")

    if irregularities_list:
        irregularities_gdf = gpd.GeoDataFrame(pd.concat(irregularities_list, ignore_index=True))
        irregularities_gdf = aggregate_and_deduplicate(irregularities_gdf)
        irregularities_gdf.to_csv(os.path.join(PROCESSED_FOLDER, "processed_irregularities.csv"), index=False)
        print(f"Irregularidades procesadas guardadas en processed_irregularities.csv")

# Ejecutar el script
combine_and_process_csv()
