# Análisis de Datos con PySpark - NYC Taxi Data

## 🎯 Objetivo

Realizar análisis de datos sobre el dataset de taxis amarillos de NYC utilizando PySpark y consultas SQL.

## 📊 Dataset

- **Archivo**: `yellow_tripdata_2021-01.parquet`
- **Ubicación**: `hdfs:///nifi/yellow_tripdata_2021-01.parquet`
- **Tamaño**: ~20.6 MB
- **Registro**: Enero 2021
- **Diccionario**: [NYC TLC Data Dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf)

## 🔧 Configuración Inicial

### 1. Iniciar PySpark

```bash
# En el contenedor de Hadoop
hadoop@cd7195a9ebf6:/$ pyspark
```

### 2. Cargar Datos

```python
# Cargar archivo Parquet desde HDFS
df = spark.read.parquet("hdfs:///nifi/yellow_tripdata_2021-01.parquet")

# Crear vista temporal para consultas SQL
df.createOrReplaceTempView("yellow_tripdata")

# Verificar datos
df.show()
```

## 📋 Consultas de Análisis

### 3.1 **Viajes con Total Menor a $10**

**Objetivo**: Mostrar VendorID, fecha de pickup y monto total para viajes menores a $10

```python
spark.sql("""
SELECT VendorID, tpep_pickup_datetime, total_amount
FROM yellow_tripdata
WHERE total_amount < 10
""").show(10)
```

**Resultado esperado**:
```
+--------+--------------------+------------+
|VendorID|tpep_pickup_datetime|total_amount|
+--------+--------------------+------------+
|       1| 2020-12-31 21:51:20|         4.3|
|       2| 2020-12-31 21:42:11|         8.3|
|       2| 2020-12-31 21:04:21|        9.96|
|       2| 2020-12-31 21:43:41|         9.3|
|       2| 2020-12-31 21:36:08|         5.8|
|       1| 2020-12-31 21:03:13|         0.0|
|       1| 2020-12-31 21:30:32|         9.3|
|       2| 2020-12-31 21:16:19|         9.8|
|       2| 2020-12-31 21:57:26|         8.8|
|       2| 2020-12-31 21:33:33|        9.96|
+--------+--------------------+------------+
```

### 3.2 **Top 10 Días con Mayor Recaudación**

**Objetivo**: Mostrar los 10 días que más dinero se recaudó

```python
spark.sql("""
SELECT
    DATE(tpep_pickup_datetime) AS pickup_date,
    SUM(total_amount) AS total_revenue
FROM yellow_tripdata
GROUP BY DATE(tpep_pickup_datetime)
ORDER BY total_revenue DESC
LIMIT 10
""").show()
```

**Resultado esperado**:
```
+-----------+-----------------+
|pickup_date|    total_revenue|
+-----------+-----------------+
| 2021-01-28|961322.5600002451|
| 2021-01-22|942205.9300002148|
| 2021-01-29|937373.5100002222|
| 2021-01-21|932444.4500002082|
| 2021-01-15|931628.1900002063|
| 2021-01-14|926664.0400001821|
| 2021-01-27|  895259.87000017|
| 2021-01-19|890581.4500001629|
| 2021-01-07|887670.1600001527|
| 2021-01-08| 878002.730000146|
+-----------+-----------------+
```

### 3.3 **Top 10 Viajes con Menor Recaudación (>10 millas)**

**Objetivo**: Mostrar los 10 viajes que menos dinero recaudó en distancias mayores a 10 millas

```python
spark.sql("""
SELECT
    trip_distance,
    total_amount
FROM yellow_tripdata
WHERE trip_distance > 10
ORDER BY total_amount ASC
LIMIT 10
""").show()
```

**Resultado esperado**:
```
+-------------+------------+
|trip_distance|total_amount|
+-------------+------------+
|        12.68|      -252.3|
|        34.35|     -176.42|
|        14.75|      -152.8|
|        33.96|     -127.92|
|         29.1|      -119.3|
|        26.94|      -111.3|
|        20.08|      -107.8|
|        19.55|      -102.8|
|        19.16|      -90.55|
|        25.83|      -88.54|
+-------------+------------+
```

### 3.4 **Viajes con Más de 2 Pasajeros y Pago con Tarjeta**

**Objetivo**: Mostrar viajes de más de 2 pasajeros que pagaron con tarjeta de crédito

```python
spark.sql("""
SELECT
    trip_distance,
    tpep_pickup_datetime
FROM yellow_tripdata
WHERE passenger_count > 2
  AND payment_type = 1
""").show(10, truncate=False)
```

