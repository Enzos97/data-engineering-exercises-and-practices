# Hive - Northwind Analytics

Este directorio contiene los scripts SQL para configurar y consultar la base de datos Hive para el proyecto Northwind Analytics.

## 📄 Archivos

### `northwind-setup.sql`

Script principal que contiene:
- Creación de la base de datos `northwind_analytics`
- Comandos para describir las tablas
- Consultas de ejemplo y análisis
- Estadísticas de datos

## 🗄️ Base de Datos

### northwind_analytics

```sql
CREATE DATABASE IF NOT EXISTS northwind_analytics
COMMENT 'Base de datos para análisis de Northwind'
LOCATION '/user/hive/warehouse/northwind_analytics.db';
```

**Ubicación HDFS**: `/user/hive/warehouse/northwind_analytics.db`

## 📊 Tablas

### 1. products_sold

**Descripción**: Almacena información de clientes con productos vendidos mayores al promedio.

**Esquema**:
```
customer_id         STRING    # ID del cliente
company_name        STRING    # Nombre de la compañía
productos_vendidos  BIGINT    # Cantidad de productos vendidos
```

**Creada por**: `spark_products_sold.py`

**Modo de actualización**: Overwrite (reemplaza datos en cada ejecución)

**Ubicación**: `/user/hive/warehouse/northwind_analytics.db/products_sold`

**Formato**: Parquet (gestionado por Spark)

**Consultas de ejemplo**:

```sql
-- Ver top 10 clientes por productos vendidos
SELECT 
    customer_id,
    company_name,
    productos_vendidos
FROM products_sold
ORDER BY productos_vendidos DESC
LIMIT 10;

-- Estadísticas generales
SELECT 
    COUNT(*) as total_clientes,
    AVG(productos_vendidos) as promedio_productos,
    MAX(productos_vendidos) as maximo_productos,
    MIN(productos_vendidos) as minimo_productos
FROM products_sold;
```

### 2. products_sent

**Descripción**: Almacena información de pedidos enviados que tuvieron descuento.

**Esquema**:
```
order_id              INT       # ID de la orden
shipped_date          BIGINT    # Fecha de envío (timestamp)
company_name          STRING    # Nombre de la compañía
phone                 STRING    # Teléfono de contacto
unit_price_discount   DOUBLE    # Precio unitario con descuento aplicado
quantity              INT       # Cantidad de productos
total_price           DOUBLE    # Precio total (unit_price_discount * quantity)
```

**Creada por**: `spark_products_sent.py`

**Modo de actualización**: Overwrite (reemplaza datos en cada ejecución)

**Ubicación**: `/user/hive/warehouse/northwind_analytics.db/products_sent`

**Formato**: Parquet (gestionado por Spark)

**Consultas de ejemplo**:

```sql
-- Ver top 10 pedidos por precio total
SELECT 
    order_id,
    company_name,
    unit_price_discount,
    quantity,
    total_price
FROM products_sent
ORDER BY total_price DESC
LIMIT 10;

-- Estadísticas de ventas
SELECT 
    COUNT(*) as total_pedidos,
    COUNT(DISTINCT company_name) as total_empresas,
    ROUND(AVG(total_price), 2) as precio_promedio,
    ROUND(MAX(total_price), 2) as precio_maximo,
    ROUND(MIN(total_price), 2) as precio_minimo,
    ROUND(SUM(total_price), 2) as total_ventas
FROM products_sent;

-- Top 10 empresas por total de ventas
SELECT 
    company_name,
    COUNT(*) as num_pedidos,
    ROUND(SUM(total_price), 2) as total_ventas
FROM products_sent
GROUP BY company_name
ORDER BY total_ventas DESC
LIMIT 10;
```

## 🚀 Uso

### Crear la base de datos

```bash
# Opción 1: Ejecutar el script completo
hive -f /path/to/northwind-setup.sql

# Opción 2: Conectarse a Hive y ejecutar comandos
hive
```

```sql
-- Dentro de Hive
source /path/to/northwind-setup.sql;
```

### Conectarse a Hive

#### Usando Hive CLI:

```bash
hive
```

```sql
USE northwind_analytics;
SHOW TABLES;
```

#### Usando Beeline:

```bash
beeline -u jdbc:hive2://localhost:10000
```

```sql
USE northwind_analytics;
SHOW TABLES;
```

