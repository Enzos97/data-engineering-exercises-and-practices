#!/bin/bash

# Script: ingest.sh
# Descripción: Descarga el archivo titanic.csv desde S3 a directorio local de NiFi
# Autor: Hadoop
# Fecha: 2025-11-20

echo "=== DESCARGANDO ARCHIVO TITANIC.CSV ==="
echo "Fecha: $(date)"

# Crear directorio si no existe
mkdir -p /home/nifi/ingest

# Descargar archivo
echo "Descargando titanic.csv..."
curl -o /home/nifi/ingest/titanic.csv \
https://data-engineer-edvai-public.s3.amazonaws.com/titanic.csv

# Verificar descarga
if [ $? -eq 0 ]; then
    echo "✅ Descarga completada exitosamente"
    echo "📊 Tamaño del archivo: $(ls -lh /home/nifi/ingest/titanic.csv | awk '{print $5}')"
else
    echo "❌ Error en la descarga"
    exit 1
fi

echo "=== PROCESO COMPLETADO ==="

