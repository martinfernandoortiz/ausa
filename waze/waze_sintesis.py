import os
import pandas as pd

def load_and_merge_parquets(folder_path):
    """
    Lee todos los archivos Parquet en la carpeta especificada y combina sus registros en un único DataFrame.
    Elimina registros duplicados.
    
    Parameters:
        folder_path (str): Ruta a la carpeta con los archivos Parquet.
        
    Returns:
        tuple: DataFrame con todos los registros (antes de eliminar duplicados),
               DataFrame sin duplicados.
    """
    all_data = []

    # Recorre todos los archivos en la carpeta
    for file_name in os.listdir(folder_path):
        file_path = os.path.join(folder_path, file_name)

        # Verifica que sea un archivo Parquet
        if os.path.isfile(file_path) and file_name.endswith(".parquet"):
            try:
                print(f"Leyendo archivo: {file_path}")
                data = pd.read_parquet(file_path)
                all_data.append(data)
            except Exception as e:
                print(f"Error leyendo {file_path}: {e}")

    # Combina todos los DataFrames en uno solo
    if all_data:
        combined_df = pd.concat(all_data, ignore_index=True)
        print(f"Total de registros combinados: {len(combined_df)}")
        
        # Crear una copia para todos los registros
        all_records_df = combined_df.copy()
        
        # Eliminar duplicados
        print("Eliminando duplicados...")
        unique_records_df = combined_df.drop_duplicates()
        print(f"Total de registros únicos: {len(unique_records_df)}")
        
        return all_records_df, unique_records_df
    else:
        print("No se encontraron archivos Parquet en la carpeta especificada.")
        return pd.DataFrame(), pd.DataFrame()  # Devuelve DataFrames vacíos si no hay datos

# Ruta a la carpeta con los archivos Parquet
folder_path = "/ruta/a/la/carpeta/con/parquets"

# Ejecuta la función
all_records_df, unique_records_df = load_and_merge_parquets(folder_path)

# Guarda los resultados si hay datos
if not all_records_df.empty:
    # Guardar todos los registros en CSV
    all_records_csv = "all_records.csv"
    all_records_df.to_csv(all_records_csv, index=False)
    print(f"Archivo con todos los registros guardado en {all_records_csv}.")
    
    # Guardar los registros únicos en CSV
    unique_records_csv = "unique_records.csv"
    unique_records_df.to_csv(unique_records_csv, index=False)
    print(f"Archivo con registros únicos guardado en {unique_records_csv}.")
    
    # Guardar los registros únicos en Parquet
    unique_records_parquet = "unique_records.parquet"
    unique_records_df.to_parquet(unique_records_parquet, index=False)
    print(f"Archivo combinado sin duplicados guardado en {unique_records_parquet}.")
else:
    print("No se generó ningún archivo porque no hay datos.")
