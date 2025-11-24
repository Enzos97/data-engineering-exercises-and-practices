#!/bin/bash

# =====================================================
# Script: ingest_aviacion.sh
# Descripción: Descarga archivos de aviación desde S3 y los sube a HDFS
# Autor: Data Engineering Team
# Fecha: 2025-11-24
# EJERCICIO FINAL 1 - PUNTO 1: Ingest de Archivos
# =====================================================

# Cargar variables de entorno de Hadoop
export HADOOP_HOME=/home/hadoop/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "=========================================="
echo "✈️  AVIACIÓN CIVIL - DESCARGA DE DATOS"
echo "=========================================="
echo ""

# Configuración
LOCAL_DIR="/home/hadoop/landing"
HDFS_DIR="/ingest"

# URLs de descarga
VUELOS_2021_URL="https://data-engineer-edvai-public.s3.amazonaws.com/2021-informe-ministerio.csv"
VUELOS_2022_URL="https://data-engineer-edvai-public.s3.amazonaws.com/202206-informe-ministerio.csv"
AEROPUERTOS_URL="https://data-engineer-edvai-public.s3.amazonaws.com/aeropuertos_detalle.csv"

VUELOS_2021_FILE="2021-informe-ministerio.csv"
VUELOS_2022_FILE="202206-informe-ministerio.csv"
AEROPUERTOS_FILE="aeropuertos_detalle.csv"

# =====================================================
# PASO 1: CREAR DIRECTORIO LOCAL
# =====================================================
echo -e "${BLUE}📁 Paso 1: Creando directorio local...${NC}"
mkdir -p $LOCAL_DIR
cd $LOCAL_DIR

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Directorio creado: $LOCAL_DIR${NC}"
else
    echo -e "${RED}❌ Error al crear directorio local${NC}"
    exit 1
fi
echo ""

# =====================================================
# PASO 2: DESCARGAR ARCHIVOS DESDE S3
# =====================================================
echo -e "${BLUE}📥 Paso 2: Descargando archivos desde S3...${NC}"
echo ""

# Descargar vuelos 2021
echo "   🛫 Descargando vuelos 2021..."
wget -O $VUELOS_2021_FILE "$VUELOS_2021_URL" 2>&1 | grep -E "saved|failed|error" || true

if [ -f "$VUELOS_2021_FILE" ]; then
    echo -e "${GREEN}   ✅ Descarga exitosa: $VUELOS_2021_FILE${NC}"
    echo "      📊 Tamaño: $(du -h $VUELOS_2021_FILE | cut -f1)"
    echo "      📋 Líneas: $(wc -l < $VUELOS_2021_FILE)"
else
    echo -e "${RED}   ❌ Error al descargar $VUELOS_2021_FILE${NC}"
    exit 1
fi
echo ""

# Descargar vuelos 2022
echo "   🛫 Descargando vuelos 2022..."
wget -O $VUELOS_2022_FILE "$VUELOS_2022_URL" 2>&1 | grep -E "saved|failed|error" || true

if [ -f "$VUELOS_2022_FILE" ]; then
    echo -e "${GREEN}   ✅ Descarga exitosa: $VUELOS_2022_FILE${NC}"
    echo "      📊 Tamaño: $(du -h $VUELOS_2022_FILE | cut -f1)"
    echo "      📋 Líneas: $(wc -l < $VUELOS_2022_FILE)"
else
    echo -e "${RED}   ❌ Error al descargar $VUELOS_2022_FILE${NC}"
    exit 1
fi
echo ""

# Descargar aeropuertos
echo "   🏢 Descargando detalles de aeropuertos..."
wget -O $AEROPUERTOS_FILE "$AEROPUERTOS_URL" 2>&1 | grep -E "saved|failed|error" || true

if [ -f "$AEROPUERTOS_FILE" ]; then
    echo -e "${GREEN}   ✅ Descarga exitosa: $AEROPUERTOS_FILE${NC}"
    echo "      📊 Tamaño: $(du -h $AEROPUERTOS_FILE | cut -f1)"
    echo "      📋 Líneas: $(wc -l < $AEROPUERTOS_FILE)"
else
    echo -e "${RED}   ❌ Error al descargar $AEROPUERTOS_FILE${NC}"
    exit 1
fi
echo ""

