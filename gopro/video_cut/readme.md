# 🎥 Herramienta de Corte y División de Video con Python

Esta es una herramienta de línea de comandos (CLI) que te permite realizar **cortes** y **divisiones rápidas** en archivos de video utilizando **Python** y **FFmpeg**. Es ideal para flujos de trabajo donde la velocidad y la facilidad de uso son prioritarias.

## ⚙️ Estructura del Proyecto

Para que el script funcione, debes asegurarte de que la estructura de tu directorio sea la siguiente:

/mi_proyecto_video_cut/
├── video_cut.py               # ⬅️ El script principal de Python <br>
├── input/                     # ⬅️ Coloca aquí los videos que deseas cortar  <br>
│ └── mi_video.mp4  <br>
├── tools/                     # ⬅️ Coloca aquí el ejecutable de FFmpeg  <br>
│ └── ffmpeg (o ffmpeg.exe)  <br>
└── video_cut/                 # ⬅️ Los videos cortados aparecerán automáticamente aquí  <br>

## 🚀 Uso de la Herramienta

Todos los comandos deben ejecutarse en la terminal. El formato de tiempo es siempre **HH:MM:SS** (ej. `00:01:30`).

### 1. `remove` (Recortar Extremos)

Se utiliza para quitar una porción del inicio o del final del video, conservando la parte deseada.

| Tarea | Opción | Comando de Ejemplo |
| :--- | :--- | :--- |
| **Quitar el Inicio** (Conservar desde) | `-s` / `--start` | `python video_cut.py remove mi_video.mp4 -s 00:00:10` |
| **Quitar el Final** (Conservar hasta) | `-e` / `--end` | `python video_cut.py remove mi_video.mp4 -e 00:02:45` |

### 2. `split` (Dividir en Dos Partes)

Divide el video en dos archivos en un punto específico. Permite nombrar los archivos de salida con `-o1` y `-o2`.

| Tarea | Comando de Ejemplo | Archivos Creados |
| :--- | :--- | :--- |
| **División Automática** | `python video_cut.py split video.mp4 00:00:30` | `video_parte1_a_00-00-30.mp4`<br>`video_parte2_desde_00-00-30.mp4` |
| **División Manual** | `python video_cut.py split video.mp4 00:00:30 -o1 intro.mp4 -o2 cuerpo_principal.mp4` | `intro.mp4`<br>`cuerpo_principal.mp4` |

---

## ⚠️ Consideración Importante: Metadata

El script utiliza el modo de **copia de *stream*** (`-c copy`) de FFmpeg. Este método asegura una **velocidad máxima** y **cero pérdida de calidad** al evitar la recodificación.

Sin embargo, debido a este proceso, la **metadata original** (datos de la cámara, historial EXIF, etc.) **no se conserva** en los archivos de salida, sino que es reemplazada por nueva metadata de sistema (fecha de exportación, etc.).
