#Itera
#Algunas cosas
# por las dudas crear env
#python3 -m venv videos
#activarlo
#source videos/bin/activate
#pip install ffmpeg-python

import os
import ffmpeg
import time

# Define el tamaño objetivo del archivo comprimido (en KB)
TARGET_SIZE_KB = 500 * 1000

def compress_video(video_full_path, output_file_name, target_size):
    """
    Comprime un archivo de video manteniendo una calidad adecuada basada en un tamaño objetivo
    y eliminando el audio.
    """
    try:
        # Obtiene información del video
        probe = ffmpeg.probe(video_full_path)
        duration = float(probe['format']['duration'])  # Duración del video en segundos

        # Calcula el bitrate total objetivo
        target_total_bitrate = (target_size * 1024 * 8) / (1.073741824 * duration)

        # Configura el bitrate del video (todo el bitrate se usa para el video)
        video_bitrate = target_total_bitrate

        # Ejecuta la compresión en dos pasadas, eliminando el audio
        i = ffmpeg.input(video_full_path)
        ffmpeg.output(
            i, os.devnull, **{'c:v': 'libx264', 'b:v': video_bitrate, 'pass': 1, 'f': 'mp4', 'an': None}
        ).overwrite_output().run()
        ffmpeg.output(
            i, output_file_name, **{'c:v': 'libx264', 'b:v': video_bitrate, 'pass': 2, 'an': None}
        ).overwrite_output().run()

        print(f"Compresión completada (sin audio): {output_file_name}")

    except ffmpeg.Error as e:
        print(f"Error al procesar el video {video_full_path}: {e.stderr.decode()}")

def process_videos(input_folder, output_folder, target_size):
    """
    Procesa todos los videos en la carpeta de entrada y los comprime, replicando la estructura de carpetas.
    """
    for root, _, files in os.walk(input_folder):
        # Construye la ruta relativa en la carpeta de salida
        relative_path = os.path.relpath(root, input_folder)
        output_subfolder = os.path.join(output_folder, relative_path)

        # Crea la carpeta correspondiente en el output si no existe
        os.makedirs(output_subfolder, exist_ok=True)

        for filename in files:
            input_path = os.path.join(root, filename)

            # Verifica si es un archivo de video
            if os.path.isfile(input_path) and filename.lower().endswith(('.mp4', '.mkv', '.avi', '.mov')):
                output_path = os.path.join(output_subfolder, filename)

                print(f"Procesando: {input_path}")
                start_time = time.time()

                # Comprime el video eliminando el audio
                compress_video(input_path, output_path, target_size)

                end_time = time.time()
                print(f"Tiempo de ejecución para {filename}: {end_time - start_time:.2f} segundos")
            else:
                print(f"Saltando: {input_path} (no es un archivo de video)")

if __name__ == "__main__":
    # Configura las carpetas de entrada y salida
    input_folder = "/home/videos/input"
    output_folder = "/home/videos/output"

    # Procesa los videos
    process_videos(input_folder, output_folder, TARGET_SIZE_KB)
