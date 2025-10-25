-- Script: hive-setup.sql
-- Descripción: Scripts SQL para configurar la base de datos y tabla en Hive
-- Autor: Ejercicio 8 - Práctica Airflow + Hive + Spark

-- =============================================
-- 1. CREACIÓN DE BASE DE DATOS
-- =============================================

-- Crear base de datos tripdata si no existe
CREATE DATABASE IF NOT EXISTS tripdata;

-- Usar la base de datos tripdata
USE tripdata;

-- =============================================
-- 2. CREACIÓN DE TABLA EXTERNA
-- =============================================

-- Crear tabla externa airport_trips
CREATE EXTERNAL TABLE IF NOT EXISTS airport_trips (
    tpep_pickup_datetime STRING,
    airport_fee DOUBLE,
    payment_type INT,
    tolls_amount DOUBLE,
    total_amount DOUBLE
)
STORED AS PARQUET
LOCATION '/user/hive/warehouse/tripdata.db/airport_trips';

-- =============================================
-- 3. VERIFICACIONES
-- =============================================

-- Mostrar todas las tablas en la base de datos
SHOW TABLES;

-- Describir la estructura de la tabla
DESCRIBE airport_trips;

-- Describir información detallada de la tabla
DESCRIBE FORMATTED airport_trips;

-- =============================================
-- 4. CONSULTAS DE VERIFICACIÓN
-- =============================================

-- Contar registros en la tabla
SELECT COUNT(*) AS total_registros FROM airport_trips;

-- Mostrar una muestra de los datos
SELECT * FROM airport_trips LIMIT 10;

-- Estadísticas básicas
SELECT 
    COUNT(*) as total_viajes,
    AVG(airport_fee) as promedio_airport_fee,
    AVG(total_amount) as promedio_total_amount,
    MIN(tpep_pickup_datetime) as fecha_mas_antigua,
    MAX(tpep_pickup_datetime) as fecha_mas_reciente
FROM airport_trips;

-- =============================================
-- 5. CONSULTAS DE ANÁLISIS
-- =============================================

-- Viajes por tipo de pago
SELECT 
    payment_type,
    COUNT(*) as cantidad_viajes,
    AVG(total_amount) as promedio_monto
FROM airport_trips
GROUP BY payment_type;

-- Viajes por rango de airport_fee
SELECT 
    CASE 
        WHEN airport_fee = 0 THEN 'Sin cargo de aeropuerto'
        WHEN airport_fee > 0 AND airport_fee <= 1.25 THEN 'Cargo estándar'
        WHEN airport_fee > 1.25 THEN 'Cargo alto'
    END as rango_airport_fee,
    COUNT(*) as cantidad_viajes
FROM airport_trips
GROUP BY 
    CASE 
        WHEN airport_fee = 0 THEN 'Sin cargo de aeropuerto'
        WHEN airport_fee > 0 AND airport_fee <= 1.25 THEN 'Cargo estándar'
        WHEN airport_fee > 1.25 THEN 'Cargo alto'
    END;

-- Top 5 viajes con mayor monto total
SELECT 
    tpep_pickup_datetime,
    airport_fee,
    payment_type,
    tolls_amount,
    total_amount
FROM airport_trips
ORDER BY total_amount DESC
LIMIT 5;
