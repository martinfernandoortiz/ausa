import os
import subprocess
import sys
import pandas as pd
from pandas import read_csv

from datetime import datetime, timedelta



# Configuración de carpetas
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_DIR = os.path.join(BASE_DIR, "input")
FRAMES_DIR = os.path.join(BASE_DIR, "frames")
GPS_DIR = os.path.join(BASE_DIR, "gps")
TOOLS_DIR = os.path.join(BASE_DIR, "tools")

# Rutas a herramientas
FFMPEG_PATH = os.path.join(TOOLS_DIR, "ffmpeg.exe")
EXIFTOOL_PATH = os.path.join(TOOLS_DIR, "exiftool.exe")



# Validar que existan las herramientas
if not os.path.isfile(FFMPEG_PATH):
    print(f"❌ No se encontró ffmpeg en {FFMPEG_PATH}")
    sys.exit(1)

if not os.path.isfile(EXIFTOOL_PATH):
    print(f"❌ No se encontró exiftool en {EXIFTOOL_PATH}")
    sys.exit(1)


# Crear carpeta de frames si no existe
os.makedirs(FRAMES_DIR, exist_ok=True)

# Buscar primer MP4 en carpeta input
videos = [f for f in os.listdir(INPUT_DIR) if f.lower().endswith(".mp4")]
if not videos:
    print("No hay videos en la carpeta 'input_2'.")
    exit(1)
video_path = os.path.join(INPUT_DIR, videos[0])
video_name = os.path.splitext(videos[0])[0]



# Extraer GPS con exiftool
gps_csv = os.path.join(GPS_DIR, f"{video_name}_gps.csv")
exif_cmd = [
    EXIFTOOL_PATH, "-n", "-ee",
    "-p", "$GPSDateTime,$GPSLongitude,$GPSLatitude,$GPSAltitude,$GPSSpeed,$GPSSpeed3D",
    video_path
]

print("📍 Extrayendo datos GPS...")
with open(gps_csv, "w") as f:
    subprocess.run(exif_cmd, stdout=f, check=True)

# Leer el CSV con pandas y renombrar columnas
df = read_csv(gps_csv, header=None)
df.columns = ['fecha', 'lon', 'lat', 'alt', 'vel', 'vel3d']
df['fecha_dt'] = pd.to_datetime(df['fecha'].str.strip(), format="%Y:%m:%d %H:%M:%S.%f")
# Calcular el start_time
start_time = df['fecha_dt'].iloc[0]

# Calcular el offset y formatearlo como HH:MM:SS.ssssss
df['time'] = (df['fecha_dt'] - start_time).apply(lambda x: str(x).split(' ')[-1])



#start_time = datetime.strptime(df['fecha'].iloc[0].strip(), "%Y:%m:%d %H:%M:%S.%f")
df.to_csv(gps_csv, index=False)


gps_csv_path = os.path.join(GPS_DIR, f"{video_name}_gps.csv")

# Leer el archivo CSV con encabezado
df = pd.read_csv(gps_csv_path)
if 'fecha' not in df.columns:
    print("❌ La columna 'fecha' no se encuentra en el archivo CSV.")
    exit(1)

# Obtener el primer timestamp como referencia (tiempo cero)
try:
    start_time = datetime.strptime(df['fecha'].iloc[0].strip(), "%Y:%m:%d %H:%M:%S.%f")
except Exception as e:
    print(f"❌ Error al procesar el primer timestamp: {df['fecha'].iloc[0]} → {e}")
    exit(1)



# Iterar sobre las fechas ajustadas
for i, timestamp in enumerate(df['time']):
    try:
       
        time_str = timestamp
        name_file = str(time_str).split(' ')[-1].replace(':', '_')[:11]
        #time_str = str(timedelta(seconds=int(time_offset.total_seconds())))

        


        frame_output = os.path.join(FRAMES_DIR, f"{video_name}_{name_file}.png")
        if os.path.exists(frame_output):
            os.remove(frame_output)

        # Comando ffmpeg
        ffmpeg_cmd = [FFMPEG_PATH, "-ss", time_str, "-i", video_path, "-frames:v", "1", frame_output]
        #print("Running command:", " ".join(ffmpeg_cmd))
        subprocess.run(ffmpeg_cmd, check=True)  # Descomentar para ejecutar

        '''
        exif_cmd = [
            os.path.join(TOOLS_DIR, "exiftool.exe"),
            f"-DateTimeOriginal={current_time.strftime('%Y:%m:%d %H:%M:%S')}",
            f"-GPSLatitude={df['lat'].iloc[i]}",
            f"-GPSLongitude={df['lon'].iloc[i]}",
            f"-GPSAltitude={df['"alt'].iloc[i]}",
            "-overwrite_original",
            frame_output
        ]
        subprocess.run(exif_cmd, check=True)
        '''

    except Exception as e:
        print(f"❌ Error en línea {i}: {timestamp} → {e}")
