#!/bin/bash

# =============================================================================
# Script de Ejercicios Sqoop - Práctica de Ingesta de Datos
# =============================================================================
# Este script contiene todos los comandos ejecutados en la práctica de Sqoop
# para importar datos desde PostgreSQL a HDFS
# =============================================================================

echo "=========================================="
echo "PRÁCTICA SQOOP - INGESTA DE DATOS"
echo "=========================================="

# Configuración de variables
DB_HOST="172.17.0.1"
DB_PORT="5432"
DB_NAME="northwind"
DB_USER="postgres"
DB_PASSWORD="edvai"

echo "Configuración:"
echo "- Host: $DB_HOST"
echo "- Puerto: $DB_PORT"
echo "- Base de datos: $DB_NAME"
echo "- Usuario: $DB_USER"
echo ""

# =============================================================================
# EJERCICIO 1: Listar tablas de la base de datos northwind
# =============================================================================
echo "=========================================="
echo "EJERCICIO 1: Listar tablas de northwind"
echo "=========================================="

echo "Comando: sqoop list-tables"
echo "Resultado esperado: Lista de todas las tablas disponibles"
echo ""

sqoop list-tables \
  --connect jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME \
  --username $DB_USER -P

echo ""
echo "=========================================="
echo ""

# =============================================================================
# EJERCICIO 2: Mostrar los clientes de Argentina
# =============================================================================
echo "=========================================="
echo "EJERCICIO 2: Clientes de Argentina"
echo "=========================================="

echo "Comando: sqoop eval con consulta SQL"
echo "Resultado esperado: Registros de clientes de Argentina"
echo ""

sqoop eval \
  --connect jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME \
  --username $DB_USER \
  --P \
  --query "select * from customers where country = 'Argentina'"

echo ""
echo "=========================================="
echo ""

# =============================================================================
# EJERCICIO 3: Importar tabla orders completa
# =============================================================================
echo "=========================================="
echo "EJERCICIO 3: Importar tabla orders completa"
echo "=========================================="

echo "Comando: sqoop import para tabla orders"
echo "Formato: Parquet"
echo "Directorio destino: /sqoop/ingest/orders"
echo ""

sqoop import \
  --connect "jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME" \
  --username $DB_USER \
  --table orders \
  --m 1 \
  --P \
  --target-dir /sqoop/ingest/orders \
  --as-parquetfile \
  --delete-target-dir

echo ""
echo "Verificación: hdfs dfs -ls /sqoop/ingest/orders/"
hdfs dfs -ls /sqoop/ingest/orders/
echo "=========================================="
echo ""

# =============================================================================
# EJERCICIO 4: Importar productos con más de 20 unidades en stock
# =============================================================================
echo "=========================================="
echo "EJERCICIO 4: Productos con más de 20 unidades en stock"
echo "=========================================="

echo "Comando: sqoop import con filtro WHERE"
echo "Filtro: units_in_stock > 20"
echo "Directorio destino: /sqoop/ingest/products_high_stock"
echo ""

sqoop import \
  --connect "jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME" \
  --username $DB_USER \
  --table products \
  --m 1 \
  --P \
  --target-dir /sqoop/ingest/products_high_stock \
  --as-parquetfile \
  --where "units_in_stock > 20" \
  --delete-target-dir

echo ""
echo "Verificación: hdfs dfs -ls /sqoop/ingest/products_high_stock/"
hdfs dfs -ls /sqoop/ingest/products_high_stock/
echo "=========================================="
echo ""

# =============================================================================
# COMANDOS ADICIONALES DE VERIFICACIÓN
# =============================================================================
echo "=========================================="
echo "VERIFICACIÓN DE RESULTADOS"
echo "=========================================="

echo "1. Listar todos los directorios creados en /sqoop/ingest/:"
hdfs dfs -ls /sqoop/ingest/

echo ""
echo "2. Verificar tamaño de archivos:"
hdfs dfs -du -h /sqoop/ingest/

echo ""
echo "3. Contar archivos en cada directorio:"
echo "Orders:"
hdfs dfs -ls /sqoop/ingest/orders/ | wc -l
echo "Products high stock:"
hdfs dfs -ls /sqoop/ingest/products_high_stock/ | wc -l

echo ""
echo "=========================================="
echo "PRÁCTICA COMPLETADA"
echo "=========================================="
echo "Todos los ejercicios han sido ejecutados exitosamente."
echo "Los datos han sido importados en formato Parquet a HDFS."
echo "=========================================="
