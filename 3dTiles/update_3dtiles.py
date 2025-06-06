#Actualiza los datos que están en cesium en el servidor
#Se ejecuta python3 update_3dtiles.py MODELO


import os
import requests
import zipfile
import shutil
import sys
from datetime import datetime, timezone

LOG_FILE = "/home/IFC/update_log.txt"  # Ruta modificable

# === Configuración ===
CESIUM_API_URL = "https://api.cesium.com/v1/archives/"
AUTH_TOKEN = "Bearer token"
LOCAL_BASE_PATH = "/home/IFC/"

# === Parámetro desde consola ===
if len(sys.argv) < 2:
    print("Uso: python update_3d_tiles.py NOMBRE_MODELO")
    sys.exit(1)

MODELO_OBJETIVO = sys.argv[1]
print(f"Iniciando actualización de modelo: {MODELO_OBJETIVO}")


def registrar_log(nombre_modelo, id_archivo, fecha_api_str, estado):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    linea = f"[{timestamp}] Modelo: {nombre_modelo} | ID: {id_archivo} | Fecha API: {fecha_api_str} → {estado}\n"
    with open(LOG_FILE, "a") as f:
        f.write(linea)


def obtener_archivos_api(url, token):
    print("Consultando la API de Cesium...")
    headers = {"Authorization": token}
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    return response.json()


def respaldar_carpeta(path):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    old_path = os.path.join(path, "old")
    os.makedirs(old_path, exist_ok=True)

    # Nombre para la carpeta de respaldo con timestamp
    backup_name = f"backup_{timestamp}"
    backup_path = os.path.join(old_path, backup_name)

    # Mover todos los archivos y carpetas dentro de path (excepto 'old') a backup_path
    os.makedirs(backup_path)

    for item in os.listdir(path):
        if item == "old":
            continue
        src = os.path.join(path, item)
        dst = os.path.join(backup_path, item)
        shutil.move(src, dst)

    print(f"Respaldo movido a: {backup_path}")

def descargar_y_reemplazar(id_archivo, destino, url_base, token, fecha_api_str):
    print("Descargando y reemplazando archivos...")
    download_url = f"{url_base}{id_archivo}/download"
    zip_file = f"temp_{id_archivo}.zip"

    headers = {"Authorization": token}
    response = requests.get(download_url, headers=headers, stream=True)
    response.raise_for_status()

    with open(zip_file, "wb") as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)

    # === Copia de respaldo ===
    tiene_contenido = os.path.isdir(destino) and any(
        nombre != "old" for nombre in os.listdir(destino)
    )

    if tiene_contenido:
        try:
            with open(os.path.join(destino, "dateAdded"), "r") as f:
                old_date_str = f.read().strip()
        except Exception:
            old_date_str = datetime.now().strftime("%Y%m%d_%H%M%S")

        old_base = os.path.join(destino, "old")
        os.makedirs(old_base, exist_ok=True)

        backup_path = os.path.join(
            old_base,
            f"old_{old_date_str.replace(':', '').replace('-', '').replace('T', '_').replace('Z', '')}"
        )

        def ignore_old_folder(dir, files):
            return ['old'] if 'old' in files else []

        shutil.copytree(destino, backup_path, ignore=ignore_old_folder)
        print(f"Modelo anterior respaldado en: {backup_path}")

        # NO borrar el destino, para mantener todos los backups

    # Asegurarse que destino existe para extraer zip
    os.makedirs(destino, exist_ok=True)

    with zipfile.ZipFile(zip_file, 'r') as zip_ref:
        zip_ref.extractall(destino)

    os.remove(zip_file)

    # Guardar nueva fecha en archivo dateAdded
    with open(os.path.join(destino, "dateAdded"), "w") as f:
        f.write(fecha_api_str)

    print(f"Archivo actualizado en {destino} y dateAdded guardado.")

def leer_fecha_local(local_path):
    try:
        with open(os.path.join(local_path, "dateAdded"), "r") as f:
            fecha_str = f.read().strip()
            return datetime.strptime(fecha_str, "%Y-%m-%dT%H:%M:%S.%fZ").replace(tzinfo=timezone.utc)
    except Exception:
        return None


def actualizar_modelo(nombre_modelo, url, token, base_path):
    datos = obtener_archivos_api(url, token)
    coincidencias = [item for item in datos["items"] if item["name"] == nombre_modelo]

    if not coincidencias:
        print(f"❌ Modelo '{nombre_modelo}' no encontrado en la API.")
        return

    # Elegir el más reciente por dateAdded
    item = max(coincidencias, key=lambda x: x["dateAdded"])
    fecha_api_str = item["dateAdded"]
    fecha_api = datetime.fromisoformat(fecha_api_str.replace("Z", "+00:00"))
    modelo_id = item["id"]
    print('Datos: \n item:' +str(item)+"\n Fecha: "+str(fecha_api)+"\n modelo id :" + str(modelo_id)) # BORRAR

    local_path = os.path.join(base_path, nombre_modelo)

    if not os.path.isdir(local_path):
        print(f"📥 El modelo '{nombre_modelo}' no existe localmente. Descargando...")
        descargar_y_reemplazar(modelo_id, local_path, url, token, fecha_api_str)
        registrar_log(nombre_modelo, modelo_id, fecha_api_str, "Descargado nuevo (no existía local)")
        return

    # Leer dateAdded local

    try:
        with open(os.path.join(local_path, "dateAdded"), "r") as f:
            fecha_local_str = f.read().strip()
            fecha_local = datetime.fromisoformat(fecha_local_str.replace("Z", "+00:00"))
    except Exception:
        print("⚠️ No se pudo leer el archivo 'dateAdded'. Se asumirá fecha mínima.")
        fecha_local = datetime.min.replace(tzinfo=timezone.utc)

    # Comparación
    if fecha_api > fecha_local:
        print(f"🔄 Modelo '{nombre_modelo}' desactualizado. Actualizando...")
        descargar_y_reemplazar(modelo_id, local_path, url, token, fecha_api_str)
        registrar_log(nombre_modelo, modelo_id, fecha_api_str, "Actualizado")
    else:
        print(f"✅ Modelo '{nombre_modelo}' ya está actualizado.")
        registrar_log(nombre_modelo, modelo_id, fecha_api_str, "Sin cambios (ya actualizado)")


# === Ejecutar ===
actualizar_modelo(MODELO_OBJETIVO, CESIUM_API_URL, AUTH_TOKEN, LOCAL_BASE_PATH)

print("Proceso terminado.")