# =====================================================
# PASO 3: VERIFICAR ARCHIVOS DESCARGADOS
# =====================================================
echo -e "${BLUE}🗂️  Paso 3: Verificando archivos descargados...${NC}"
echo "Archivos en $LOCAL_DIR:"
ls -lh $LOCAL_DIR/*.csv
echo ""

# =====================================================
# PASO 4: LIMPIAR DIRECTORIO HDFS SI EXISTE
# =====================================================
echo -e "${BLUE}🗑️  Paso 4: Limpiando directorio HDFS si existe...${NC}"
hdfs dfs -rm -r $HDFS_DIR 2>/dev/null
echo -e "${YELLOW}   ⚠️  Directorio HDFS limpiado (si existía)${NC}"
echo ""

# =====================================================
# PASO 5: CREAR DIRECTORIO EN HDFS
# =====================================================
echo -e "${BLUE}📂 Paso 5: Creando directorio en HDFS...${NC}"
hdfs dfs -mkdir -p $HDFS_DIR

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Directorio HDFS creado: $HDFS_DIR${NC}"
else
    echo -e "${RED}❌ Error al crear directorio HDFS${NC}"
    exit 1
fi
echo ""

# =====================================================
# PASO 6: SUBIR ARCHIVOS A HDFS
# =====================================================
echo -e "${BLUE}⬆️  Paso 6: Subiendo archivos a HDFS...${NC}"
echo ""

# Subir vuelos 2021
echo "   📤 Subiendo $VUELOS_2021_FILE..."
hdfs dfs -put -f $VUELOS_2021_FILE $HDFS_DIR/

if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✅ $VUELOS_2021_FILE subido${NC}"
else
    echo -e "${RED}   ❌ Error al subir $VUELOS_2021_FILE${NC}"
    exit 1
fi

# Subir vuelos 2022
echo "   📤 Subiendo $VUELOS_2022_FILE..."
hdfs dfs -put -f $VUELOS_2022_FILE $HDFS_DIR/

if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✅ $VUELOS_2022_FILE subido${NC}"
else
    echo -e "${RED}   ❌ Error al subir $VUELOS_2022_FILE${NC}"
    exit 1
fi

# Subir aeropuertos
echo "   📤 Subiendo $AEROPUERTOS_FILE..."
hdfs dfs -put -f $AEROPUERTOS_FILE $HDFS_DIR/

if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✅ $AEROPUERTOS_FILE subido${NC}"
else
    echo -e "${RED}   ❌ Error al subir $AEROPUERTOS_FILE${NC}"
    exit 1
fi
echo ""

# =====================================================
# PASO 7: VERIFICAR ARCHIVOS EN HDFS
# =====================================================
echo -e "${BLUE}✅ Paso 7: Verificando archivos en HDFS...${NC}"
hdfs dfs -ls -h $HDFS_DIR
echo ""

# =====================================================
# PASO 8: LIMPIAR ARCHIVOS LOCALES (OPCIONAL)
# =====================================================
echo -e "${BLUE}🧹 Paso 8: ¿Desea eliminar archivos locales? (s/n)${NC}"
read -t 5 -p "Respuesta (5s timeout): " respuesta || respuesta="n"

if [ "$respuesta" = "s" ]; then
    rm -f $LOCAL_DIR/*.csv
    echo -e "${GREEN}✅ Archivos locales eliminados${NC}"
else
    echo -e "${YELLOW}⚠️  Archivos locales conservados en $LOCAL_DIR${NC}"
fi
echo ""

# =====================================================
# RESUMEN FINAL
# =====================================================
echo "=========================================="
echo -e "${GREEN}✅ INGEST COMPLETADO EXITOSAMENTE${NC}"
echo "=========================================="
echo ""
echo "📊 Resumen:"
echo "   - Archivos descargados: 3"
echo "   - Ubicación local: $LOCAL_DIR"
echo "   - Ubicación HDFS: $HDFS_DIR"
echo ""
echo "📁 Archivos en HDFS:"
hdfs dfs -ls $HDFS_DIR | awk '{print "   •", $8, "(" $5 ")"}'
echo ""
echo "🎯 Siguiente paso: Crear tablas en Hive"
echo "   Comando: hive -f /home/hadoop/queries_aviacion.sql"
echo ""

