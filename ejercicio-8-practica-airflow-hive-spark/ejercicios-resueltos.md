# Ejercicios Resueltos - Práctica Airflow + Hive + Spark

Este documento contiene la resolución completa de todos los ejercicios del pipeline de procesamiento de datos NYC Taxi.

## 📋 Resumen de Ejercicios

| Ejercicio | Descripción | Estado | Tiempo |
|-----------|-------------|--------|--------|
| 1 | Crear base de datos y tabla en Hive | ✅ Completado | ~5 min |
| 2 | Verificar esquema de tabla | ✅ Completado | ~1 min |
| 3 | Script de descarga e ingesta | ✅ Completado | ~2 min |
| 4 | Procesamiento con Spark | ✅ Completado | ~2 min |
| 5 | Orquestación con Airflow | ✅ Completado | ~3 min |

---

## 🗄️ Ejercicio 1: Configuración de Hive

### Objetivo
Crear la base de datos `tripdata` y la tabla externa `airport_trips` en Hive.

### Comandos Ejecutados

```sql
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS tripdata;
OK
Time taken: 2.145 seconds

-- Usar base de datos
USE tripdata;
OK
Time taken: 0.087 seconds

-- Crear tabla externa
CREATE EXTERNAL TABLE IF NOT EXISTS airport_trips (
    tpep_pickup_datetime STRING,
    airport_fee DOUBLE,
    payment_type INT,
    tolls_amount DOUBLE,
    total_amount DOUBLE
)
STORED AS PARQUET
LOCATION '/user/hive/warehouse/tripdata.db/airport_trips';
OK
Time taken: 2.731 seconds

-- Verificar tablas
SHOW TABLES;
OK
airport_trips
tripdata_table
Time taken: 0.244 seconds, Fetched: 2 row(s)
```

### Resultado
✅ **Base de datos `tripdata` creada exitosamente**
✅ **Tabla externa `airport_trips` configurada con esquema Parquet**

---

## 🔍 Ejercicio 2: Verificación de Esquema

### Objetivo
Verificar la estructura y metadatos de la tabla `airport_trips`.

### Comando Ejecutado

```sql
DESCRIBE FORMATTED airport_trips;
```

### Resultado Detallado

**Columnas:**
- `tpep_pickup_datetime`: string
- `airport_fee`: double
- `payment_type`: int
- `tolls_amount`: double
- `total_amount`: double

**Información de la Tabla:**
- **Database**: tripdata
- **Owner**: hadoop
- **CreateTime**: Wed Oct 22 20:12:15 ART 2025
- **Table Type**: EXTERNAL_TABLE
- **Location**: hdfs://172.17.0.2:9000/user/hive/warehouse/tripdata.db/airport_trips

**Configuración de Almacenamiento:**
- **SerDe Library**: org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe
- **InputFormat**: org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat
- **OutputFormat**: org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat
- **Compressed**: No

### Resultado
✅ **Esquema verificado correctamente**
✅ **Configuración Parquet confirmada**

---

## 📥 Ejercicio 3: Script de Descarga e Ingesta

### Objetivo
Crear script automatizado para descargar archivos Parquet e ingerirlos en HDFS.

### Script Creado: `download_and_ingest.sh`

**Funcionalidades implementadas:**
- ✅ Verificación de servicios HDFS
- ✅ Descarga de archivos desde URLs públicas
- ✅ Validación de conectividad
- ✅ Subida automática a HDFS
- ✅ Limpieza de archivos temporales

### Ejecución del Script

```bash
# Hacer ejecutable
chmod +x download_and_ingest.sh

# Ejecutar script
./download_and_ingest.sh
```

### Resultados de la Ejecución

