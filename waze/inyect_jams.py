#pip install pandas pyarrow sqlalchemy psycopg2 shapely geopandas
import os
import pandas as pd
import pyarrow.parquet as pq
from sqlalchemy import create_engine
from datetime import datetime, timedelta
import geopandas as gpd
from shapely.geometry import shape
from shapely.wkb import loads


# Configuración de la base de datos PostgreSQL
DB_HOST = "172.25.92.12"
DB_NAME = "ausagis"
DB_USER = "postgres"
DB_PASSWORD = "Autopistas2024"
DB_SCHEMA = "waze"
DB_TABLE = "jams"

# Conexión a la base de datos
engine = create_engine(f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}")
"""

parquet_file = "/home/waze/data/sintesis/output_parquet/jams_geo.parquet"

# Leer el archivo Parquet
df = pd.read_parquet("/home/waze/data/sintesis/output_geoparquet/jams_geo.parquet")
df['speed'] = pd.to_numeric(df['speed'], errors='coerce')
df['level'] = pd.to_numeric(df['level'], errors='coerce')
df['length'] = pd.to_numeric(df['length'], errors='coerce')
df['delay'] = pd.to_numeric(df['delay'], errors='coerce')



# Convertir pub_date a datetime si no lo está
#df['pub_date'] = pd.to_datetime(df['pub_date'], format="%Y-%m-%d %H:%M:%S", errors='coerce', utc=True)
df['pub_date'] = pd.to_datetime(df['pub_date'], errors='coerce', utc=True)


# Obtener la fecha límite en UTC
fecha_limite = datetime.utcnow().replace(tzinfo=pd.Timestamp.utcnow().tz) - timedelta(days=2)


# Filtrar registros con más de 2 días de antigüedad
df_filtered = df[df['pub_date'] <= fecha_limite]



print(df_filtered.head())
print('#############################################################<br>#############################################################')
# Agregación de datos
def aggregate_data(group):
    max_length_rows = group.loc[group.groupby('id')['length'].idxmax()]

    return pd.Series({
        'pub_date': group['pub_date'].max(),  # Tomar la fecha más reciente
        'id': group['id'].iloc[0],            # Tomar el primer id
        'level': group['level'].iloc[0],      # Tomar el primer level
        'street': group['street'].iloc[0],    # Tomar la primera street
        'city': group['city'].iloc[0],        # Tomar la primera city
        'roadtype': group['roadtype'].iloc[0],# Tomar el primer roadtype
        'alertID': group['alertID'].iloc[0],  # Tomar el primer alertID
        'speed_min': group['speed'].min(),    # Mínimo de speed
        'speed_max': group['speed'].max(),    # Máximo de speed
        'speed_median': group['speed'].median(),  # Mediana de speed
        'length_min': group['length'].min(),  # Mínimo de length
        'length_max': group['length'].max(),  # Máximo de length
        'length_median': group['length'].median(),  # Mediana de length
        'delay_min': group['delay'].min(),    # Mínimo de delay
        'delay_max': group['delay'].max(),    # Máximo de delay
        'delay_median': group['delay'].median(),  # Mediana de delay
        'geom': group.loc[group['length'].idxmax(), 'geometry']  # Geometría con máximo length
    })

# Aplicar la agregación por iid
#df_aggregated = df_filtered.groupby('uuid', group_keys=False).apply(aggregate_data)
df_aggregated = df_filtered.groupby('uuid', group_keys=False).apply(aggregate_data).reset_index(drop=True)
df_aggregated["geom"] = df_aggregated["geom"].apply(lambda x: loads(x) if isinstance(x, (bytes, bytearray)) else x)

df_aggregated = gpd.GeoDataFrame(df_aggregated, geometry='geom')
"""
#print(df_aggregated.head())
#df_aggregated.to_parquet("output_geoparquet/borrar.parquet", engine='pyarrow')



df_aggregated = "/home/waze/data/sintesis/output_geoparquet/1_borrar.parquet"

# Leer el archivo Parquet
df_aggregated = pd.read_parquet(df_aggregated)
parquet_file = "/home/waze/data/sintesis/output_parquet/jams_geo.parquet"

# Leer el archivo Parquet
df = pd.read_parquet("/home/waze/data/sintesis/output_geoparquet/jams_geo.parquet")
# Insertar los datos agregados en la tabla de PostgreSQL
df_aggregated.to_sql(
    name=DB_TABLE,
    con=engine,
    schema=DB_SCHEMA,
    if_exists='append',  # Agregar datos sin eliminar los existentes
    index=False
)

# Eliminar los datos originales que se agregaron
iids_to_delete = df_aggregated['id'].unique()
df = df[~df['id'].isin(iids_to_delete)]

print("Datos Borrados")
df.to_parquet("output_geoparquet/jams_geo.parquet", engine='pyarrow')
print("Listorti")
