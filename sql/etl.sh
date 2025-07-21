#!/bin/bash

# Configuración de conexión
DB_NAME="ausagis"
USER="tu_usuario"
HOST="localhost"
PORT="5432"
OUTPUT_DIR="./sql_por_objeto"
SCHEMAS=("gisdata" "formularios" "maps")

# Crear carpeta de salida
mkdir -p "$OUTPUT_DIR"

# Exportar tablas y vistas con dependencias asociadas
for SCHEMA in "${SCHEMAS[@]}"; do
  echo "🔍 Procesando esquema: $SCHEMA"

  # Obtener tablas y vistas
  OBJETOS=$(psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DB_NAME" -Atc "
    SELECT table_name FROM information_schema.tables WHERE table_schema = '$SCHEMA'
    UNION
    SELECT table_name FROM information_schema.views WHERE table_schema = '$SCHEMA';"
  )

  for OBJ in $OBJETOS; do
    FILENAME="${OUTPUT_DIR}/${SCHEMA}.${OBJ}.txt"
    echo "📦 Exportando $SCHEMA.$OBJ → $FILENAME"

    pg_dump -h "$HOST" -p "$PORT" -U "$USER" -d "$DB_NAME" \
      --schema="$SCHEMA" \
      --table="$SCHEMA.$OBJ" \
      --schema-only \
      --no-owner \
      --no-privileges \
      > "$FILENAME"
  done
done

# Exportar secuencias independientes
echo "🔍 Exportando secuencias independientes..."

for SCHEMA in "${SCHEMAS[@]}"; do
  SEQUENCES=$(psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DB_NAME" -Atc "
    SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = '$SCHEMA';"
  )

  for SEQ in $SEQUENCES; do
    FILENAME="${OUTPUT_DIR}/${SCHEMA}.${SEQ}_seq.txt"
    echo "📦 Exportando secuencia $SCHEMA.$SEQ → $FILENAME"

    pg_dump -h "$HOST" -p "$PORT" -U "$USER" -d "$DB_NAME" \
      --schema="$SCHEMA" \
      --table="$SCHEMA.$SEQ" \
      --schema-only \
      --no-owner \
      --no-privileges \
      > "$FILENAME"
  done
done

# Exportar funciones y triggers definidos a nivel de esquema
echo "🔍 Exportando funciones, triggers, y reglas globales..."

for SCHEMA in "${SCHEMAS[@]}"; do
  FILENAME="${OUTPUT_DIR}/${SCHEMA}.__funciones_y_triggers_esquema.txt"
  echo "📦 Exportando funciones/triggers a nivel de esquema $SCHEMA → $FILENAME"

  pg_dump -h "$HOST" -p "$PORT" -U "$USER" -d "$DB_NAME" \
    --schema="$SCHEMA" \
    --section=pre-data \
    --schema-only \
    --no-owner \
    --no-privileges \
    --file="$FILENAME"
done

echo "✅ Todos los archivos fueron generados en: $OUTPUT_DIR"
