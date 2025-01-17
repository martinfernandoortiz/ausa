import os
import pandas as pd
import glob
from datetime import datetime

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