### Verificar estructura de las tablas

```sql
-- Descripción detallada
DESC FORMATTED products_sold;
DESC FORMATTED products_sent;

-- Descripción simple
DESCRIBE products_sold;
DESCRIBE products_sent;
```

### Contar registros

```sql
SELECT COUNT(*) as total FROM products_sold;
SELECT COUNT(*) as total FROM products_sent;
```

### Consultar datos

```sql
-- Primeros 10 registros
SELECT * FROM products_sold LIMIT 10;
SELECT * FROM products_sent LIMIT 10;
```

## 📈 Análisis de Datos

### Análisis de Clientes (products_sold)

```sql
-- Distribución de productos vendidos
SELECT 
    CASE 
        WHEN productos_vendidos < 30 THEN '1. Bajo (< 30)'
        WHEN productos_vendidos < 50 THEN '2. Medio (30-50)'
        WHEN productos_vendidos < 80 THEN '3. Alto (50-80)'
        ELSE '4. Muy Alto (>= 80)'
    END as categoria,
    COUNT(*) as cantidad_clientes,
    ROUND(AVG(productos_vendidos), 2) as promedio_productos
FROM products_sold
GROUP BY 
    CASE 
        WHEN productos_vendidos < 30 THEN '1. Bajo (< 30)'
        WHEN productos_vendidos < 50 THEN '2. Medio (30-50)'
        WHEN productos_vendidos < 80 THEN '3. Alto (50-80)'
        ELSE '4. Muy Alto (>= 80)'
    END
ORDER BY categoria;
```

### Análisis de Ventas (products_sent)

```sql
-- Ventas por empresa
SELECT 
    company_name,
    COUNT(*) as total_pedidos,
    ROUND(SUM(total_price), 2) as ventas_totales,
    ROUND(AVG(total_price), 2) as ticket_promedio
FROM products_sent
GROUP BY company_name
ORDER BY ventas_totales DESC
LIMIT 20;

-- Análisis de descuentos aplicados
SELECT 
    COUNT(*) as pedidos_con_descuento,
    ROUND(AVG(unit_price_discount), 2) as precio_promedio_con_descuento,
    ROUND(AVG(quantity), 2) as cantidad_promedio,
    ROUND(AVG(total_price), 2) as venta_promedio
FROM products_sent;
```

## 🔧 Mantenimiento

### Actualizar estadísticas de las tablas

```sql
-- Analizar tabla para optimizar consultas
ANALYZE TABLE products_sold COMPUTE STATISTICS;
ANALYZE TABLE products_sent COMPUTE STATISTICS;

-- Analizar columnas específicas
ANALYZE TABLE products_sold COMPUTE STATISTICS FOR COLUMNS;
ANALYZE TABLE products_sent COMPUTE STATISTICS FOR COLUMNS;
```

### Verificar espacio usado

```bash
# Ver tamaño en HDFS
hdfs dfs -du -h /user/hive/warehouse/northwind_analytics.db/
```

### Limpiar datos antiguos

```sql
-- Eliminar datos de las tablas (mantener estructura)
TRUNCATE TABLE products_sold;
TRUNCATE TABLE products_sent;

-- Eliminar tablas completamente
DROP TABLE IF EXISTS products_sold;
DROP TABLE IF EXISTS products_sent;

-- Eliminar base de datos completa
DROP DATABASE IF EXISTS northwind_analytics CASCADE;
```

## 🐛 Troubleshooting

### Problema: "Database does not exist"

```sql
-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS northwind_analytics;
USE northwind_analytics;
```

### Problema: "Table not found"

**Causa**: Las tablas son creadas por los scripts de Spark. Primero ejecuta el pipeline completo.

```bash
# Ejecutar scripts de Spark
spark-submit /home/hadoop/scripts/spark_products_sold.py
spark-submit /home/hadoop/scripts/spark_products_sent.py
```

### Problema: Permisos insuficientes

```bash
# Verificar permisos en HDFS
hdfs dfs -ls /user/hive/warehouse/

# Dar permisos si es necesario
hdfs dfs -chmod -R 755 /user/hive/warehouse/northwind_analytics.db/
```

## 📚 Referencias

- [Apache Hive Language Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual)
- [Hive DDL](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL)
- [Hive DML](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML)

---

**Última actualización**: 2025-11-12

