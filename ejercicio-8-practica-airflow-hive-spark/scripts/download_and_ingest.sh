#!/bin/bash

# Script: download_and_ingest.sh
# Descripción: Descarga archivos Parquet de viajes NYC Taxi y los sube a HDFS

echo "=== INICIANDO DESCARGA E INGESTA A HDFS ==="
echo "Fecha: $(date)"

# --- CONFIGURACIÓN DEL ENTORNO ---
# Si Airflow no carga el entorno de Hadoop, lo forzamos manualmente
export HADOOP_HOME=/home/hadoop/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Comando HDFS con ruta absoluta por seguridad
HDFS_CMD="$HADOOP_HOME/bin/hdfs"

# Directorio HDFS para los archivos
HDFS_RAW_DIR="/user/hadoop/tripdata/raw"

# --- 1. Verificar servicios HDFS ---
echo "1. Verificando servicios HDFS..."
jps | grep -E "NameNode|DataNode" > /dev/null
if [ $? -ne 0 ]; then
  echo "❌ Servicios HDFS no detectados"
  exit 1
fi

# --- 2. Verificar/Crear directorio en HDFS ---
echo "2. Verificando directorio HDFS: $HDFS_RAW_DIR"
$HDFS_CMD dfs -mkdir -p $HDFS_RAW_DIR

# --- 3. URLs y nombres locales ---
URL1="https://data-engineer-edvai-public.s3.amazonaws.com/yellow_tripdata_2021-01.parquet"
URL2="https://data-engineer-edvai-public.s3.amazonaws.com/yellow_tripdata_2021-02.parquet"
FILE1="yellow_tripdata_2021-01.parquet"
FILE2="yellow_tripdata_2021-02.parquet"

# --- 4. Prueba de conectividad ---
echo "3. Probando conectividad con URLs..."
wget --spider $URL1 --timeout=30
if [ $? -ne 0 ]; then
  echo "❌ No hay conexión a internet o el servidor no responde"
  exit 1
fi
echo "✅ Conectividad OK"

# --- 5. Descarga de archivos ---
echo "4. Descargando archivos..."
wget --tries=3 --timeout=60 -O $FILE1 $URL1
DOWNLOAD1=$?
wget --tries=3 --timeout=60 -O $FILE2 $URL2
DOWNLOAD2=$?

if [ $DOWNLOAD1 -eq 0 ] && [ $DOWNLOAD2 -eq 0 ]; then
  echo "✅ Archivos descargados correctamente"
  echo "   - $FILE1: $(ls -lh $FILE1 | awk '{print $5}')"
  echo "   - $FILE2: $(ls -lh $FILE2 | awk '{print $5}')"
else
  echo "❌ Error en la descarga: códigos $DOWNLOAD1 / $DOWNLOAD2"
  exit 1
fi

# --- 6. Subir a HDFS ---
echo "5. Subiendo archivos a HDFS..."
$HDFS_CMD dfs -put -f $FILE1 $HDFS_RAW_DIR/
UPLOAD1=$?
$HDFS_CMD dfs -put -f $FILE2 $HDFS_RAW_DIR/
UPLOAD2=$?

if [ $UPLOAD1 -eq 0 ] && [ $UPLOAD2 -eq 0 ]; then
  echo "✅ Archivos subidos correctamente a HDFS"
else
  echo "❌ Error subiendo archivos a HDFS"
  exit 1
fi

# --- 7. Verificación ---
echo "6. Verificando carga en HDFS..."
$HDFS_CMD dfs -ls -h $HDFS_RAW_DIR/

# --- 8. Limpieza local ---
echo "7. Limpiando archivos locales..."
rm -f $FILE1 $FILE2

echo "=== PROCESO COMPLETADO EXITOSAMENTE ==="
echo "✅ Archivos disponibles en HDFS: $HDFS_RAW_DIR"
echo "📅 Fecha finalización: $(date)"
