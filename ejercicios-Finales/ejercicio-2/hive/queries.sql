-- =====================================================
-- Script: queries.sql
-- Descripción: Consultas de negocio para Car Rental Analytics
-- Autor: Data Engineering Team
-- Fecha: 2025-11-22
-- PUNTO 5: Consultas SQL al Data Warehouse
-- =====================================================

-- Configuración: Mostrar encabezados de columnas
SET hive.cli.print.header=true;

USE car_rental_db;

-- =====================================================
-- 5a. Cantidad de alquileres de autos ecológicos con rating >= 4
-- =====================================================
-- Vehículos ecológicos: híbrido o eléctrico
-- Rating: al menos 4

SELECT 
    COUNT(*) as total_alquileres_ecologicos
FROM car_rental_analytics
WHERE (fuelType = 'hybrid' OR fuelType = 'electric')
  AND rating >= 4;

-- Detalle por tipo de combustible
SELECT 
    fuelType,
    COUNT(*) as total_alquileres,
    AVG(rating) as rating_promedio,
    SUM(renterTripsTaken) as total_viajes
FROM car_rental_analytics
WHERE (fuelType = 'hybrid' OR fuelType = 'electric')
  AND rating >= 4
GROUP BY fuelType
ORDER BY total_alquileres DESC;


-- =====================================================
-- 5b. Los 5 estados con menor cantidad de alquileres
-- =====================================================

SELECT 
    state_name,
    COUNT(*) as total_alquileres,
    ROUND(AVG(rating), 2) as rating_promedio,
    ROUND(AVG(rate_daily), 2) as tarifa_diaria_promedio
FROM car_rental_analytics
WHERE state_name IS NOT NULL
GROUP BY state_name
ORDER BY total_alquileres ASC
LIMIT 5;


-- =====================================================
-- 5c. Los 10 modelos (con marca) de autos más rentados
-- =====================================================

SELECT 
    make as marca,
    model as modelo,
    COUNT(*) as total_alquileres,
    ROUND(AVG(rating), 2) as rating_promedio,
    ROUND(AVG(rate_daily), 2) as tarifa_diaria_promedio,
    SUM(renterTripsTaken) as total_viajes
FROM car_rental_analytics
WHERE make IS NOT NULL 
  AND model IS NOT NULL
GROUP BY make, model
ORDER BY total_alquileres DESC
LIMIT 10;


-- =====================================================
-- 5d. Alquileres por año (automóviles fabricados 2010-2015)
-- =====================================================
-- Columnas:
--   anio_fabricacion: Año de fabricación del vehículo (2010-2015)
--   total_alquileres: Cantidad total de alquileres para ese año
--   rating_promedio: Calificación promedio de los vehículos
--   tarifa_diaria_promedio: Precio promedio de alquiler por día (USD)
--   cantidad_marcas: Número de marcas distintas disponibles
--   total_viajes: Suma total de viajes realizados por los arrendatarios

SELECT 
    year as anio_fabricacion,
    COUNT(*) as total_alquileres,
    ROUND(AVG(rating), 2) as rating_promedio,
    ROUND(AVG(rate_daily), 2) as tarifa_diaria_promedio,
    COUNT(DISTINCT make) as cantidad_marcas,
    SUM(renterTripsTaken) as total_viajes
FROM car_rental_analytics
WHERE year BETWEEN 2010 AND 2015
GROUP BY year
ORDER BY year;

-- Resumen general 2010-2015
SELECT 
    MIN(year) as anio_minimo,
    MAX(year) as anio_maximo,
    COUNT(*) as total_alquileres,
    ROUND(AVG(rating), 2) as rating_promedio,
    COUNT(DISTINCT make) as total_marcas,
    COUNT(DISTINCT model) as total_modelos
FROM car_rental_analytics
WHERE year BETWEEN 2010 AND 2015;


-- =====================================================
-- 5e. Las 5 ciudades con más alquileres de vehículos ecológicos
-- =====================================================

SELECT 
    city as ciudad,
    state_name as estado,
    COUNT(*) as total_alquileres_ecologicos,
    ROUND(AVG(rating), 2) as rating_promedio,
    COUNT(CASE WHEN fuelType = 'hybrid' THEN 1 END) as hibridos,
    COUNT(CASE WHEN fuelType = 'electric' THEN 1 END) as electricos,
    ROUND(AVG(rate_daily), 2) as tarifa_diaria_promedio
FROM car_rental_analytics
WHERE (fuelType = 'hybrid' OR fuelType = 'electric')
  AND city IS NOT NULL
GROUP BY city, state_name
ORDER BY total_alquileres_ecologicos DESC
LIMIT 5;


-- =====================================================
-- 5f. Promedio de reviews segmentado por tipo de combustible
-- =====================================================

SELECT 
    fuelType as tipo_combustible,
    COUNT(*) as total_vehiculos,
    ROUND(AVG(reviewCount), 2) as promedio_reviews,
    MIN(reviewCount) as minimo_reviews,
    MAX(reviewCount) as maximo_reviews,
    ROUND(AVG(rating), 2) as rating_promedio,
    SUM(reviewCount) as total_reviews
FROM car_rental_analytics
WHERE fuelType IS NOT NULL
GROUP BY fuelType
ORDER BY promedio_reviews DESC;


-- =====================================================
-- CONSULTAS ADICIONALES DE ANÁLISIS
-- =====================================================

-- Distribución de ratings
SELECT 
    rating,
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM car_rental_analytics), 2) as porcentaje
FROM car_rental_analytics
GROUP BY rating
ORDER BY rating DESC;

-- Top 10 propietarios con más vehículos
SELECT 
    owner_id as propietario,
    COUNT(*) as total_vehiculos,
    ROUND(AVG(rating), 2) as rating_promedio,
    ROUND(AVG(rate_daily), 2) as tarifa_promedio,
    SUM(renterTripsTaken) as total_viajes
FROM car_rental_analytics
GROUP BY owner_id
ORDER BY total_vehiculos DESC
LIMIT 10;

-- Análisis de tarifas por tipo de combustible
SELECT 
    fuelType as tipo_combustible,
    COUNT(*) as total_vehiculos,
    ROUND(AVG(rate_daily), 2) as tarifa_promedio,
    MIN(rate_daily) as tarifa_minima,
    MAX(rate_daily) as tarifa_maxima,
    ROUND(AVG(rating), 2) as rating_promedio
FROM car_rental_analytics
WHERE fuelType IS NOT NULL
GROUP BY fuelType
ORDER BY tarifa_promedio DESC;

-- Estados con mejores ratings
SELECT 
    state_name as estado,
    COUNT(*) as total_vehiculos,
    ROUND(AVG(rating), 2) as rating_promedio,
    ROUND(AVG(rate_daily), 2) as tarifa_promedio
FROM car_rental_analytics
WHERE state_name IS NOT NULL
GROUP BY state_name
HAVING COUNT(*) > 10  -- Solo estados con más de 10 vehículos
ORDER BY rating_promedio DESC
LIMIT 10;

