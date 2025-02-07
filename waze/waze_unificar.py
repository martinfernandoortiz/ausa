import os
import pandas as pd
import glob
from datetime import datetime
import geopandas as gpd
from shapely.geometry import Point, LineString




# Directorios donde están los archivos generados
alerts_folder = '/home/waze/data/alerts/'
jams_folder = '/home/waze/data/jams/'
irregularities_folder = '/home/waze/data/irregularities/'


# Carpeta de destino para los archivos sintetizados
sintesis_folder = '/home/waze/data/sintesis/'

# Función para leer todos los archivos Parquet de una carpeta y combinarlos en un DataFrame
def combine_files(folder_path):
    # Buscar todos los archivos Parquet en el directorio
    parquet_files = glob.glob(os.path.join(folder_path, "*.parquet"))
    
    # Si hay archivos Parquet, combinarlos en un solo DataFrame
    if parquet_files:
        # Leer y concatenar todos los archivos Parquet
        df_list = [pd.read_parquet(file) for file in parquet_files]
        combined_df = pd.concat(df_list, ignore_index=True)
        return combined_df
    else:
        return pd.DataFrame()  # Retornar un DataFrame vacío si no hay archivos

# Función para guardar el DataFrame combinado como un archivo Parquet
def save_parquet(df, folder, prefix):
    if not df.empty:
        # Crear el nombre del archivo con la fecha actual
        timestamp = datetime.now().strftime("%Y%m%d")
        file_name = f"{prefix}_{timestamp}.parquet"
        file_path = os.path.join(folder, file_name)
        
        # Guardar el DataFrame como un archivo Parquet
        df.to_parquet(file_path, index=False)
        print(f"Archivo Parquet guardado: {file_path}")
        return True
    return False

# Función para eliminar archivos originales Parquet
def delete_files(folder_path):
    # Buscar todos los archivos Parquet en la carpeta
    parquet_files = glob.glob(os.path.join(folder_path, "*.parquet"))
    
    for file in parquet_files:
        try:
            os.remove(file)
            print(f"Archivo eliminado: {file}")
        except Exception as e:
            print(f"Error al eliminar el archivo {file}: {e}")

# Función principal para procesar y sintetizar los archivos
def main():
    # Combinar los archivos por tipo
    print("Combinando archivos de alertas...")
    alerts_df = combine_files(alerts_folder)
    print(f"Se combinaron {len(alerts_df)} registros de alertas.")
    
    print("Combinando archivos de jams...")
    jams_df = combine_files(jams_folder)
    print(f"Se combinaron {len(jams_df)} registros de jams.")
    
    print("Combinando archivos de irregularidades...")
    irregularities_df = combine_files(irregularities_folder)
    print(f"Se combinaron {len(irregularities_df)} registros de irregularidades.")
    
    # Guardar los archivos combinados como Parquet en la carpeta de síntesis
    if save_parquet(alerts_df, sintesis_folder, "alerts"):
        delete_files(alerts_folder)
    
    if save_parquet(jams_df, sintesis_folder, "jams"):
        delete_files(jams_folder)
    
    if save_parquet(irregularities_df, sintesis_folder, "irregularities"):
        delete_files(irregularities_folder)

# Ejecutar el script
if __name__ == "__main__":
    main()

print('###################################################')
print('####### PARTE DOS DEL SCRIPT  #####################' )
print('###################################################')

print('###################################################')
print('####### IRREGULARITIES Y JAMS #####################' )
print('###################################################')

def parse_linestring(line_str):
    # Divide la cadena en valores individuales (tanto positivos como negativos)
    values = line_str.strip().split()
    
    # Verifica que haya un número par de valores (pares de lat long)
    if len(values) % 2 != 0:
        raise ValueError("La cadena no contiene un número par de coordenadas (lat long).")
    
    # Convierte los valores a flotantes y agrupa en pares (lat, long)
    coords = []
    for i in range(0, len(values), 2):
        try:
            lat = float(values[i])       # Convierte la latitud a float
            lon = float(values[i+1])     # Convierte la longitud a float
            coords.append((lon, lat))    # Shapely usa (x, y), que corresponde a (long, lat)
        except ValueError as e:
            raise ValueError(f"Error al convertir coordenadas: {values[i]}, {values[i+1]}") from e
    
    # Crea y retorna un objeto LineString
    return LineString(coords)

# Obtener la ruta del archivo Python que se está ejecutando
current_dir = os.path.dirname(os.path.abspath(__file__))

sintesis = current_dir + '/data/sintesis/'
# Definir la ruta relativa de la carpeta donde están los archivos Parquet
folder_path = os.path.join(sintesis, "")

# Cargar archivos según el tipo
#alerts_files = glob.glob(f"{folder_path}/alerts_*.parquet")
jams_files = glob.glob(f"{folder_path}/jams_*.parquet")
irregularities_files = glob.glob(f"{folder_path}/irregularities_*.parquet")

