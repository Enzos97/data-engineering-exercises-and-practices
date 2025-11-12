# Ejercicios Resueltos - Clase 9: Northwind Analytics

**Consigna**: Por cada ejercicio, escribir el código y agregar una captura de pantalla del resultado obtenido.

---

## Ejercicio 1: Crear base de datos en Hive

### 📝 Enunciado

Crear una base de datos en Hive llamada `northwind_analytics`.

### 💻 Solución

#### Paso 1: Conectarse al contenedor Hadoop

```bash
docker exec -it edvai_hadoop bash
su hadoop
```

#### Paso 2: Abrir Hive

```bash
hive
```

#### Paso 3: Crear la base de datos

```sql
CREATE DATABASE IF NOT EXISTS northwind_analytics
COMMENT 'Base de datos para análisis de Northwind'
LOCATION '/user/hive/warehouse/northwind_analytics.db';
```

**Salida esperada**:
```
OK
Time taken: 4.875 seconds
```

#### Paso 4: Verificar la creación

```sql
SHOW DATABASES;
```

**Salida esperada**:
```
OK
default
f1
northwind_analytics
tripdata
Time taken: 0.474 seconds, Fetched: 4 row(s)
```

#### Paso 5: Usar la base de datos

```sql
USE northwind_analytics;
```

**Salida esperada**:
```
OK
Time taken: 0.312 seconds
```

### 📊 Captura de Pantalla

> **Archivo**: `images/ejercicio1-create-database.png`
> 
> Debe mostrar la creación de la base de datos y la verificación con `SHOW DATABASES`.

---

## Ejercicio 2: Script Sqoop para importar clientes

### 📝 Enunciado

Crear un script para importar un archivo .parquet de la base northwind que contenga la lista de clientes junto a la cantidad de productos vendidos ordenados de mayor a menor (campos `customer_id`, `company_name`, `productos_vendidos`). Luego ingestar el archivo a HDFS (carpeta `/sqoop/ingest/clientes`). Pasar la password en un archivo.

### 💻 Solución

#### Paso 1: Crear archivo de password

```bash
# En el contenedor Hadoop
cd /home/hadoop
echo "edvai" > password.txt
chmod 600 password.txt
ls -la password.txt
```

**Salida esperada**:
```
-rw------- 1 hadoop hadoop 5 Nov 12 01:00 password.txt
```

#### Paso 2: Crear el script Sqoop

```bash
cd /home/hadoop/scripts
nano sqoop_import_clientes.sh
```

**Contenido del script**:

```bash
#!/bin/bash

# Script: sqoop_import_clientes.sh
# Descripción: Importa datos de clientes con productos vendidos desde PostgreSQL a HDFS

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
```

#### Paso 3: Dar permisos de ejecución

```bash
chmod +x sqoop_import_clientes.sh
```

#### Paso 4: Ejecutar el script

```bash
./sqoop_import_clientes.sh
```

**Salida esperada**:
```
=== IMPORTANDO DATOS DE CLIENTES CON SQOOP ===
1. Creando directorio HDFS: /sqoop/ingest/customers
2. Limpiando directorio destino si existe...
3. Ejecutando Sqoop import con consulta compleja...
...
2025-11-12 00:31:28,356 INFO mapreduce.ImportJobBase: Retrieved 89 records.
✅ Importación completada exitosamente
4. Verificando datos en HDFS...
Found 3 items
drwxr-xr-x   - hadoop supergroup          0 2025-11-12 00:31 /sqoop/ingest/customers/.metadata
drwxr-xr-x   - hadoop supergroup          0 2025-11-12 00:31 /sqoop/ingest/customers/.signals
-rw-r--r--   1 hadoop supergroup      3.6 K 2025-11-12 00:31 /sqoop/ingest/customers/xxxxx.parquet
=== PROCESO COMPLETADO ===
```

### 📊 Captura de Pantalla

> **Archivo**: `images/ejercicio2-sqoop-clientes.png`
> 
> Debe mostrar la ejecución completa del script y la verificación en HDFS.

---

## Ejercicio 3: Script Sqoop para importar envíos

### 📝 Enunciado

Crear un script para importar un archivo .parquet de la base northwind que contenga la lista de órdenes junto a qué empresa realizó cada pedido (campos `order_id`, `shipped_date`, `company_name`, `phone`). Luego ingestar el archivo a HDFS (carpeta `/sqoop/ingest/envíos`). Pasar la password en un archivo.

### 💻 Solución

#### Paso 1: Crear el script Sqoop

```bash
cd /home/hadoop/scripts
nano sqoop_import_envios.sh
```

**Contenido del script**:

```bash
#!/bin/bash

# Script: sqoop_import_envios.sh
# Descripción: Importa datos de órdenes con información de empresa desde PostgreSQL a HDFS

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
```

