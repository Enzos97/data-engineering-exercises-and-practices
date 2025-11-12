# Scripts - Northwind ETL Pipeline

Este directorio contiene todos los scripts de automatización para el pipeline ETL de Northwind Analytics.

## 📁 Contenido

### Scripts de Ingestión (Sqoop)

| Script | Descripción | Destino HDFS |
|--------|-------------|--------------|
| `sqoop_import_clientes.sh` | Importa clientes con productos vendidos | `/sqoop/ingest/customers` |
| `sqoop_import_envios.sh` | Importa órdenes con información de envío | `/sqoop/ingest/envios` |
| `sqoop_import_order_details.sh` | Importa detalles de órdenes | `/sqoop/ingest/order_details` |

### Scripts de Procesamiento (Spark)

| Script | Descripción | Tabla Hive |
|--------|-------------|------------|
| `spark_products_sold.py` | Procesa clientes con ventas > promedio | `products_sold` |
| `spark_products_sent.py` | Procesa pedidos con descuento | `products_sent` |

## 🔧 Configuración Previa

### 1. Crear archivo de password

```bash
# Crear archivo seguro con la password
echo "edvai" > /home/hadoop/password.txt
chmod 600 /home/hadoop/password.txt

# Verificar permisos
ls -la /home/hadoop/password.txt
# Debe mostrar: -rw------- 1 hadoop hadoop
```

### 2. Dar permisos de ejecución

```bash
chmod +x /home/hadoop/scripts/*.sh
chmod +x /home/hadoop/scripts/*.py
```

### 3. Verificar conectividad a PostgreSQL

```bash
# Probar conexión
psql -h 172.17.0.1 -p 5432 -U postgres -d northwind -c "SELECT COUNT(*) FROM customers;"
```

## 📄 Descripción Detallada de Scripts

### sqoop_import_clientes.sh

**Propósito**: Importar datos de clientes con la cantidad total de productos vendidos.

**Query SQL**:
```sql
SELECT 
    c.customer_id, 
    c.company_name, 
    COUNT(od.product_id) as productos_vendidos 
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id 
JOIN order_details od ON o.order_id = od.order_id 
GROUP BY c.customer_id, c.company_name
```

**Características**:
- Formato: Parquet
- Compresión: Snappy
- Split-by: customer_id
- Mappers: 1

**Ejecución**:
```bash
bash /home/hadoop/scripts/sqoop_import_clientes.sh
```

**Verificación**:
```bash
hdfs dfs -ls -h /sqoop/ingest/customers
```

---

### sqoop_import_envios.sh

**Propósito**: Importar información de órdenes enviadas con datos de la empresa.

**Query SQL**:
```sql
SELECT 
    o.order_id, 
    o.shipped_date, 
    c.company_name, 
    c.phone 
FROM orders o 
JOIN customers c ON o.customer_id = c.customer_id 
WHERE o.shipped_date IS NOT NULL
```

**Características**:
- Formato: Parquet
- Compresión: Snappy
- Split-by: order_id
- Mappers: 1
- Filtro: Solo órdenes con shipped_date no nulo

**Ejecución**:
```bash
bash /home/hadoop/scripts/sqoop_import_envios.sh
```

**Verificación**:
```bash
hdfs dfs -ls -h /sqoop/ingest/envios
```

---

### sqoop_import_order_details.sh

**Propósito**: Importar detalles de todas las órdenes.

**Query SQL**:
```sql
SELECT 
    order_id, 
    unit_price, 
    quantity, 
    discount 
FROM order_details
```

**Características**:
- Formato: Parquet
- Compresión: Snappy
- Split-by: order_id
- Mappers: 1

**Ejecución**:
```bash
bash /home/hadoop/scripts/sqoop_import_order_details.sh
```

**Verificación**:
```bash
hdfs dfs -ls -h /sqoop/ingest/order_details
```

---

### spark_products_sold.py

**Propósito**: Procesar datos de clientes y filtrar aquellos con productos vendidos mayor al promedio.

**Input**: 
- HDFS: `/sqoop/ingest/customers`

**Procesamiento**:
1. Lee datos desde HDFS en formato Parquet
2. Calcula el promedio de productos vendidos
3. Filtra clientes con productos_vendidos > promedio
4. Ordena por productos_vendidos descendente

**Output**:
- Tabla Hive: `northwind_analytics.products_sold`
- Modo: Overwrite

**Tecnologías**:
- PySpark
- Hive Support
- Adaptive Query Execution

**Ejecución**:
```bash
spark-submit /home/hadoop/scripts/spark_products_sold.py
```

**Verificación**:
```bash
beeline -u jdbc:hive2://localhost:10000 -e "
USE northwind_analytics;
SELECT COUNT(*) FROM products_sold;
SELECT * FROM products_sold ORDER BY productos_vendidos DESC LIMIT 10;
"
```

---

### spark_products_sent.py

**Propósito**: Procesar órdenes que tuvieron descuento, calculando precios finales.

**Input**:
- HDFS: `/sqoop/ingest/envios`
- HDFS: `/sqoop/ingest/order_details`

