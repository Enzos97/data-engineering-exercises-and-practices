#!/bin/bash

# Script: sqoop_import_clientes.sh
# Descripción: Importa datos de clientes con productos vendidos desde PostgreSQL a HDFS
# Autor: Hadoop
# Fecha: 2025-11-12

# Cargar variables de entorno de Hadoop
export HADOOP_HOME=/home/hadoop/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:/usr/lib/sqoop/bin:$PATH

echo "=== IMPORTANDO DATOS DE CLIENTES CON SQOOP ==="

# Configuración PostgreSQL
DB_HOST="172.17.0.1"
DB_PORT="5432"
DB_NAME="northwind"
DB_USER="postgres"
PASSWORD_FILE="file:///home/hadoop/password.txt"
HDFS_DEST_DIR="/sqoop/ingest/customers"

# Crear directorio HDFS
echo "1. Creando directorio HDFS: $HDFS_DEST_DIR"
hdfs dfs -mkdir -p $HDFS_DEST_DIR

# Limpiar directorio si ya existe
echo "2. Limpiando directorio destino si existe..."
hdfs dfs -rm -r $HDFS_DEST_DIR/* 2>/dev/null

# Ejecutar Sqoop import con consulta
echo "3. Ejecutando Sqoop import con consulta compleja..."
sqoop import \
    --connect jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME} \
    --username $DB_USER \
    --password-file $PASSWORD_FILE \
    --query "SELECT c.customer_id, c.company_name, COUNT(od.product_id) as productos_vendidos FROM customers c JOIN orders o ON c.customer_id = o.customer_id JOIN order_details od ON o.order_id = od.order_id WHERE \$CONDITIONS GROUP BY c.customer_id, c.company_name" \
    --target-dir $HDFS_DEST_DIR \
    --as-parquetfile \
    --compress \
    --compression-codec snappy \
    --split-by customer_id \
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