**Resultado esperado**:
```
+-------------+--------------------+
|trip_distance|tpep_pickup_datetime|
+-------------+--------------------+
|6.11         |2020-12-31 21:15:52 |
|1.7          |2020-12-31 21:31:06 |
|3.15         |2020-12-31 21:34:37 |
|10.74        |2020-12-31 21:19:57 |
|2.01         |2020-12-31 21:28:07 |
|2.85         |2020-12-31 21:08:04 |
|1.68         |2020-12-31 21:22:02 |
|0.77         |2020-12-31 21:33:33 |
|0.4          |2020-12-31 21:45:29 |
|16.54        |2020-12-31 21:36:53 |
+-------------+--------------------+
```

### 3.5 **Top 7 Viajes con Mayor Propina (>10 millas)**

**Objetivo**: Mostrar los 7 viajes con mayor propina en distancias mayores a 10 millas

```python
spark.sql("""
SELECT
    tpep_pickup_datetime,
    trip_distance,
    passenger_count,
    tip_amount
FROM yellow_tripdata
WHERE trip_distance > 10
ORDER BY tip_amount DESC
LIMIT 7
""").show(truncate=False)
```

**Resultado esperado**:
```
+--------------------+-------------+---------------+----------+
|tpep_pickup_datetime|trip_distance|passenger_count|tip_amount|
+--------------------+-------------+---------------+----------+
|2021-01-20 08:22:05 |427.7        |1.0            |1140.44   |
|2021-01-03 08:36:52 |267.7        |1.0            |369.4     |
|2021-01-12 09:57:36 |326.1        |0.0            |192.61    |
|2021-01-19 08:38:47 |260.5        |1.0            |149.03    |
|2021-01-31 20:48:50 |11.1         |0.0            |100.0     |
|2021-01-01 12:26:43 |14.86        |2.0            |99.0      |
|2021-01-18 12:50:24 |13.0         |0.0            |90.0      |
+--------------------+-------------+---------------+----------+
```

### 3.6 **Análisis por RateCodeID**

**Objetivo**: Mostrar monto total y promedio por RateCodeID, excluyendo 'Group Ride'

```python
spark.sql("""
SELECT
    RatecodeID,
    SUM(total_amount) AS total_monto,
    AVG(total_amount) AS promedio_monto
FROM yellow_tripdata
WHERE RatecodeID != 6
GROUP BY RatecodeID
""").show(truncate=False)
```

**Resultado esperado**:
```
+----------+--------------------+------------------+
|RatecodeID|total_monto         |promedio_monto    |
+----------+--------------------+------------------+
|1.0       |1.9496468430212937E7|15.606626116946773|
|4.0       |90039.93000000082   |74.90842762063296 |
|3.0       |67363.26000000043   |78.69539719626219 |
|2.0       |973635.4700000732   |65.52937609369182 |
|99.0      |1748.0699999999997  |48.55749999999999 |
|5.0       |255075.08999999086  |48.939963545662096|
+----------+--------------------+------------------+
```

## 📊 Insights de Negocio

### Análisis de Resultados

1. **Viajes Económicos**: Muchos viajes menores a $10, indicando viajes cortos
2. **Días de Mayor Recaudación**: Enero 28 fue el día más rentable
3. **Viajes de Larga Distancia**: Algunos viajes muestran montos negativos (reembolsos)
4. **Viajes Grupales**: Viajes con más de 2 pasajeros son menos comunes
5. **Propinas Generosas**: Viajes largos pueden generar propinas muy altas
6. **RateCodeID**: La mayoría de viajes son tipo 1 (tarifa estándar)

### Métricas Clave

- **Total de registros**: ~1.2 millones de viajes
- **Período**: Enero 2021
- **VendorID**: 1 y 2 (principales proveedores)
- **Formato de datos**: Parquet optimizado
- **Tiempo de procesamiento**: < 1 minuto por consulta

## 🔧 Optimizaciones

### Consultas Optimizadas

```python
# Usar cache para consultas repetidas
df.cache()

# Usar repartition para mejor rendimiento
df.repartition(4)

# Usar broadcast para joins pequeños
spark.conf.set("spark.sql.adaptive.enabled", "true")
```

### Configuración de Spark

```python
# Configurar memoria
spark.conf.set("spark.executor.memory", "2g")
spark.conf.set("spark.driver.memory", "1g")

# Configurar paralelismo
spark.conf.set("spark.sql.shuffle.partitions", "200")
```