#### Paso 2: Dar permisos y ejecutar

```bash
chmod +x sqoop_import_envios.sh
./sqoop_import_envios.sh
```

**Salida esperada**:
```
=== IMPORTANDO DATOS DE ENVÍOS CON SQOOP ===
...
2025-11-12 00:42:40,116 INFO mapreduce.ImportJobBase: Retrieved 809 records.
✅ Importación completada exitosamente
4. Verificando datos en HDFS...
Found 3 items
...
-rw-r--r--   1 hadoop supergroup     11.7 K 2025-11-12 00:42 /sqoop/ingest/envios/xxxxx.parquet
=== PROCESO COMPLETADO ===
```

### 📊 Captura de Pantalla

> **Archivo**: `images/ejercicio3-sqoop-envios.png`

---

## Ejercicio 4: Script Sqoop para importar detalles de órdenes

### 📝 Enunciado

Crear un script para importar un archivo .parquet de la base northwind que contenga la lista de detalles de órdenes (campos `order_id`, `unit_price`, `quantity`, `discount`). Luego ingestar el archivo a HDFS (carpeta `/sqoop/ingest/order_details`). Pasar la password en un archivo.

### 💻 Solución

#### Paso 1: Crear el script Sqoop

```bash
cd /home/hadoop/scripts
nano sqoop_import_order_details.sh
```

**Contenido del script**:

```bash
#!/bin/bash

# Script: sqoop_import_order_details.sh
# Descripción: Importa datos de detalles de órdenes desde PostgreSQL a HDFS

echo "=== IMPORTANDO DATOS DE DETALLES DE ÓRDENES CON SQOOP ==="

# Configuración PostgreSQL
DB_HOST="172.17.0.1"
DB_PORT="5432"
DB_NAME="northwind"
DB_USER="postgres"
PASSWORD_FILE="file:///home/hadoop/password.txt"
HDFS_DEST_DIR="/sqoop/ingest/order_details"

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
    --query "SELECT order_id, unit_price, quantity, discount FROM order_details WHERE \$CONDITIONS" \
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
```

#### Paso 2: Dar permisos y ejecutar

```bash
chmod +x sqoop_import_order_details.sh
./sqoop_import_order_details.sh
```

**Salida esperada**:
```
=== IMPORTANDO DATOS DE DETALLES DE ÓRDENES CON SQOOP ===
...
2025-11-12 00:50:23,747 INFO mapreduce.ImportJobBase: Retrieved 2155 records.
✅ Importación completada exitosamente
4. Verificando datos en HDFS...
Found 3 items
...
-rw-r--r--   1 hadoop supergroup     12.0 K 2025-11-12 00:50 /sqoop/ingest/order_details/xxxxx.parquet
=== PROCESO COMPLETADO ===
```

### 📊 Captura de Pantalla

> **Archivo**: `images/ejercicio4-sqoop-order-details.png`

---

## Ejercicio 5: Script Spark para products_sold

### 📝 Enunciado

Generar un archivo .py que permita mediante Spark insertar en hive en la db `northwind_analytics` en la tabla `products_sold`, los datos del punto 2, pero solamente aquellas compañías en las que la cantidad de productos vendidos fue mayor al promedio.

### 💻 Solución

#### Paso 1: Crear el script Spark

```bash
cd /home/hadoop/scripts
nano spark_products_sold.py
```

**Contenido del script**: (Ver archivo `scripts/spark_products_sold.py`)

#### Paso 2: Dar permisos y ejecutar

```bash
chmod +x spark_products_sold.py
spark-submit spark_products_sold.py
```

**Salida esperada**:

```
=== INICIANDO PROCESAMIENTO SPARK PARA PRODUCTS_SOLD ===

1. 📂 Leyendo datos de clientes desde HDFS...
   ✅ Datos cargados: 89 registros
   📊 Esquema de datos:
root
 |-- customer_id: string (nullable = true)
 |-- company_name: string (nullable = true)
 |-- productos_vendidos: long (nullable = true)

2. 📈 Calculando promedio de productos vendidos...
   ✅ Promedio de productos vendidos: 24.21

3. 🔍 Filtrando compañías con productos vendidos > promedio...
   ✅ Compañías filtradas: 33 de 89

4. 💾 Creando/Actualizando tabla en Hive...
   ✅ Usando base de datos: northwind_analytics
   ✅ Tabla 'products_sold' creada/actualizada en Hive

5. ✅ Verificando datos en Hive...
   📊 Total de registros en tabla Hive: 33

✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE
📊 Compañías procesadas: 33
💾 Tabla Hive: northwind_analytics.products_sold
🛑 Sesión de Spark cerrada
```

#### Paso 3: Verificar en Hive

```bash
beeline -u jdbc:hive2://localhost:10000 -e "
USE northwind_analytics;
SELECT COUNT(*) FROM products_sold;
SELECT * FROM products_sold ORDER BY productos_vendidos DESC LIMIT 10;
"
```

