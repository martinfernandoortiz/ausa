from google.colab import drive
from moviepy.editor import VideoFileClip
import os

# Montar Google Drive
drive.mount('/content/drive')

def get_fixed_bitrate(target_size_mb, video_duration):
    """Calcula un bitrate fijo para alcanzar un tamaño objetivo."""
    target_size_bits = target_size_mb * 8 * 1024 * 1024  # Convertir MB a bits
    return int(target_size_bits / video_duration)  # Bitrate en bps

def video_compressor(input_path, output_path, target_resolution=(1280, 720), target_size_mb=50):
    """Comprime el video asegurando un tamaño y resolución objetivo."""
    # Obtener el clip de video
    vid_clip = VideoFileClip(input_path)
    video_duration = vid_clip.duration

    # Redimensionar el video
    resized_clip = vid_clip.resize(height=target_resolution[1])

    # Calcular un bitrate fijo para el tamaño deseado
    fixed_bitrate = get_fixed_bitrate(target_size_mb, video_duration)

    # Guardar el video comprimido
    resized_clip.write_videofile(
        output_path,
        bitrate=f"{fixed_bitrate}k",
        codec="libx264",
        preset="medium"  # Ajusta entre "ultrafast", "fast", "medium", "slow"
    )

if __name__ == "__main__":
    input_path = "/content/drive/MyDrive/videos/240304-PDB-RAE-S-SUBIDAAV.PTE.S.CASTILLO.mp4"
    output_video_path = "/content/drive/MyDrive/videos/SUBIDAAV.mp4"

    # Comprimir video
    if os.path.exists(input_path):
        # Cambia el tamaño objetivo (en MB) según lo que necesites
        target_size_mb = 50
        video_compressor(input_path, output_video_path, target_resolution=(1280, 720), target_size_mb=target_size_mb)
        print(f"El video se comprimió correctamente y se guardó en {output_video_path}")
    else:
        print(f"Error: El archivo {input_path} no se encontró.")
