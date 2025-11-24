-- =====================================================
-- Script: queries_aviacion.sql
-- Descripción: Consultas para el Ejercicio Final 1 - Aviación
-- Autor: Data Engineering Team
-- Fecha: 2025-11-22
-- =====================================================

-- Configuración para mostrar encabezados
SET hive.cli.print.header=true;

-- =====================================================
-- CREAR BASE DE DATOS Y TABLAS
-- =====================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS aviacion;

USE aviacion;

-- =====================================================
-- TABLA 1: VUELOS (aeropuerto_tabla)
-- =====================================================
-- Schema según PDF Página 2

CREATE TABLE IF NOT EXISTS aeropuerto_tabla (
    fecha DATE,
    horaUTC STRING,
    clase_de_vuelo STRING,
    clasificacion_de_vuelo STRING,
    tipo_de_movimiento STRING,
    aeropuerto STRING,
    origen_destino STRING,
    aerolinea_nombre STRING,
    aeronave STRING,
    pasajeros INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");

-- =====================================================
-- TABLA 2: DETALLES AEROPUERTOS (aeropuerto_detalles_tabla)
-- =====================================================
-- Schema según PDF Página 3

CREATE TABLE IF NOT EXISTS aeropuerto_detalles_tabla (
    aeropuerto STRING,
    oac STRING,
    iata STRING,
    tipo STRING,
    denominacion STRING,
    coordenadas_latitud STRING,
    coordenadas_longitud STRING,
    elev FLOAT,
    uom_elev STRING,
    ref STRING,
    distancia_ref FLOAT,
    direccion_ref STRING,
    condicion STRING,
    control STRING,
    region STRING,
    uso STRING,
    trafico STRING,
    sna STRING,
    concesionado STRING,
    provincia STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");

-- Mostrar tablas creadas
SHOW TABLES;

-- =====================================================
-- VERIFICACIÓN INICIAL: Datos cargados correctamente
-- =====================================================

-- Ver cuántos registros hay en cada tabla
SELECT '=== VERIFICACION DE CARGA ===' AS info;

SELECT COUNT(*) as total_vuelos FROM aeropuerto_tabla;

SELECT COUNT(*) as total_aeropuertos FROM aeropuerto_detalles_tabla;

-- Ver muestra de datos
SELECT '=== MUESTRA DE VUELOS (5 registros) ===' AS info;
SELECT * FROM aeropuerto_tabla LIMIT 5;

SELECT '=== MUESTRA DE AEROPUERTOS (5 registros) ===' AS info;
SELECT * FROM aeropuerto_detalles_tabla LIMIT 5;

-- =====================================================
-- PUNTO 5: Verificar tipos de datos (Schema)
-- =====================================================

SELECT '=== PUNTO 5: SCHEMA DE TABLAS ===' AS info;

DESCRIBE aviacion.aeropuerto_tabla;

DESCRIBE aviacion.aeropuerto_detalles_tabla;

-- =====================================================
-- PUNTO 6: Cantidad de vuelos (01/12/2021 - 31/01/2022)
-- =====================================================

SELECT '=== PUNTO 6: VUELOS ENTRE DIC 2021 Y ENE 2022 ===' AS info;

SELECT COUNT(*) as total_vuelos
FROM aeropuerto_tabla
WHERE fecha BETWEEN '2021-12-01' AND '2022-01-31';

-- Resultado esperado: ~57,984 vuelos

-- =====================================================
-- PUNTO 7: Pasajeros de Aerolíneas Argentinas (01/01/2021 - 30/06/2022)
-- =====================================================

SELECT '=== PUNTO 7: PASAJEROS AEROLINEAS ARGENTINAS ===' AS info;

SELECT SUM(pasajeros) as total_pasajeros
FROM aeropuerto_tabla
WHERE aerolinea_nombre LIKE '%AEROLINEAS ARGENTINAS%'
  AND fecha BETWEEN '2021-01-01' AND '2022-06-30';

-- Resultado esperado: ~7,484,860 pasajeros

-- =====================================================
-- PUNTO 8: Tablero de Vuelos con Ciudades (Detalle)
-- =====================================================

SELECT '=== PUNTO 8: TABLERO DE VUELOS CON CIUDADES ===' AS info;

SELECT 
    v.fecha, 
    v.horautc, 
    v.aeropuerto as codigo_salida, 
    a_salida.denominacion as ciudad_salida, 
    v.origen_destino as codigo_arribo, 
    a_arribo.denominacion as ciudad_arribo, 
    v.pasajeros
FROM aeropuerto_tabla v
LEFT JOIN aeropuerto_detalles_tabla a_salida 
    ON v.aeropuerto = a_salida.aeropuerto
LEFT JOIN aeropuerto_detalles_tabla a_arribo 
    ON v.origen_destino = a_arribo.aeropuerto
WHERE v.fecha BETWEEN '2022-01-01' AND '2022-06-30'
ORDER BY v.fecha DESC
LIMIT 10;

-- =====================================================
-- PUNTO 9: Top 10 Aerolíneas (Pasajeros)
-- =====================================================

SELECT '=== PUNTO 9: TOP 10 AEROLINEAS ===' AS info;

SELECT 
    aerolinea_nombre, 
    SUM(pasajeros) as total_pasajeros,
    COUNT(*) as total_vuelos,
    ROUND(AVG(pasajeros), 2) as promedio_pasajeros_por_vuelo
FROM aeropuerto_tabla
WHERE aerolinea_nombre IS NOT NULL 
  AND aerolinea_nombre != '0' 
GROUP BY aerolinea_nombre
ORDER BY total_pasajeros DESC
LIMIT 10;

-- =====================================================
-- PUNTO 10: Top 10 Aeronaves (Salidas desde Buenos Aires)
-- =====================================================

SELECT '=== PUNTO 10: TOP 10 AERONAVES DESDE BS AS ===' AS info;

SELECT 
    v.aeronave, 
    COUNT(*) as cantidad_despegues,
    SUM(v.pasajeros) as total_pasajeros_transportados
FROM aeropuerto_tabla v
JOIN aeropuerto_detalles_tabla d 
    ON v.aeropuerto = d.aeropuerto
WHERE (UPPER(d.provincia) LIKE '%BUENOS AIRES%' 
       OR UPPER(d.provincia) LIKE '%CAPITAL FEDERAL%')
  AND v.tipo_de_movimiento = 'Despegue'
  AND v.aeronave IS NOT NULL 
  AND v.aeronave != '0'
GROUP BY v.aeronave
ORDER BY cantidad_despegues DESC
LIMIT 10;

-- =====================================================
-- CONSULTAS ADICIONALES DE ANÁLISIS
-- =====================================================

-- Distribución de vuelos por tipo de movimiento
SELECT '=== ANALISIS: DISTRIBUCION POR TIPO DE MOVIMIENTO ===' AS info;

SELECT 
    tipo_de_movimiento,
    COUNT(*) as total_vuelos,
    SUM(pasajeros) as total_pasajeros
FROM aeropuerto_tabla
GROUP BY tipo_de_movimiento
ORDER BY total_vuelos DESC;

-- Aeropuertos más activos (Top 10)
SELECT '=== ANALISIS: TOP 10 AEROPUERTOS MAS ACTIVOS ===' AS info;

SELECT 
    v.aeropuerto as codigo,
    d.denominacion as nombre_aeropuerto,
    d.provincia,
    COUNT(*) as total_operaciones,
    SUM(v.pasajeros) as total_pasajeros
FROM aeropuerto_tabla v
LEFT JOIN aeropuerto_detalles_tabla d 
    ON v.aeropuerto = d.aeropuerto
GROUP BY v.aeropuerto, d.denominacion, d.provincia
ORDER BY total_operaciones DESC
LIMIT 10;

-- Promedio de pasajeros por clase de vuelo
SELECT '=== ANALISIS: PROMEDIO PASAJEROS POR CLASE DE VUELO ===' AS info;

SELECT 
    clase_de_vuelo,
    COUNT(*) as total_vuelos,
    ROUND(AVG(pasajeros), 2) as promedio_pasajeros,
    SUM(pasajeros) as total_pasajeros
FROM aeropuerto_tabla
WHERE clase_de_vuelo IS NOT NULL
GROUP BY clase_de_vuelo
ORDER BY total_vuelos DESC;

-- Vuelos por mes (serie temporal)
SELECT '=== ANALISIS: VUELOS POR MES ===' AS info;

SELECT 
    YEAR(fecha) as anio,
    MONTH(fecha) as mes,
    COUNT(*) as total_vuelos,
    SUM(pasajeros) as total_pasajeros
FROM aeropuerto_tabla
GROUP BY YEAR(fecha), MONTH(fecha)
ORDER BY anio, mes;

-- Verificar si hay vuelos internacionales (NO deberían existir)
SELECT '=== VERIFICACION: VUELOS INTERNACIONALES (DEBEN SER 0) ===' AS info;

SELECT COUNT(*) as vuelos_internacionales
FROM aeropuerto_tabla
WHERE LOWER(clasificacion_de_vuelo) = 'internacional';

-- Aeropuertos por provincia
SELECT '=== ANALISIS: AEROPUERTOS POR PROVINCIA ===' AS info;

SELECT 
    provincia,
    COUNT(*) as cantidad_aeropuertos,
    COUNT(DISTINCT tipo) as tipos_aeropuertos
FROM aeropuerto_detalles_tabla
WHERE provincia IS NOT NULL
GROUP BY provincia
ORDER BY cantidad_aeropuertos DESC;

-- =====================================================
-- FIN DE CONSULTAS
-- =====================================================

SELECT '=== CONSULTAS COMPLETADAS ===' AS info;