**Salida esperada**:

```
+-----------+----------------------------+------------------+
|customer_id|company_name                |productos_vendidos|
+-----------+----------------------------+------------------+
|SAVEA      |Save-a-lot Markets          |116               |
|ERNSH      |Ernst Handel                |102               |
|QUICK      |QUICK-Stop                  |86                |
|RATTC      |Rattlesnake Canyon Grocery  |71                |
|HUNGO      |Hungry Owl All-Night Grocers|55                |
...
```

### 📊 Capturas de Pantalla

> **Archivos**: 
> - `images/ejercicio5-spark-products-sold.png` - Ejecución del script
> - `images/ejercicio5-verify-products-sold.png` - Verificación en Hive

---

## Ejercicio 6: Script Spark para products_sent

### 📝 Enunciado

Generar un archivo .py que permita mediante Spark insertar en hive en la tabla `products_sent`, los datos del punto 3 y 4, de manera tal que se vean las columnas `order_id`, `shipped_date`, `company_name`, `phone`, `unit_price_discount` (unit_price with discount), `quantity`, `total_price` (unit_price_discount * quantity). Solo de aquellos pedidos que hayan tenido descuento.

### 💻 Solución

#### Paso 1: Crear el script Spark

```bash
cd /home/hadoop/scripts
nano spark_products_sent.py
```

**Contenido del script**: (Ver archivo `scripts/spark_products_sent.py`)

#### Paso 2: Dar permisos y ejecutar

```bash
chmod +x spark_products_sent.py
spark-submit spark_products_sent.py
```

**Salida esperada**:

```
=== INICIANDO PROCESAMIENTO SPARK PARA PRODUCTS_SENT ===

1. 📂 Leyendo datos desde HDFS...
   ✅ Envíos cargados: 809 registros
   ✅ Detalles de órdenes cargados: 2,155 registros

2. 🔄 Procesando y uniendo datos...
   ✅ Detalles con descuento: 838
   ✅ Registros después del JOIN: 803

3. 💾 Creando/Actualizando tabla en Hive...
   ✅ Tabla 'products_sent' creada/actualizada en Hive

4. ✅ Verificando datos en Hive...
   📊 Total de registros en tabla Hive: 803

   📈 Estadísticas de precios:
+-------------+---------------+-------------+-------------+
|total_pedidos|precio_promedio|precio_maximo|precio_minimo|
+-------------+---------------+-------------+-------------+
|803          |627.52         |15019.5      |8.5          |
+-------------+---------------+-------------+-------------+

✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE
📊 Pedidos con descuento procesados: 803
💾 Tabla Hive: northwind_analytics.products_sent
🛑 Sesión de Spark cerrada
```

#### Paso 3: Verificar en Hive

```bash
beeline -u jdbc:hive2://localhost:10000 -e "
USE northwind_analytics;
SELECT COUNT(*) FROM products_sent;
SELECT * FROM products_sent ORDER BY total_price DESC LIMIT 10;
"
```

### 📊 Capturas de Pantalla

> **Archivos**: 
> - `images/ejercicio6-spark-products-sent.png` - Ejecución del script
> - `images/ejercicio6-verify-products-sent.png` - Verificación en Hive

---

## Ejercicio 7: Orquestación con Airflow

### 📝 Enunciado

Realizar un proceso automático en Airflow que orqueste los pipelines creados en los puntos anteriores. Crear un grupo para la etapa de ingest y otro para la etapa de process. Correrlo y mostrar una captura de pantalla (del DAG y del resultado en la base de datos).

### 💻 Solución

#### Paso 1: Copiar el DAG a Airflow

```bash
# Copiar el archivo del DAG
cp /path/to/northwind_processing.py /home/hadoop/airflow/dags/

# Verificar que Airflow lo detecta
airflow dags list | grep northwind
```

#### Paso 2: Verificar que el DAG está disponible

```bash
airflow dags show northwind_processing
```

**Salida esperada** (estructura del DAG):
```
inicio
  ├── ingest
  │   ├── sqoop_import_clientes
  │   ├── sqoop_import_envios
  │   └── sqoop_import_order_details
  ├── process
  │   ├── spark_products_sold
  │   └── spark_products_sent
  ├── verify
  │   ├── verify_products_sold
  │   └── verify_products_sent
  └── fin_proceso
```

#### Paso 3: Ejecutar el DAG

**Opción A: Desde la UI de Airflow**

1. Acceder a http://localhost:8080
2. Buscar el DAG `northwind_processing`
3. Activar el toggle (switch) para habilitarlo
4. Click en el botón "Trigger DAG" (▶)
5. Monitorear la ejecución en la vista Graph

**Opción B: Desde la línea de comandos**