# Función para cargar y unir archivos
def load_and_concat_parquet(files):
    return pd.concat([pd.read_parquet(f) for f in files], ignore_index=True) if files else pd.DataFrame()

# Cargar los datos
jams_df = load_and_concat_parquet(jams_files)
irregularities_df = load_and_concat_parquet(irregularities_files)



# Verificar si 'jams_df' no está vacío antes de crear 'jams_gdf'
if not jams_df.empty:
    jams_df['geometry'] = jams_df['line'].apply(parse_linestring)
    jams_gdf = gpd.GeoDataFrame(jams_df, geometry='geometry', crs="EPSG:4326")
    # Convertir columnas numéricas a tipos adecuados
    #jams_df['magvar'] = pd.to_numeric(jams_df['magvar'], errors='coerce')
else:
    jams_gdf = gpd.GeoDataFrame()  # Definir un GeoDataFrame vacío en caso de que esté vacío

# Verificar si 'irregularities_df' no está vacío antes de crear 'irregularities_gdf'
if not irregularities_df.empty:
    irregularities_df['geometry'] = irregularities_df['line'].apply(parse_linestring)
    irregularities_gdf = gpd.GeoDataFrame(irregularities_df, geometry='geometry', crs="EPSG:4326")
    # Convertir columnas numéricas a tipos adecuados
    #irregularities_df['magvar'] = pd.to_numeric(irregularities_df['magvar'], errors='coerce')
else:
    irregularities_gdf = gpd.GeoDataFrame()  # Definir un GeoDataFrame vacío en caso de que esté vacío

# Guardar cada GeoDataFrame como archivos GeoParquet

if not jams_gdf.empty:
    jams_gdf.to_parquet("data/sintesis/output_geoparquet/raw_jams.parquet", engine='pyarrow')
    print("Archivo 'jams_geo.parquet' guardado.")
    
    for file in jams_files:
        try:
            os.remove(file)
            print(f"Eliminado: {file}")
        except Exception as e:
            print(f"Error al eliminar {file}: {e}")

        print("Jams diarios unificados")

if not irregularities_gdf.empty:
    irregularities_gdf.to_parquet("data/sintesis/output_geoparquet/raw_irregularities.parquet", engine='pyarrow')
    print("Archivo 'irregularities_geo.parquet' guardado.")

    for file in irregularities_files:
        try:
            os.remove(file)
            print(f"Eliminado: {file}")
        except Exception as e:
            print(f"Error al eliminar {file}: {e}")

    print("Irregularities diarias unificados")
    
    
    
    
print('###################################################')
print('####### PARTE TRES DEL SCRIPT  #####################' )
print('###################################################')

print('###################################################')
print('####### ALERTS #####################' )
print('###################################################')


alerts_files = glob.glob(f"{folder_path}/alerts_*.parquet")



# Función para cargar y unir archivos
def load_and_concat_parquet(files):
    return pd.concat([pd.read_parquet(f) for f in files], ignore_index=True) if files else pd.DataFrame()

# Cargar los datos
alerts_df = load_and_concat_parquet(alerts_files)

# Verifica las columnas de alerts_df para encontrar la columna correcta
#print(alerts_df.columns)  # Muestra todas las columnas
#print(alerts_df.head())   # Muestra las primeras filas para inspeccionar los datos

# Verifica si 'alerts_df' tiene la columna 'points' antes de continuar
if 'point' in alerts_df.columns:
    alerts_df[['lat', 'lon']] = alerts_df['point'].str.split(expand=True).astype(float)
    alerts_df['geometry'] = alerts_df.apply(lambda row: Point(row['lon'], row['lat']), axis=1)
    # Convertir columnas numéricas a tipos adecuados
    alerts_df['magvar'] = pd.to_numeric(alerts_df['magvar'], errors='coerce')
    alerts_df['confidence'] = pd.to_numeric(alerts_df['confidence'], errors='coerce')
    alerts_df['reliability'] = pd.to_numeric(alerts_df['reliability'], errors='coerce')

    #alerts_df['confidence'] = alerts_df['confidence'].astype(bytes)

    alerts_gdf = gpd.GeoDataFrame(alerts_df, geometry='geometry', crs="EPSG:4326")
else:
    print("La columna 'points' no se encuentra en alerts_df.")
    alerts_gdf = gpd.GeoDataFrame()  # Definir un GeoDataFrame vacío en caso de que esté vacío



# Guardar cada GeoDataFrame como archivos GeoParquet
if not alerts_gdf.empty:
    alerts_gdf.to_parquet("data/sintesis/output_geoparquet/raw_alerts.parquet", engine='pyarrow')
    for file in alerts_files:
        try:
            os.remove(file)
            print(f"Eliminado: {file}")
        except Exception as e:
            print(f"Error al eliminar {file}: {e}")

        print("Jams diarios unificados")
    print("Archivo 'alerts_geo.parquet' guardado.")
