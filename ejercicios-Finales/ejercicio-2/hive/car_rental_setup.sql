-- =====================================================
-- Script: car_rental_setup.sql
-- Descripción: Crea la base de datos y tabla para Car Rental
-- Autor: Data Engineering Team
-- Fecha: 2025-11-22
-- =====================================================

-- PUNTO 1: Crear base de datos
CREATE DATABASE IF NOT EXISTS car_rental_db;

-- Usar la base de datos
USE car_rental_db;

-- PUNTO 1: Crear tabla car_rental_analytics
CREATE TABLE IF NOT EXISTS car_rental_analytics (
    fuelType STRING,
    rating INT,
    renterTripsTaken INT,
    reviewCount INT,
    city STRING,
    state_name STRING,
    owner_id INT,
    rate_daily INT,
    make STRING,
    model STRING,
    year INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="0");

-- Mostrar tablas para verificar
SHOW TABLES;

-- Describir la tabla para verificar el esquema
DESCRIBE FORMATTED car_rental_analytics;

-- Verificar que la tabla esté vacía inicialmente
SELECT COUNT(*) as total_registros FROM car_rental_analytics;