```bash
# Trigger del DAG
airflow dags trigger northwind_processing

# Ver logs en tiempo real
airflow dags list-runs -d northwind_processing
```

#### Paso 4: Verificar resultados en Hive

Una vez completado el DAG, verificar los datos:

```bash
beeline -u jdbc:hive2://localhost:10000
```

```sql
USE northwind_analytics;

-- Mostrar tablas
SHOW TABLES;

-- Contar registros
SELECT 'products_sold' as tabla, COUNT(*) as total FROM products_sold
UNION ALL
SELECT 'products_sent' as tabla, COUNT(*) as total FROM products_sent;

-- Top 5 clientes
SELECT customer_id, company_name, productos_vendidos 
FROM products_sold 
ORDER BY productos_vendidos DESC 
LIMIT 5;

-- Top 5 ventas
SELECT order_id, company_name, total_price 
FROM products_sent 
ORDER BY total_price DESC 
LIMIT 5;
```

**Salida esperada**:

```
+-------------+------+
|    tabla    |total |
+-------------+------+
|products_sold|  33  |
|products_sent| 803  |
+-------------+------+

+-----------+----------------------------+------------------+
|customer_id|company_name                |productos_vendidos|
+-----------+----------------------------+------------------+
|SAVEA      |Save-a-lot Markets          |116               |
|ERNSH      |Ernst Handel                |102               |
|QUICK      |QUICK-Stop                  |86                |
|RATTC      |Rattlesnake Canyon Grocery  |71                |
|HUNGO      |Hungry Owl All-Night Grocers|55                |
+-----------+----------------------------+------------------+
```

### 📊 Capturas de Pantalla

> **Archivos requeridos**: 
> 
> 1. **`images/ejercicio7-airflow-dag-graph.png`**
>    - Vista Graph del DAG en Airflow UI
>    - Debe mostrar todos los TaskGroups expandidos
>    - Todas las tareas en estado SUCCESS (verde)
> 
> 2. **`images/ejercicio7-airflow-dag-grid.png`**
>    - Vista Grid del DAG mostrando la ejecución temporal
>    - Debe mostrar el run completo exitoso
> 
> 3. **`images/ejercicio7-airflow-task-groups.png`**
>    - Vista detallada de los TaskGroups:
>      - ingest (3 tareas en paralelo)
>      - process (2 tareas en paralelo)
>      - verify (2 tareas en paralelo)
> 
> 4. **`images/ejercicio7-hive-resultados.png`**
>    - Consultas en Hive/Beeline mostrando:
>      - SHOW TABLES
>      - Conteo de registros en ambas tablas
>      - Top 5 de cada tabla

---

## 📊 Resumen de Resultados

### Datos Procesados

| Etapa | Dataset | Registros | Ubicación |
|-------|---------|-----------|-----------|
| **Ingest** | Clientes | 89 | `/sqoop/ingest/customers` |
| **Ingest** | Envíos | 809 | `/sqoop/ingest/envios` |
| **Ingest** | Order Details | 2,155 | `/sqoop/ingest/order_details` |
| **Process** | Products Sold | 33 | `northwind_analytics.products_sold` |
| **Process** | Products Sent | 803 | `northwind_analytics.products_sent` |

### Métricas del Análisis

**Products Sold**:
- Total clientes analizados: 89
- Promedio de productos vendidos: 24.21
- Clientes sobre el promedio: 33 (37%)
- Top cliente: Save-a-lot Markets (116 productos)

**Products Sent**:
- Total pedidos con descuento: 803
- Precio promedio: $627.52
- Venta máxima: $15,019.50
- Venta mínima: $8.50

### Tiempos de Ejecución

| Etapa | Tiempo Aproximado |
|-------|-------------------|
| Sqoop Import Clientes | ~25 segundos |
| Sqoop Import Envíos | ~24 segundos |
| Sqoop Import Order Details | ~24 segundos |
| Spark Products Sold | ~30 segundos |
| Spark Products Sent | ~35 segundos |
| **Total Pipeline** | **~2.5 minutos** |

---

## ✅ Checklist de Completitud

- [ ] Ejercicio 1: Base de datos creada en Hive
- [ ] Ejercicio 2: Script Sqoop clientes funcionando
- [ ] Ejercicio 3: Script Sqoop envíos funcionando
- [ ] Ejercicio 4: Script Sqoop order_details funcionando
- [ ] Ejercicio 5: Script Spark products_sold funcionando
- [ ] Ejercicio 6: Script Spark products_sent funcionando
- [ ] Ejercicio 7: DAG de Airflow ejecutándose correctamente
- [ ] Todas las capturas de pantalla tomadas
- [ ] Datos verificados en Hive
- [ ] Documentación completa

---

**Fecha de completitud**: 2025-11-12  
**Autor**: Hadoop Team  
**Versión**: 1.0

