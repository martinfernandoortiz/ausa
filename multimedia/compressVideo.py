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
TARGET_SIZE_KB = 350 * 1000

def compress_video(video_full_path, output_file_name, target_size):
    """
    Comprime un archivo de video manteniendo una calidad adecuada basada en un tamaño objetivo.
    """
    min_audio_bitrate = 32000
    max_audio_bitrate = 256000

    try:
        # Obtiene información del video
        probe = ffmpeg.probe(video_full_path)
        duration = float(probe['format']['duration'])  # Duración del video en segundos
        audio_bitrate = float(
            next((s for s in probe['streams'] if s['codec_type'] == 'audio'), None)['bit_rate']
        )

        # Calcula el bitrate total objetivo
        target_total_bitrate = (target_size * 1024 * 8) / (1.073741824 * duration)

        # Ajusta el bitrate del audio
        if 10 * audio_bitrate > target_total_bitrate:
            audio_bitrate = target_total_bitrate / 10
            if audio_bitrate < min_audio_bitrate < target_total_bitrate:
                audio_bitrate = min_audio_bitrate
            elif audio_bitrate > max_audio_bitrate:
                audio_bitrate = max_audio_bitrate

        # Calcula el bitrate del video
        video_bitrate = target_total_bitrate - audio_bitrate

        # Ejecuta la compresión en dos pasadas
        i = ffmpeg.input(video_full_path)
        ffmpeg.output(
            i, os.devnull, **{'c:v': 'libx264', 'b:v': video_bitrate, 'pass': 1, 'f': 'mp4'}
        ).overwrite_output().run()
        ffmpeg.output(
            i, output_file_name, **{'c:v': 'libx264', 'b:v': video_bitrate, 'pass': 2, 'c:a': 'aac', 'b:a': audio_bitrate}
        ).overwrite_output().run()

        print(f"Compresión completada: {output_file_name}")

    except ffmpeg.Error as e:
        print(f"Error al procesar el video {video_full_path}: {e.stderr.decode()}")


def process_videos(input_folder, output_folder, target_size):
    """
    Procesa todos los videos en la carpeta de entrada y los comprime.
    """
    # Crea la carpeta de salida si no existe
    os.makedirs(output_folder, exist_ok=True)

    # Itera sobre los archivos en la carpeta de entrada
    for filename in os.listdir(input_folder):
        input_path = os.path.join(input_folder, filename)

        # Verifica si es un archivo de video (opcional: puedes agregar más extensiones)
        if os.path.isfile(input_path) and filename.lower().endswith(('.mp4', '.mkv', '.avi', '.mov')):
            output_path = os.path.join(output_folder, filename)

            print(f"Procesando: {input_path}")
            start_time = time.time()

            # Comprime el video
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
