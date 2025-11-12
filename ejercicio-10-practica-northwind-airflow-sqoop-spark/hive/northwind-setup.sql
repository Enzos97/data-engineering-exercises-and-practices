-- ============================================
-- CONFIGURACIÓN DE BASE DE DATOS HIVE
-- Northwind Analytics
-- ============================================
-- Descripción: Scripts para crear la base de datos y tablas
--              necesarias para el análisis de datos de Northwind
-- Autor: Hadoop
-- Fecha: 2025-11-12
-- ============================================

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS northwind_analytics
COMMENT 'Base de datos para análisis de Northwind'
LOCATION '/user/hive/warehouse/northwind_analytics.db';

-- Usar la base de datos
USE northwind_analytics;

-- ============================================
-- MOSTRAR BASES DE DATOS
-- ============================================
SHOW DATABASES;

-- ============================================
-- TABLA: products_sold
-- ============================================
-- Descripción: Almacena información de clientes con productos vendidos
--              mayores al promedio
-- Creada automáticamente por: spark_products_sold.py
-- Actualización: Overwrite en cada ejecución del pipeline

-- Verificar estructura de la tabla
DESC FORMATTED products_sold;

-- Consulta de muestra
SELECT 
    customer_id,
    company_name,
    productos_vendidos
FROM products_sold
ORDER BY productos_vendidos DESC
LIMIT 10;

-- Estadísticas
SELECT 
    COUNT(*) as total_clientes,
    AVG(productos_vendidos) as promedio_productos,
    MAX(productos_vendidos) as maximo_productos,
    MIN(productos_vendidos) as minimo_productos
FROM products_sold;

-- ============================================
-- TABLA: products_sent
-- ============================================
-- Descripción: Almacena información de pedidos enviados con descuento
-- Creada automáticamente por: spark_products_sent.py
-- Actualización: Overwrite en cada ejecución del pipeline

-- Verificar estructura de la tabla
DESC FORMATTED products_sent;

-- Consulta de muestra
SELECT 
    order_id,
    shipped_date,
    company_name,
    phone,
    unit_price_discount,
    quantity,
    total_price
FROM products_sent
ORDER BY total_price DESC
LIMIT 10;

-- Estadísticas de pedidos
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

-- ============================================
-- NOTAS
-- ============================================
-- 1. Las tablas son manejadas automáticamente por Spark
-- 2. Los datos se almacenan en formato Parquet
-- 3. El modo 'overwrite' actualiza los datos en cada ejecución
-- 4. La ubicación de las tablas es el warehouse de Hive por defecto
-- ============================================

