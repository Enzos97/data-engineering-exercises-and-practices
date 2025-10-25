#!/bin/bash

# =============================================================================
# Script de Descarga - Archivo Parquet de NYC Taxi Data
# =============================================================================
# Este script descarga el archivo yellow_tripdata_2021-01.parquet desde S3
# y lo guarda en el directorio /home/nifi/ingest/
# =============================================================================

# === CONFIGURACIÓN ===
DOWNLOAD_URL="https://data-engineer-edvai-public.s3.amazonaws.com/yellow_tripdata_2021-01.parquet"
LOCAL_DIR="/home/nifi/ingest"
FILENAME="yellow_tripdata_2021-01.parquet"
LOG_FILE="/home/nifi/download_log.txt"

# === INICIO ===
echo "🚀 Iniciando descarga de archivo Parquet" | tee -a "$LOG_FILE"
echo "URL: $DOWNLOAD_URL" | tee -a "$LOG_FILE"
echo "Directorio destino: $LOCAL_DIR" | tee -a "$LOG_FILE"
echo "=============================================" | tee -a "$LOG_FILE"

# Crear directorio si no existe
if [ ! -d "$LOCAL_DIR" ]; then
    echo "📁 Creando directorio: $LOCAL_DIR" | tee -a "$LOG_FILE"
    mkdir -p "$LOCAL_DIR"
fi

# Verificar si wget está disponible
if ! command -v wget &> /dev/null; then
    echo "❌ Error: wget no está instalado." | tee -a "$LOG_FILE"
    exit 1
fi

# Descargar archivo
echo "⬇️ Descargando archivo: $FILENAME..." | tee -a "$LOG_FILE"
if wget -O "$LOCAL_DIR/$FILENAME" "$DOWNLOAD_URL"; then
    echo "✅ Éxito: Archivo descargado correctamente." | tee -a "$LOG_FILE"
    
    # Verificar tamaño del archivo
    FILE_SIZE=$(ls -lh "$LOCAL_DIR/$FILENAME" | awk '{print $5}')
    echo "📊 Tamaño del archivo: $FILE_SIZE" | tee -a "$LOG_FILE"
    
    # Verificar permisos
    chmod 644 "$LOCAL_DIR/$FILENAME"
    echo "🔐 Permisos configurados: 644" | tee -a "$LOG_FILE"
    
else
    echo "❌ Error: Falló la descarga del archivo." | tee -a "$LOG_FILE"
    exit 1
fi

echo "=============================================" | tee -a "$LOG_FILE"
echo "🎯 Proceso completado." | tee -a "$LOG_FILE"
echo "📁 Archivo disponible en: $LOCAL_DIR/$FILENAME" | tee -a "$LOG_FILE"