```
=== INICIANDO DESCARGA E INGESTA A HDFS ===
Fecha: Wed Oct 22 21:48:57 -03 2025

1. Verificando servicios HDFS...
✅ Servicios detectados: NameNode, DataNode

2. Verificando directorio HDFS: /user/hadoop/tripdata/raw
✅ Directorio creado exitosamente

3. Probando conectividad con URLs...
✅ Conectividad OK

4. Descargando archivos...
✅ Archivos descargados correctamente
   - yellow_tripdata_2021-01.parquet: 21M
   - yellow_tripdata_2021-02.parquet: 21M

5. Subiendo archivos a HDFS...
✅ Archivos subidos correctamente a HDFS

6. Verificando carga en HDFS...
📊 Contenido del directorio /user/hadoop/tripdata/raw:
Found 2 items
-rw-r--r--   1 hadoop supergroup     20.7 M 2025-10-22 21:49 /user/hadoop/tripdata/raw/yellow_tripdata_2021-01.parquet
-rw-r--r--   1 hadoop supergroup     20.8 M 2025-10-22 21:49 /user/hadoop/tripdata/raw/yellow_tripdata_2021-02.parquet

7. Limpiando archivos locales...
=== PROCESO COMPLETADO EXITOSAMENTE ===
✅ Archivos disponibles en HDFS: /user/hadoop/tripdata/raw
📅 Fecha finalización: Wed Oct 22 21:49:16 -03 2025
```

### Resultado
✅ **2 archivos Parquet descargados y subidos a HDFS**
✅ **Total de datos**: ~41.5 MB
✅ **Tiempo de ejecución**: ~19 segundos

---

## ⚡ Ejercicio 4: Procesamiento con Spark

### Objetivo
Procesar datos con Spark, aplicar filtros específicos e insertar resultados en Hive.

### Script Creado: `process_airport_trips.py`

**Funcionalidades implementadas:**
- ✅ Lectura de archivos Parquet desde HDFS
- ✅ Unión de datasets de enero y febrero 2021
- ✅ Filtrado de viajes a aeropuertos pagados en efectivo
- ✅ Inserción de resultados en tabla Hive
- ✅ Estadísticas y validaciones de datos

### Ejecución del Script

```bash
# Hacer ejecutable
chmod +x process_airport_trips.py

# Ejecutar con Spark
spark-submit process_airport_trips.py
```

### Resultados de la Ejecución

```
=== INICIANDO PROCESAMIENTO CON SPARK ===

1. 📂 Leyendo archivos Parquet desde HDFS...
   ✅ Enero 2021: 1,369,769 registros
   ✅ Febrero 2021: 1,371,709 registros

2. 🔄 Uniendo datos de enero y febrero...
   ✅ Total combinado: 2,741,478 registros

3. 📊 Esquema de datos:
root
 |-- VendorID: long (nullable = true)
 |-- tpep_pickup_datetime: timestamp (nullable = true)
 |-- tpep_dropoff_datetime: timestamp (nullable = true)
 |-- passenger_count: double (nullable = true)
 |-- trip_distance: double (nullable = true)
 |-- RatecodeID: double (nullable = true)
 |-- store_and_fwd_flag: string (nullable = true)
 |-- PULocationID: long (nullable = true)
 |-- DOLocationID: long (nullable = true)
 |-- payment_type: long (nullable = true)
 |-- fare_amount: double (nullable = true)
 |-- extra: double (nullable = true)
 |-- mta_tax: double (nullable = true)
 |-- tip_amount: double (nullable = true)
 |-- tolls_amount: double (nullable = true)
 |-- improvement_surcharge: double (nullable = true)
 |-- total_amount: double (nullable = true)
 |-- congestion_surcharge: double (nullable = true)
 |-- airport_fee: double (nullable = true)

4. 🔍 Filtrando viajes a aeropuertos pagados en efectivo...
   ✅ Viajes filtrados: 1 registros

5. 🗂️ Seleccionando columnas para tabla Hive...
6. 👀 Muestra de datos a insertar:
+--------------------+-----------+------------+------------+------------+
|tpep_pickup_datetime|airport_fee|payment_type|tolls_amount|total_amount|
+--------------------+-----------+------------+------------+------------+
|2021-02-21 02:36:21 |1.25       |2           |0.0         |59.55       |
+--------------------+-----------+------------+------------+------------+

7. 📈 Estadísticas de los datos:
+-------+-----------+------------+------------+------------+
|summary|airport_fee|payment_type|tolls_amount|total_amount|
+-------+-----------+------------+------------+------------+
|  count|          1|           1|           1|           1|
|   mean|       1.25|         2.0|         0.0|       59.55|
| stddev|       null|        null|        null|        null|
|    min|       1.25|           2|         0.0|       59.55|
|    max|       1.25|           2|         0.0|       59.55|
+-------+-----------+------------+------------+------------+

8. 💾 Insertando datos en la tabla Hive airport_trips...
✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE
📊 Total de viajes insertados: 1
🛑 Sesión de Spark cerrada
```

