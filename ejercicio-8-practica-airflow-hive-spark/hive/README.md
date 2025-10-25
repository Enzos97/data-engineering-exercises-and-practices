# Hive - Ejercicio 8

Esta carpeta contiene la configuración y documentación de Apache Hive para el almacenamiento y consulta de datos NYC Taxi.

## 📁 Archivos Incluidos

### 1️⃣ **hive-setup.sql**
Script SQL completo para configurar la base de datos y tabla en Hive.

## 🗄️ Configuración de Base de Datos

### Base de Datos: `tripdata`
- **Propósito**: Almacenar datos de viajes de taxis NYC
- **Tipo**: Base de datos estándar de Hive
- **Ubicación**: `/user/hive/warehouse/tripdata.db/`

### Tabla: `airport_trips`
- **Tipo**: Tabla externa (EXTERNAL TABLE)
- **Formato**: Parquet
- **Propósito**: Almacenar viajes a aeropuertos con filtros específicos

## 📊 Esquema de la Tabla

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `tpep_pickup_datetime` | STRING | Fecha y hora de recogida |
| `airport_fee` | DOUBLE | Cargo por aeropuerto |
| `payment_type` | INT | Tipo de pago (1=Credit, 2=Cash, etc.) |
| `tolls_amount` | DOUBLE | Monto de peajes |
| `total_amount` | DOUBLE | Monto total del viaje |

## 🔧 Configuración de Almacenamiento

### Formato Parquet
- **Ventajas**: Compresión eficiente, consultas rápidas
- **SerDe**: `org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe`
- **InputFormat**: `org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat`
- **OutputFormat**: `org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat`

### Ubicación en HDFS
```
hdfs://172.17.0.2:9000/user/hive/warehouse/tripdata.db/airport_trips
```

## 🚀 Instalación y Configuración

### Opción 1: Ejecutar Comandos SQL Directamente (Recomendado)
```bash
# Conectar a Hive
hive

# Ejecutar comandos SQL directamente en la consola
hive> CREATE DATABASE IF NOT EXISTS tripdata;
OK
Time taken: 2.145 seconds

hive> USE tripdata;
OK
Time taken: 0.087 seconds

hive> CREATE EXTERNAL TABLE IF NOT EXISTS airport_trips (
    >     tpep_pickup_datetime STRING,
    >     airport_fee DOUBLE,
    >     payment_type INT,
    >     tolls_amount DOUBLE,
    >     total_amount DOUBLE
    > )
    > STORED AS PARQUET
    > LOCATION '/user/hive/warehouse/tripdata.db/airport_trips';
OK
Time taken: 2.731 seconds
```

### Opción 2: Usar Script SQL
```bash
# Conectar a Hive
hive

# Ejecutar script (si prefieres usar el archivo)
source hive-setup.sql;
```

### 3. Verificar Configuración
```sql
-- Verificar base de datos
SHOW DATABASES;

-- Usar base de datos
USE tripdata;

-- Verificar tablas
SHOW TABLES;

-- Verificar esquema
DESCRIBE FORMATTED airport_trips;
```

## 📋 Comandos SQL Principales

### Creación de Base de Datos
```sql
CREATE DATABASE IF NOT EXISTS tripdata;
USE tripdata;
```

### Creación de Tabla Externa
```sql
CREATE EXTERNAL TABLE IF NOT EXISTS airport_trips (
    tpep_pickup_datetime STRING,
    airport_fee DOUBLE,
    payment_type INT,
    tolls_amount DOUBLE,
    total_amount DOUBLE
)
STORED AS PARQUET
LOCATION '/user/hive/warehouse/tripdata.db/airport_trips';
```

### Verificaciones Básicas
```sql
-- Contar registros
SELECT COUNT(*) FROM airport_trips;

-- Ver muestra de datos
SELECT * FROM airport_trips LIMIT 10;

-- Verificar esquema
DESCRIBE FORMATTED airport_trips;
```

## 📊 Consultas de Análisis

### 1. Estadísticas Generales
```sql
SELECT 
    COUNT(*) as total_viajes,
    AVG(airport_fee) as promedio_airport_fee,
    AVG(total_amount) as promedio_total_amount
FROM airport_trips;
```

### 2. Análisis por Tipo de Pago
```sql
SELECT 
    payment_type,
    COUNT(*) as cantidad_viajes,
    AVG(total_amount) as promedio_monto
FROM airport_trips
GROUP BY payment_type;
```

### 3. Top Viajes por Monto
```sql
SELECT 
    tpep_pickup_datetime,
    total_amount
FROM airport_trips
ORDER BY total_amount DESC
LIMIT 5;
```

## 🔍 Monitoreo y Verificación

### Verificar Estado de la Tabla
```sql
-- Información detallada
DESCRIBE FORMATTED airport_trips;

-- Verificar ubicación
SHOW CREATE TABLE airport_trips;
```

### Verificar Datos
```sql
-- Contar registros
SELECT COUNT(*) FROM airport_trips;

-- Verificar tipos de pago
SELECT DISTINCT payment_type FROM airport_trips;

-- Verificar rangos de montos
SELECT 
    MIN(total_amount) as min_monto,
    MAX(total_amount) as max_monto,
    AVG(total_amount) as promedio_monto
FROM airport_trips;
```

## ⚠️ Troubleshooting

### Error: "Database does not exist"
```sql
-- Crear base de datos
CREATE DATABASE tripdata;
USE tripdata;
```

### Error: "Table not found"
```sql
-- Verificar tablas existentes
SHOW TABLES;

-- Recrear tabla si es necesario
DROP TABLE IF EXISTS airport_trips;
-- Ejecutar CREATE EXTERNAL TABLE nuevamente
```

### Error: "Location not found"
```bash
# Verificar directorio en HDFS
hdfs dfs -ls /user/hive/warehouse/tripdata.db/

# Crear directorio si es necesario
hdfs dfs -mkdir -p /user/hive/warehouse/tripdata.db/airport_trips
```

## 📈 Métricas de Rendimiento

### Consultas Optimizadas
- **Formato Parquet**: Consultas más rápidas
- **Índices**: No necesarios con Parquet
- **Compresión**: Reducción de espacio ~70%

### Tiempos de Consulta Esperados
- **COUNT(*)**: ~1-2 segundos
- **SELECT con filtros**: ~2-5 segundos
- **GROUP BY**: ~5-10 segundos
- **ORDER BY**: ~3-8 segundos

## 🎯 Resultados Esperados

### Después de la Configuración
- ✅ Base de datos `tripdata` creada
- ✅ Tabla externa `airport_trips` configurada
- ✅ Formato Parquet establecido
- ✅ Ubicación en HDFS configurada

### Después del Procesamiento
- ✅ Datos insertados en la tabla
- ✅ 1 registro filtrado disponible
- ✅ Consultas funcionando correctamente
- ✅ Verificación exitosa con Airflow

## 🔄 Mantenimiento

### Limpieza de Datos
```sql
-- Eliminar registros antiguos (si es necesario)
DELETE FROM airport_trips WHERE tpep_pickup_datetime < '2021-01-01';
```

### Optimización de Tabla
```sql
-- Analizar tabla para optimización
ANALYZE TABLE airport_trips COMPUTE STATISTICS;
```

### Backup de Datos
```bash
# Copiar datos a ubicación de backup
hdfs dfs -cp /user/hive/warehouse/tripdata.db/airport_trips /backup/airport_trips_$(date +%Y%m%d)
```
