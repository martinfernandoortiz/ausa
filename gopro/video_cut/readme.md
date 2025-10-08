 Herramienta de Corte y División de Video con Python
Esta es una herramienta de línea de comandos (CLI) que te permite realizar cortes y divisiones rápidas en archivos de video utilizando Python y FFmpeg. Es ideal para flujos de trabajo donde la velocidad y la facilidad de uso son prioritarias.

⚙️ Estructura del Proyecto
Para que el script funcione, debes asegurarte de que la estructura de tu directorio sea la siguiente:

/mi_proyecto_video_cut/
├── video_cut.py               # ⬅️ El script principal de Python
├── input/                     # ⬅️ Coloca aquí los videos que deseas cortar
│   └── mi_video.mp4
├── tools/                     # ⬅️ Coloca aquí el ejecutable de FFmpeg
│   └── ffmpeg (o ffmpeg.exe)
└── video_cut/                 # ⬅️ Los videos cortados aparecerán automáticamente aquí
💻 Código Fuente (video_cut.py)
A continuación, se encuentra el código completo del script.

🚀 Uso de la Herramienta
Todos los comandos deben ejecutarse en la terminal. El formato de tiempo es siempre HH:MM:SS (ej. 00:01:30).

1. remove (Recortar Extremos)
Se utiliza para quitar una porción del inicio o del final del video, conservando la parte deseada.

Tarea	Opción	Comando de Ejemplo
Quitar el Inicio (Conservar desde)	-s / --start	python video_cut.py remove mi_video.mp4 -s 00:00:10
Quitar el Final (Conservar hasta)	-e / --end	python video_cut.py remove mi_video.mp4 -e 00:02:45

Exportar a Hojas de cálculo
2. split (Dividir en Dos Partes)
Divide el video en dos archivos en un punto específico. Permite nombrar los archivos de salida con -o1 y -o2.

Tarea	Comando de Ejemplo	Archivos Creados
División Automática	python video_cut.py split video.mp4 00:00:30	video_parte1_a_00-00-30.mp4 video_parte2_desde_00-00-30.mp4
División Manual	python video_cut.py split video.mp4 00:00:30 -o1 intro.mp4 -o2 cuerpo_principal.mp4	intro.mp4 cuerpo_principal.mp4

Exportar a Hojas de cálculo
