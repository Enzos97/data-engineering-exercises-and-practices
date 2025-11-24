#!/bin/bash

# =====================================================
# Script: download_data.sh
# Descripción: Descarga archivos Car Rental y georef desde S3
# Autor: Data Engineering Team
# Fecha: 2025-11-22
# PUNTO 2: Ingest de archivos
# =====================================================

# Cargar variables de entorno de Hadoop
export HADOOP_HOME=/home/hadoop/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64  # Corregido a Java 11
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "🚗 CAR RENTAL DATA DOWNLOAD"
echo "=========================================="
echo ""

# Configuración
LOCAL_DIR="/tmp/car_rental"
HDFS_DIR="/car_rental/raw"

# URLs de los archivos
CAR_RENTAL_URL="https://data-engineer-edvai-public.s3.amazonaws.com/CarRentalData.csv"
GEOREF_URL="https://data-engineer-edvai-public.s3.amazonaws.com/georef-united-states-of-america-state.csv"

# Nombres de archivos
CAR_RENTAL_FILE="CarRentalData.csv"
GEOREF_FILE="georef_usa_states.csv"

echo "📁 Paso 1: Creando directorio temporal..."
mkdir -p $LOCAL_DIR
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Directorio creado: $LOCAL_DIR${NC}"
else
    echo -e "${RED}❌ Error al crear directorio${NC}"
    exit 1
fi
echo ""

echo "📥 Paso 2: Descargando CarRentalData.csv..."
wget -O $LOCAL_DIR/$CAR_RENTAL_FILE $CAR_RENTAL_URL
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Descarga exitosa: $CAR_RENTAL_FILE${NC}"
    echo "   📊 Tamaño: $(ls -lh $LOCAL_DIR/$CAR_RENTAL_FILE | awk '{print $5}')"
    echo "   📋 Líneas: $(wc -l < $LOCAL_DIR/$CAR_RENTAL_FILE)"
else
    echo -e "${RED}❌ Error al descargar $CAR_RENTAL_FILE${NC}"
    exit 1
fi
echo ""

echo "📥 Paso 3: Descargando georef USA states..."
echo "   ⚠️  Usando -O para renombrar archivo (contiene caracteres especiales)"
wget -P $LOCAL_DIR -O $LOCAL_DIR/$GEOREF_FILE "$GEOREF_URL"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Descarga exitosa: $GEOREF_FILE${NC}"
    echo "   📊 Tamaño: $(ls -lh $LOCAL_DIR/$GEOREF_FILE | awk '{print $5}')"
    echo "   📋 Líneas: $(wc -l < $LOCAL_DIR/$GEOREF_FILE)"
else
    echo -e "${RED}❌ Error al descargar $GEOREF_FILE${NC}"
    exit 1
fi
echo ""

echo "🗂️  Paso 4: Verificando archivos descargados..."
echo "Archivos en $LOCAL_DIR:"
ls -lh $LOCAL_DIR/
echo ""

echo "🔍 Paso 5: Vista previa de datos..."
echo ""
echo "--- CarRentalData.csv (primeras 2 líneas, primeros 200 caracteres) ---"
head -2 $LOCAL_DIR/$CAR_RENTAL_FILE | cut -c1-200
echo ""
echo "--- georef_usa_states.csv (solo conteo de líneas) ---"
echo "   Líneas totales: $(wc -l < $LOCAL_DIR/$GEOREF_FILE)"
echo "   Columnas: $(head -1 $LOCAL_DIR/$GEOREF_FILE | awk -F';' '{print NF}')"
echo ""

echo "🗑️  Paso 6: Limpiando directorio HDFS si existe..."
hdfs dfs -rm -r $HDFS_DIR 2>/dev/null
echo ""

echo "📂 Paso 7: Creando directorio en HDFS..."
hdfs dfs -mkdir -p $HDFS_DIR
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Directorio HDFS creado: $HDFS_DIR${NC}"
else
    echo -e "${RED}❌ Error al crear directorio HDFS${NC}"
    exit 1
fi
echo ""

echo "⬆️  Paso 8: Subiendo archivos a HDFS..."
echo "   Subiendo $CAR_RENTAL_FILE..."
hdfs dfs -put $LOCAL_DIR/$CAR_RENTAL_FILE $HDFS_DIR/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✅ $CAR_RENTAL_FILE subido${NC}"
else
    echo -e "${RED}   ❌ Error al subir $CAR_RENTAL_FILE${NC}"
    exit 1
fi

echo "   Subiendo $GEOREF_FILE..."
hdfs dfs -put $LOCAL_DIR/$GEOREF_FILE $HDFS_DIR/
if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✅ $GEOREF_FILE subido${NC}"
else
    echo -e "${RED}   ❌ Error al subir $GEOREF_FILE${NC}"
    exit 1
fi
echo ""

echo "✅ Paso 9: Verificando archivos en HDFS..."
hdfs dfs -ls -h $HDFS_DIR
echo ""

echo "🧹 Paso 10: Limpiando archivos temporales locales..."
rm -rf $LOCAL_DIR
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Archivos temporales eliminados${NC}"
else
    echo -e "${YELLOW}⚠️  No se pudieron eliminar todos los archivos temporales${NC}"
fi
echo ""

echo "=========================================="
echo -e "${GREEN}✅ DESCARGA COMPLETADA EXITOSAMENTE${NC}"
echo "=========================================="
echo ""
echo "📊 Resumen:"
echo "   - Archivos descargados: 2"
echo "   - Ubicación HDFS: $HDFS_DIR"
echo "   - CarRentalData.csv ✅"
echo "   - georef_usa_states.csv ✅"
echo ""
echo "🎯 Siguiente paso: Ejecutar script Spark de procesamiento"
echo ""