### Resultado
✅ **2,741,478 registros procesados**
✅ **1 viaje filtrado e insertado en Hive**
✅ **Filtros aplicados**: Aeropuertos + pago en efectivo (payment_type = 2)

---

## 🎯 Ejercicio 5: Orquestación con Airflow

### Objetivo
Crear DAG de Airflow para orquestar todo el pipeline de procesamiento.

### DAG Creado: `airport_trips_processing.py`

**Configuración del DAG:**
- **DAG ID**: `airport_trips_processing`
- **Descripción**: "Orquesta la descarga, ingestión y procesamiento de datos NYC Taxi"
- **Propietario**: `hadoop`
- **Programación**: Manual (sin schedule)
- **Tags**: `['spark', 'hive', 'etl']`

### Tareas del DAG

1. **`inicio`** - DummyOperator (tarea de inicio)
2. **`ingesta_datos`** - BashOperator (ejecuta `download_and_ingest.sh`)
3. **`procesa_spark`** - BashOperator (ejecuta `process_airport_trips.py`)
4. **`verifica_tabla_hive`** - BashOperator (verifica resultados con beeline)
5. **`fin_proceso`** - DummyOperator (tarea de finalización)

### Flujo de Dependencias
```
inicio → ingesta_datos → procesa_spark → verifica_tabla_hive → fin_proceso
```

### Ejecución del DAG

**Estado del DAG**: ✅ **SUCCESS** (todas las tareas completadas exitosamente)

**Logs de la tarea de verificación:**
```
[2025-10-23, 03:06:47 UTC] {subprocess.py:92} INFO - +--------+
[2025-10-23, 03:06:47 UTC] {subprocess.py:92} INFO - | total  |
[2025-10-23, 03:06:47 UTC] {subprocess.py:92} INFO - +--------+
[2025-10-23, 03:06:47 UTC] {subprocess.py:92} INFO - | 2      |
[2025-10-23, 03:06:47 UTC] {subprocess.py:92} INFO - +--------+
[2025-10-23, 03:06:47 UTC] {subprocess.py:92} INFO - 1 row selected (8.53 seconds)
```

### Resultado
✅ **DAG ejecutado exitosamente**
✅ **2 registros verificados en la tabla Hive**
✅ **Pipeline completo automatizado**

---

## 📊 Resumen de Resultados

### Métricas Finales
- **Registros procesados**: 2,741,478
- **Registros filtrados**: 1
- **Archivos procesados**: 2 archivos Parquet
- **Tiempo total**: ~13 minutos
- **Estado final**: ✅ SUCCESS

### Datos Filtrados
**Viaje encontrado:**
- **Fecha**: 2021-02-21 02:36:21
- **Airport Fee**: $1.25
- **Payment Type**: 2 (efectivo)
- **Tolls Amount**: $0.00
- **Total Amount**: $59.55

### Infraestructura Utilizada
- **HDFS**: Almacenamiento distribuido
- **Hive**: Data warehouse
- **Spark**: Procesamiento distribuido
- **Airflow**: Orquestación de workflows
- **Parquet**: Formato de datos columnar

---

## 🎉 Conclusiones

El pipeline de procesamiento de datos NYC Taxi se ejecutó exitosamente, demostrando:

1. ✅ **Integración completa** entre Hive, Spark y Airflow
2. ✅ **Automatización efectiva** del proceso ETL
3. ✅ **Filtrado preciso** de datos según criterios específicos
4. ✅ **Orquestación robusta** con manejo de errores
5. ✅ **Verificación de resultados** automatizada

El ejercicio cumple con todos los objetivos planteados y establece las bases para pipelines de datos más complejos en entornos de producción.
