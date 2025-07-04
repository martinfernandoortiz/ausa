import sys

if len(sys.argv) < 2:
    print("Uso: python3 config.py <nombre_archivo.las>")
    sys.exit(1)

filename = sys.argv[1]

with open(filename, "rb+") as f:
    f.seek(6)
    f.write(bytes([17, 0, 0, 0]))
