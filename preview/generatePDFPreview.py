import os
import re
from pdf2image import convert_from_path

def generar_thumbs_recursivo(carpeta_base):
    """
    Recorre recursivamente todas las carpetas y en cada una con PDFs:
    1. Crea una carpeta 'thumbs' dentro de la carpeta actual
    2. Genera miniaturas JPG de los PDFs en la carpeta 'thumbs'
    """
    for raiz, _, archivos in os.walk(carpeta_base):
        # Filtrar solo los archivos PDF en esta carpeta
        pdfs = [f for f in archivos if f.lower().endswith('.pdf')]
        
        if pdfs:
            # Crear carpeta thumbs dentro de la carpeta actual
            thumbs_dir = os.path.join(raiz, 'thumbs')
            os.makedirs(thumbs_dir, exist_ok=True)
            print(f"\nProcesando carpeta: {raiz}")
            
            for pdf in pdfs:
                pdf_path = os.path.join(raiz, pdf)
                
                # Generar nombre limpio para la miniatura
                nombre_limpio = re.sub(r"[ ']", "_", os.path.splitext(pdf)[0])
                thumb_path = os.path.join(thumbs_dir, f"{nombre_limpio}.jpg")
                
                # Si ya existe la miniatura, saltar
                if os.path.exists(thumb_path):
                    continue
                
                try:
                    # Convertir primera página a JPG
                    images = convert_from_path(
                        pdf_path,
                        first_page=1,
                        last_page=1,
                        dpi=100,
                        output_folder=thumbs_dir,
                        output_file=nombre_limpio,
                        fmt='jpeg'
                    )
                    print(f"✓ Miniatura generada: {thumb_path}")
                except Exception as e:
                    print(f"✗ Error procesando {pdf}: {str(e)}")

if __name__ == "__main__":
    # Directorio donde se ejecuta el script
    directorio_base = os.path.dirname(os.path.abspath(__file__))
    
    print("Iniciando generación de miniaturas...")
    generar_thumbs_recursivo(directorio_base)
    print("\nProceso completado!")