**Procesamiento**:
1. Lee datos desde HDFS en formato Parquet
2. Filtra detalles con discount > 0
3. Calcula:
   - `unit_price_discount = unit_price * (1 - discount)`
   - `total_price = unit_price_discount * quantity`
4. Realiza JOIN entre envíos y detalles por order_id
5. Ordena por order_id

**Output**:
- Tabla Hive: `northwind_analytics.products_sent`
- Modo: Overwrite

**Tecnologías**:
- PySpark
- Hive Support
- Adaptive Query Execution

**Ejecución**:
```bash
spark-submit /home/hadoop/scripts/spark_products_sent.py
```

**Verificación**:
```bash
beeline -u jdbc:hive2://localhost:10000 -e "
USE northwind_analytics;
SELECT COUNT(*) FROM products_sent;
SELECT * FROM products_sent ORDER BY total_price DESC LIMIT 10;
"
```

## 🚀 Ejecución Completa del Pipeline

### Ejecución Manual Secuencial

```bash
# 1. Etapa de Ingest (pueden ejecutarse en paralelo)
bash /home/hadoop/scripts/sqoop_import_clientes.sh &
bash /home/hadoop/scripts/sqoop_import_envios.sh &
bash /home/hadoop/scripts/sqoop_import_order_details.sh &
wait

# 2. Etapa de Process (pueden ejecutarse en paralelo)
spark-submit /home/hadoop/scripts/spark_products_sold.py &
spark-submit /home/hadoop/scripts/spark_products_sent.py &
wait

# 3. Verificación
beeline -u jdbc:hive2://localhost:10000 -e "
USE northwind_analytics;
SHOW TABLES;
SELECT COUNT(*) FROM products_sold;
SELECT COUNT(*) FROM products_sent;
"
```

### Ejecución Automática con Airflow

```bash
# Trigger del DAG
airflow dags trigger northwind_processing

# Monitorear en UI
# http://localhost:8080
```

## 📊 Resultados Esperados

### Datos de Ingestión

| Dataset | Registros Aprox. | Tamaño HDFS |
|---------|------------------|-------------|
| Clientes | 89 | ~5 KB |
| Envíos | 809 | ~14 KB |
| Order Details | 2,155 | ~14 KB |

### Datos Procesados

| Tabla Hive | Registros Aprox. | Descripción |
|------------|------------------|-------------|
| products_sold | 33 | Clientes con ventas > promedio (24.21) |
| products_sent | 803 | Pedidos con descuento |

## 🐛 Troubleshooting

### Error: "Connection refused" en Sqoop

**Causa**: PostgreSQL no accesible desde el contenedor.

**Solución**:
```bash
# Verificar que PostgreSQL está corriendo
docker ps | grep postgres

# Verificar conectividad
telnet 172.17.0.1 5432

# Verificar IP correcta
docker network inspect bridge | grep Gateway
```

### Error: "Permission denied" en password.txt

**Causa**: Archivo de password mal configurado.

**Solución**:
```bash
# Recrear archivo con permisos correctos
echo "edvai" > /home/hadoop/password.txt
chmod 600 /home/hadoop/password.txt
chown hadoop:hadoop /home/hadoop/password.txt
```

### Error: "HDFS directory already exists"

**Causa**: Directorios de ingesta previos no limpiados.

**Solución**:
```bash
# Limpiar directorios
hdfs dfs -rm -r /sqoop/ingest/*

# O ejecutar los scripts que incluyen limpieza automática
```

### Error: "Spark job failed"

**Causa**: Datos de entrada no disponibles o corruptos.

**Solución**:
```bash
# Verificar que los datos existen
hdfs dfs -ls /sqoop/ingest/customers
hdfs dfs -ls /sqoop/ingest/envios
hdfs dfs -ls /sqoop/ingest/order_details

# Verificar contenido de archivos Parquet
spark-shell
val df = spark.read.parquet("hdfs://172.17.0.2:9000/sqoop/ingest/customers")
df.show()
df.printSchema()
```

## 📝 Modificaciones Comunes

### Cambiar IP de PostgreSQL

Editar en cada script de Sqoop:

```bash
DB_HOST="172.17.0.1"  # Cambiar a la IP correcta
```

### Cambiar formato de salida Sqoop

```bash
# En lugar de Parquet, usar Avro:
--as-avrodatafile

# O texto delimitado:
--as-textfile
--fields-terminated-by ','
```

### Agregar más filtros en Sqoop

```sql
-- Ejemplo: Solo clientes de USA
--query "SELECT ... WHERE country = 'USA' AND \$CONDITIONS"
```

### Optimizar Spark

```python
# En los scripts .py, ajustar configuración:
spark = (
    SparkSession.builder
    .appName("NorthwindProductsSold")
    .config("spark.sql.shuffle.partitions", "10")  # Ajustar particiones
    .config("spark.executor.memory", "2g")         # Ajustar memoria
    .enableHiveSupport()
    .getOrCreate()
)
```

## 📚 Referencias

- [Sqoop User Guide](https://sqoop.apache.org/docs/1.4.7/SqoopUserGuide.html)
- [PySpark SQL Documentation](https://spark.apache.org/docs/latest/api/python/reference/pyspark.sql.html)
- [Hive Language Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual)

---

**Última actualización**: 2025-11-12

