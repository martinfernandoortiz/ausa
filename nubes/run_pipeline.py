import argparse
import json
import subprocess
import tempfile

# Configurar argumentos
parser = argparse.ArgumentParser(description='Ejecuta pipeline PDAL con parámetros dinámicos')
parser.add_argument('-i', '--input', required=True, help='Archivo LAS de entrada')
parser.add_argument('-o', '--output', required=True, help='Archivo LAS de salida')
parser.add_argument('-e', '--epsg', default='EPSG:5348', help='Sistema de referencia (default: EPSG:5348)')
args = parser.parse_args()

# Cargar plantilla
with open('config_template.json') as f:
    config = json.load(f)

# Actualizar valores
config[0]['filename'] = args.input
config[1]['filename'] = args.output
config[1]['a_srs'] = args.epsg

# Crear archivo temporal
with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as tmpfile:
    json.dump(config, tmpfile, indent=4)
    tmp_path = tmpfile.name

# Ejecutar PDAL
try:
    subprocess.run(['pdal', 'pipeline', tmp_path], check=True)
finally:
    # Limpiar archivo temporal
    import os
    os.unlink(tmp_path)
