import os
from datetime import datetime

def generate_sql_for_videos(base_folder, base_url):
    sql_commands = []

    for root, dirs, files in os.walk(base_folder):
        for file_name in files:
            if file_name.lower().endswith(('.mp4', '.mkv', '.avi', '.mov')):  # Filtrar solo videos
                try:
                    # Extraer partes del nombre del archivo
                    name_without_extension = os.path.splitext(file_name)[0]
                    
                    # Validar si los primeros 6 caracteres son una fecha
                    date_part = name_without_extension[:6]
                    autopista_part = name_without_extension[7:10]

                    if len(date_part) == 6 and date_part.isdigit():
                        fecha = datetime.strptime(date_part, "%y%m%d").strftime("20%y-%m-%d")
                    else:
                        print(f"Saltando archivo no válido para fecha: {file_name}")
                        continue

                    # Construir el video_url y el comando SQL
                    video_url = os.path.relpath(os.path.join(root, file_name), base_folder).replace("\\", "/")
                    video_url = f"{base_url}/{video_url}"

                    sql_command = f"INSERT INTO usuarios.videos (video, video_url, fecha, autopista) " \
                                  f"VALUES ('{name_without_extension}', '{video_url}', '{fecha}', '{autopista_part}');"
                    sql_commands.append(sql_command)

                except Exception as e:
                    print(f"Error procesando el archivo {file_name}: {e}")

    return sql_commands


# Configuración de la carpeta base y la URL base
base_folder = r"\\ausafs\Repositorio GIS\01-Recorridos GoPro\01-Videos\12-Gopro 9 Black\01-videos\FEB2024"
base_url = "https://proweb.ausa.com.ar/videos"

# Generar las sentencias SQL
sql_commands = generate_sql_for_videos(base_folder, base_url)

# Guardar las sentencias SQL en un archivo
output_file = os.path.join(base_folder, "insert_videos.sql")
with open(output_file, "w") as file:
    file.write("\n".join(sql_commands))

print(f"Archivo SQL generado: {output_file}")
