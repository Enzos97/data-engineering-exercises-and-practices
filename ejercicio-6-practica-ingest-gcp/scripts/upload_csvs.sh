#!/bin/bash

# =============================================================================
# Script de Ingesta GCP - Subida de Archivos CSV a Google Cloud Storage
# =============================================================================
# Este script automatiza la subida de archivos CSV a un bucket de GCP
# utilizando gsutil CLI
# =============================================================================

# === CONFIGURACIÓN ===
BUCKET_NAME="data-bucket-demo-1"   # ← tu bucket en GCS
LOCAL_DIR="/mnt/c/Users/enz_9/OneDrive/Desktop/EDVai/csvFiles"  # ruta local de tus CSV
LOG_FILE="./upload_log.txt"               # archivo de log (opcional)

# === INICIO ===
echo "🚀 Iniciando carga de CSVs desde: $LOCAL_DIR" | tee -a "$LOG_FILE"
echo "Bucket destino: gs://$BUCKET_NAME" | tee -a "$LOG_FILE"
echo "=============================================" | tee -a "$LOG_FILE"

# Verificar si gsutil está disponible
if ! command -v gsutil &> /dev/null; then
  echo "❌ Error: gsutil no está instalado o no está en el PATH." | tee -a "$LOG_FILE"
  exit 1
fi

# Verificar si la carpeta existe
if [ ! -d "$LOCAL_DIR" ]; then
  echo "❌ Error: la carpeta $LOCAL_DIR no existe." | tee -a "$LOG_FILE"
  exit 1
fi

# Subir uno por uno los CSV
for file in "$LOCAL_DIR"/*.csv; do
  if [ -f "$file" ]; then
    echo "⬆️ Subiendo archivo: $(basename "$file")..." | tee -a "$LOG_FILE"
    if gsutil cp "$file" "gs://$BUCKET_NAME/"; then
      echo "✅ Éxito: $(basename "$file") subido correctamente." | tee -a "$LOG_FILE"
    else
      echo "⚠️ Error al subir $(basename "$file")" | tee -a "$LOG_FILE"
    fi
  fi
done

echo "=============================================" | tee -a "$LOG_FILE"
echo "🎯 Proceso finalizado." | tee -a "$LOG_FILE"
