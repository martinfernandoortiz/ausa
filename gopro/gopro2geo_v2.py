import os
import subprocess
import csv
import sys

# Configuración de carpetas
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_DIR = os.path.join(BASE_DIR, "input")
FRAMES_DIR = os.path.join(BASE_DIR, "frames")
GPS_DIR = os.path.join(BASE_DIR, "gps")
KML_DIR = os.path.join(BASE_DIR, "kml")
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

# Crear carpetas necesarias
for folder in [FRAMES_DIR, GPS_DIR, KML_DIR]:
    os.makedirs(folder, exist_ok=True)

# Buscar primer MP4 en carpeta input
videos = [f for f in os.listdir(INPUT_DIR) if f.lower().endswith(".mp4")]
if not videos:
    print("No hay videos en la carpeta 'input'.")
    sys.exit(1)
video_path = os.path.join(INPUT_DIR, videos[0])
video_name = os.path.splitext(videos[0])[0]

print(f"📹 Procesando: {video_name}")

# 1️⃣ Extraer frames con ffmpeg (a 1 fps para no generar miles de imágenes)
frames_pattern = os.path.join(FRAMES_DIR, f"{video_name}_%05d.jpg")
ffmpeg_cmd = [
    FFMPEG_PATH, "-i", video_path,
    "-vf", "fps=1",  # puedes subir este valor si quieres más frames
    "-q:v", "2",     # calidad alta
    frames_pattern
]
print("🖼 Extrayendo frames...")
subprocess.run(ffmpeg_cmd, check=True)

# 2️⃣ Extraer GPS con exiftool (todos los puntos)
gps_csv = os.path.join(GPS_DIR, f"{video_name}_gps.csv")
exif_cmd = [
    EXIFTOOL_PATH, "-n", "-ee",
    "-p", "$GPSLongitude,$GPSLatitude,$GPSAltitude",
    video_path
]
print("📍 Extrayendo datos GPS...")
with open(gps_csv, "w") as f:
    subprocess.run(exif_cmd, stdout=f, check=True)

# 3️⃣ Leer GPS y generar KML (todos los puntos, con o sin imagen)
kml_path = os.path.join(KML_DIR, f"{video_name}.kml")

with open(gps_csv, newline="") as f:
    reader = csv.reader(f)
    gps_data = list(reader)

print("🗺 Generando KML con todos los puntos...")
with open(kml_path, "w", encoding="utf-8") as kml:
    kml.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    kml.write('<kml xmlns="http://www.opengis.net/kml/2.2">\n')
    kml.write('<Document>\n')

    for i, coords in enumerate(gps_data, start=1):
        if len(coords) != 3:
            continue
        lon, lat, alt = coords
        frame_file = f"{video_name}_{i:05d}.jpg"
        frame_path = os.path.abspath(os.path.join(FRAMES_DIR, frame_file))

        kml.write("  <Placemark>\n")
        kml.write(f"    <name>Punto {i}</name>\n")

        if os.path.exists(frame_path):
            kml.write(f"    <description><![CDATA[<img src=\"file:///{frame_path}\" width=\"400\"/>]]></description>\n")
        else:
            kml.write("    <description>Sin imagen disponible</description>\n")

        kml.write("    <Point>\n")
        kml.write(f"      <coordinates>{lon},{lat},{alt}</coordinates>\n")
        kml.write("    </Point>\n")
        kml.write("  </Placemark>\n")

    kml.write('</Document>\n')
    kml.write('</kml>\n')

print(f"✅ KML generado en: {kml_path}")
