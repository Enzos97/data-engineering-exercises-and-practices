-- Script: f1-setup.sql
-- Descripción: Scripts SQL para configurar la base de datos y tablas externas en Hive para datos de Formula 1
-- Autor: Ejercicio 9 - Práctica F1 con Airflow + Hive + Spark
-- Fuente de datos: https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020

-- =============================================
-- 1. CREACIÓN DE BASE DE DATOS
-- =============================================

-- Crear base de datos f1 si no existe
CREATE DATABASE IF NOT EXISTS f1;

-- Usar la base de datos f1
USE f1;

-- =============================================
-- 2. CREACIÓN DE TABLAS EXTERNAS
-- =============================================

-- Tabla externa driver_results
-- Esta tabla contiene información de resultados de corredores con sus nombres y puntos
CREATE EXTERNAL TABLE IF NOT EXISTS driver_results (
    driver_forename STRING,
    driver_surname STRING,
    driver_nationality STRING,
    points DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/f1.db/driver_results'
TBLPROPERTIES ('skip.header.line.count'='1');

-- Tabla externa constructor_results
-- Esta tabla contiene información de resultados de constructores con sus detalles y puntos
CREATE EXTERNAL TABLE IF NOT EXISTS constructor_results (
    constructorRef STRING,
    cons_name STRING,
    cons_nationality STRING,
    url STRING,
    points DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/f1.db/constructor_results'
TBLPROPERTIES ('skip.header.line.count'='1');

-- =============================================
-- 3. VERIFICACIONES
-- =============================================

-- Mostrar todas las tablas en la base de datos
SHOW TABLES;

-- Describir la estructura de driver_results
DESCRIBE driver_results;

-- Describir la estructura de constructor_results
DESCRIBE constructor_results;

-- Describir información detallada de driver_results
DESCRIBE FORMATTED driver_results;

-- Describir información detallada de constructor_results
DESCRIBE FORMATTED constructor_results;

