import os
from PIL import Image
import ezdxf
import cv2
import matplotlib.pyplot as plt

# Directorio de entrada y salida
input_dir = "ruta/a/tu/directorio/de/entrada"
output_dir = "ruta/a/tu/directorio/de/salida"

# Crear directorio de salida si no existe
os.makedirs(output_dir, exist_ok=True)

def convert_tif_to_jpg(file_path, output_path):
    try:
        with Image.open(file_path) as img:
            img = img.convert("RGB")  # Asegurarse de que sea formato RGB
            img.save(output_path, "JPEG")
            print(f"Convertido {file_path} a {output_path}")
    except Exception as e:
        print(f"Error convirtiendo {file_path}: {e}")

def convert_dxf_to_jpg(file_path, output_path):
    try:
        doc = ezdxf.readfile(file_path)
        msp = doc.modelspace()
        # Crear una figura para renderizar
        fig, ax = plt.subplots()
        for entity in msp:
            if entity.dxftype() == "LINE":
                start, end = entity.dxf.start, entity.dxf.end
                ax.plot([start.x, end.x], [start.y, end.y], color="black")
        ax.axis("equal")
        plt.axis("off")
        plt.savefig(output_path, format="jpg", bbox_inches="tight", pad_inches=0)
        plt.close(fig)
        print(f"Convertido {file_path} a {output_path}")
    except Exception as e:
        print(f"Error convirtiendo {file_path}: {e}")

def convert_dwg_to_jpg(file_path, output_path):
    try:
        # Usar OpenCV para capturar vista previa del DWG
        # Nota: Esta parte requiere que tengas un visualizador DWG instalado que genere imágenes.
        # Puedes usar una herramienta de terceros para previsualizar automáticamente.
        print(f"Convertir DWG no está implementado completamente en este script. Usa un conversor dedicado.")
    except Exception as e:
        print(f"Error convirtiendo {file_path}: {e}")

def convert_files(input_dir, output_dir):
    for root, _, files in os.walk(input_dir):
        for file in files:
            input_path = os.path.join(root, file)
            output_path = os.path.join(output_dir, os.path.splitext(file)[0] + ".jpg")
            
            if file.lower().endswith(".tif"):
                convert_tif_to_jpg(input_path, output_path)
            elif file.lower().endswith(".dxf"):
                convert_dxf_to_jpg(input_path, output_path)
            elif file.lower().endswith(".dwg"):
                convert_dwg_to_jpg(input_path, output_path)
            else:
                print(f"Formato no soportado: {file}")

# Llama a la función
convert_files(input_dir, output_dir)
