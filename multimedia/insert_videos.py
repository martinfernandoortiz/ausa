import os
from datetime import datetime

def sanitize_filename(filename):
    """
    Reemplaza caracteres problemáticos en el nombre del archivo.
    """
    return filename.replace("ñ", "n")

def replace_autopista_names(video_url):
    """
    Reemplaza nombres largos de autopistas por sus códigos.
    """
    replacements = {
        "Autopista 25 de mayo": "AU1",
        "Autopista Dellepiane": "AUD",
        "Autopista ILLIA": "AU2",
        "Autopista Perito Moreno": "AU6",
        "Autopista Presidente Arturo Frondizi": "AU9",
        "Autopista Presidente Hector Jose Campora": "AU7",
        "Paseo del bajo": "PDB",
    }
    for long_name, short_code in replacements.items():
        video_url = video_url.replace(long_name, short_code)
    return video_url

def generate_sql_for_videos(base_folder, base_url):
    """
    Genera los comandos SQL para insertar información sobre los videos.
    """
    sql_commands = []

    for root, _, files in os.walk(base_folder):
        for file in files:
            # Sanitizar el nombre del archivo
            sanitized_file = sanitize_filename(file)

            if sanitized_file.lower().endswith(('.mp4', '.mkv', '.avi', '.mov')):
                video_name, _ = os.path.splitext(sanitized_file)
                video_url = os.path.relpath(os.path.join(root, sanitized_file), base_folder).replace("\\", "/")

                # Aplicar los reemplazos en el video_url
                video_url = replace_autopista_names(video_url)

                try:
                    # Extraer la fecha y autopista
                    date_part = video_name[:6]
                    fecha = datetime.strptime(date_part, "%y%m%d").strftime("20%y-%m-%d")
                    autopista = video_name[7:10]

                    # Generar el comando SQL
                    sql = (
                        f"INSERT INTO usuarios.videos (video, video_url, fecha, autopista) "
                        f"VALUES ('{video_name}', '{video_url}', '{fecha}', '{autopista}');"
                    )
                    sql_commands.append(sql)
                except (ValueError, IndexError):
                    print(f"Error procesando el archivo: {sanitized_file}. Verifica su formato.")
    return sql_commands

def save_sql_to_file(sql_commands, output_file):
    """
    Guarda los comandos SQL generados en un archivo.
    """
    with open(output_file, "w", encoding="utf-8") as f:
        f.write("\n".join(sql_commands))
    print(f"SQL guardado en: {output_file}")

if __name__ == "__main__":
    # Configurar rutas y base URL
    base_folder = r"\\ausafs\Repositorio GIS\01-Recorridos GoPro\01-Videos\12-Gopro 9 Black\01-videos\FEB2024"
    base_url = "/mnt/servidor_archivos/videos"
    output_file = os.path.join(base_folder, "insert_videos.sql")

    # Generar y guardar los comandos SQL
    sql_commands = generate_sql_for_videos(base_folder, base_url)
    save_sql_to_file(sql_commands, output_file)
