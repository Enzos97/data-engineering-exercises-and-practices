-- ============================================
-- CONFIGURACIÓN DE BASE DE DATOS HIVE
-- Titanic Database
-- ============================================
-- Descripción: Scripts para crear la base de datos y tabla
--              para almacenar datos procesados del Titanic
-- Autor: Edvai
-- Fecha: 2025-11-20
-- ============================================

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS titanic_db
COMMENT 'Base de datos para análisis de datos del Titanic';

-- Usar la base de datos
USE titanic_db;

-- ============================================
-- TABLA: titanic_processed
-- ============================================
-- Descripción: Almacena datos procesados del Titanic
-- Actualización: Overwrite en cada ejecución del DAG de Airflow

CREATE TABLE IF NOT EXISTS titanic_processed (
    PassengerId INT,
    Survived INT,
    Pclass INT,
    Name STRING,
    Sex STRING,
    Age FLOAT,
    Ticket STRING,
    Fare FLOAT,
    Cabin STRING,
    Embarked STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Verificar estructura de la tabla
DESC FORMATTED titanic_processed;

-- ============================================
-- CONSULTAS DE NEGOCIO
-- ============================================

-- 8a) Cuántos hombres y cuántas mujeres sobrevivieron
SELECT 
    Sex,
    COUNT(*) as Cantidad
FROM titanic_processed
WHERE Survived = 1
GROUP BY Sex;

-- 8b) Cuántas personas sobrevivieron según cada clase (Pclass)
SELECT 
    Pclass,
    COUNT(*) as Cantidad
FROM titanic_processed
WHERE Survived = 1
GROUP BY Pclass
ORDER BY Pclass;

-- 8c) Cuál fue la persona de mayor edad que sobrevivió
SELECT 
    Name,
    Age
FROM titanic_processed
WHERE Survived = 1 AND Age > 0
ORDER BY Age DESC
LIMIT 1;

-- 8d) Cuál fue la persona más joven que sobrevivió
SELECT 
    Name,
    Age
FROM titanic_processed
WHERE Survived = 1 AND Age > 0
ORDER BY Age ASC
LIMIT 1;

-- ============================================
-- CONSULTAS ADICIONALES DE ANÁLISIS
-- ============================================

-- Total de pasajeros
SELECT COUNT(*) as total_pasajeros FROM titanic_processed;

-- Tasa de supervivencia general
SELECT 
    Survived,
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM titanic_processed), 2) as porcentaje
FROM titanic_processed
GROUP BY Survived;

-- Tasa de supervivencia por género
SELECT 
    Sex,
    SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) as sobrevivieron,
    SUM(CASE WHEN Survived = 0 THEN 1 ELSE 0 END) as fallecieron,
    ROUND(SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as tasa_supervivencia
FROM titanic_processed
GROUP BY Sex;

-- Tasa de supervivencia por clase
SELECT 
    Pclass,
    SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) as sobrevivieron,
    SUM(CASE WHEN Survived = 0 THEN 1 ELSE 0 END) as fallecieron,
    ROUND(SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as tasa_supervivencia
FROM titanic_processed
GROUP BY Pclass
ORDER BY Pclass;

-- Edad promedio por género y supervivencia
SELECT 
    Sex,
    Survived,
    ROUND(AVG(Age), 2) as edad_promedio,
    ROUND(MIN(Age), 2) as edad_minima,
    ROUND(MAX(Age), 2) as edad_maxima
FROM titanic_processed
WHERE Age > 0
GROUP BY Sex, Survived
ORDER BY Sex, Survived;

-- ============================================
-- NOTAS
-- ============================================
-- 1. La tabla se carga automáticamente mediante el DAG de Airflow
-- 2. Los datos se actualizan con modo OVERWRITE en cada ejecución
-- 3. Los valores de Cabin nulos se convierten a 0
-- 4. Los valores de Age nulos se rellenan con el promedio por género
-- ============================================

