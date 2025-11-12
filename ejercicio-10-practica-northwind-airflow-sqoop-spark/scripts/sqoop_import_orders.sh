#!/bin/bash

# Script: sqoop_import_envios.sh
# Descripción: Importa datos de órdenes con información de empresa desde PostgreSQL a HDFS
# Autor: Hadoop
# Fecha: 2025-11-12

# Cargar variables de entorno de Hadoop
export HADOOP_HOME=/home/hadoop/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:/usr/lib/sqoop/bin:$PATH

echo "=== IMPORTANDO DATOS DE ENVÍOS CON SQOOP ==="

# Configuración PostgreSQL
DB_HOST="172.17.0.1"
DB_PORT="5432"
DB_NAME="northwind"
DB_USER="postgres"
PASSWORD_FILE="file:///home/hadoop/password.txt"
HDFS_DEST_DIR="/sqoop/ingest/envios"

# Crear directorio HDFS
echo "1. Creando directorio HDFS: $HDFS_DEST_DIR"
hdfs dfs -mkdir -p $HDFS_DEST_DIR

# Limpiar directorio si ya existe
echo "2. Limpiando directorio destino si existe..."
hdfs dfs -rm -r $HDFS_DEST_DIR/* 2>/dev/null

# Ejecutar Sqoop import con consulta
echo "3. Ejecutando Sqoop import..."
sqoop import \
    --connect jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME} \
    --username $DB_USER \
    --password-file $PASSWORD_FILE \
    --query "SELECT o.order_id, o.shipped_date, c.company_name, c.phone FROM orders o JOIN customers c ON o.customer_id = c.customer_id WHERE o.shipped_date IS NOT NULL AND \$CONDITIONS" \
    --target-dir $HDFS_DEST_DIR \
    --as-parquetfile \
    --compress \
    --compression-codec snappy \
    --split-by order_id \
    --m 1

if [ $? -eq 0 ]; then
    echo "✅ Importación completada exitosamente"
else
    echo "❌ Error en la importación Sqoop"
    exit 1
fi

# Verificar datos en HDFS
echo "4. Verificando datos en HDFS..."
hdfs dfs -ls -h $HDFS_DEST_DIR

echo "=== PROCESO COMPLETADO ==="

