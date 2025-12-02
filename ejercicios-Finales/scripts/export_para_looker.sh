#!/bin/bash

# =====================================================
# Script: export_para_looker.sh
# Descripción: Exporta datos desde Hive en formato CSV
#              listo para subir a Google Sheets → Looker Studio
# Autor: Data Engineering Team
# Fecha: 2025-12-01
# USO: Ejecutar dentro del contenedor Hadoop como usuario hadoop
# =====================================================

# Cargar variables de entorno
export HIVE_HOME=/home/hadoop/hive
export HADOOP_HOME=/home/hadoop/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${BLUE}╔════════════════════════════════════════════════╗"
echo -e "║  📊 EXPORTACIÓN PARA LOOKER STUDIO            ║"
echo -e "║  Datos listos para Google Sheets              ║"
echo -e "╚════════════════════════════════════════════════╝${NC}"
echo ""

# Directorio de salida
OUTPUT_DIR="/tmp/looker_exports"
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

echo -e "${YELLOW}📁 Directorio: $OUTPUT_DIR${NC}"
echo ""

# ============================================
# EJERCICIO 1 - AVIACIÓN
# ============================================
echo -e "${BLUE}✈️  EJERCICIO 1 - AVIACIÓN CIVIL${NC}"
echo ""

# 1. Total de vuelos (KPI)
echo "📊 1/6 - Exportando: Total de vuelos (Punto 6)..."
hive --silent -e "
SET hive.cli.print.header=true;
USE aviacion;
SELECT 'Total Vuelos' as Metrica, COUNT(*) as Valor
FROM aeropuerto_tabla
WHERE fecha BETWEEN '2021-12-01' AND '2022-01-31';
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej1_total_vuelos.csv

echo -e "${GREEN}   ✅ ej1_total_vuelos.csv${NC}"

# 2. Pasajeros Aerolíneas Argentinas (KPI)
echo "📊 2/6 - Exportando: Pasajeros Aerolíneas Argentinas (Punto 7)..."
hive --silent -e "
SET hive.cli.print.header=true;
USE aviacion;
SELECT 'Pasajeros AA' as Metrica, SUM(pasajeros) as Valor
FROM aeropuerto_tabla
WHERE aerolinea_nombre LIKE '%AEROLINEAS ARGENTINAS%'
  AND fecha BETWEEN '2021-01-01' AND '2022-06-30';
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej1_pasajeros_aa.csv

echo -e "${GREEN}   ✅ ej1_pasajeros_aa.csv${NC}"

# 3. Top 10 Aerolíneas
echo "📊 3/6 - Exportando: Top 10 Aerolíneas (Punto 9)..."
hive --silent -e "
SET hive.cli.print.header=true;
USE aviacion;
SELECT 
    aerolinea_nombre as Aerolinea, 
    SUM(pasajeros) as Total_Pasajeros
FROM aeropuerto_tabla
WHERE aerolinea_nombre IS NOT NULL 
  AND aerolinea_nombre != '0'
GROUP BY aerolinea_nombre
ORDER BY Total_Pasajeros DESC
LIMIT 10;
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej1_top10_aerolineas.csv

echo -e "${GREEN}   ✅ ej1_top10_aerolineas.csv${NC}"

# 4. Top 10 Aeronaves
echo "📊 4/6 - Exportando: Top 10 Aeronaves (Punto 10)..."
hive --silent -e "
SET hive.cli.print.header=true;
USE aviacion;
SELECT 
    v.aeronave as Aeronave, 
    COUNT(*) as Cantidad_Despegues
FROM aeropuerto_tabla v
JOIN aeropuerto_detalles_tabla d ON v.aeropuerto = d.aeropuerto
WHERE (UPPER(d.provincia) LIKE '%BUENOS AIRES%' 
    OR UPPER(d.provincia) LIKE '%CAPITAL FEDERAL%')
  AND v.tipo_de_movimiento = 'Despegue'
  AND v.aeronave IS NOT NULL 
  AND v.aeronave != '0'
GROUP BY v.aeronave
ORDER BY Cantidad_Despegues DESC
LIMIT 10;
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej1_top10_aeronaves.csv

echo -e "${GREEN}   ✅ ej1_top10_aeronaves.csv${NC}"
echo ""

# ============================================
# EJERCICIO 2 - CAR RENTAL
# ============================================
echo -e "${BLUE}🚗 EJERCICIO 2 - CAR RENTAL${NC}"
echo ""

# 1. Alquileres ecológicos (KPI)
echo "📊 5/12 - Exportando: Alquileres Ecológicos (Punto 5a)..."
hive --silent -e "
SET hive.cli.print.header=true;
USE car_rental_db;
SELECT 'Alquileres Ecologicos' as Metrica, COUNT(*) as Valor
FROM car_rental_analytics
WHERE (fuelType = 'hybrid' OR fuelType = 'electric')
  AND rating >= 4;
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej2_alquileres_ecologicos.csv

echo -e "${GREEN}   ✅ ej2_alquileres_ecologicos.csv${NC}"

# 2. Desglose ecológicos por tipo
echo "📊 6/12 - Exportando: Desglose Ecológicos..."
hive --silent -e "
SET hive.cli.print.header=true;
USE car_rental_db;
SELECT 
    fuelType as Tipo_Combustible,
    COUNT(*) as Total_Alquileres,
    ROUND(AVG(rating), 2) as Rating_Promedio
FROM car_rental_analytics
WHERE (fuelType = 'hybrid' OR fuelType = 'electric')
  AND rating >= 4
GROUP BY fuelType;
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej2_ecologicos_desglose.csv

echo -e "${GREEN}   ✅ ej2_ecologicos_desglose.csv${NC}"

# 3. 5 Estados con menor cantidad
echo "📊 7/12 - Exportando: Estados Baja Demanda (Punto 5b)..."
hive --silent -e "
SET hive.cli.print.header=true;
USE car_rental_db;
SELECT
    state_name as Estado,
    COUNT(*) as Total_Alquileres,
    ROUND(AVG(rating), 2) as Rating_Promedio,
    ROUND(AVG(rate_daily), 2) as Tarifa_Promedio_USD
FROM car_rental_analytics
WHERE state_name IS NOT NULL
GROUP BY state_name
ORDER BY Total_Alquileres ASC
LIMIT 5;
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej2_estados_baja_demanda.csv

echo -e "${GREEN}   ✅ ej2_estados_baja_demanda.csv${NC}"

# 4. Top 10 Modelos
echo "📊 8/12 - Exportando: Top 10 Modelos (Punto 5c)..."
hive --silent -e "
SET hive.cli.print.header=true;
USE car_rental_db;
SELECT
    make as Marca,
    model as Modelo,
    COUNT(*) as Total_Alquileres,
    ROUND(AVG(rating), 2) as Rating_Promedio,
    ROUND(AVG(rate_daily), 2) as Tarifa_Diaria_USD
FROM car_rental_analytics
WHERE make IS NOT NULL AND model IS NOT NULL
GROUP BY make, model
ORDER BY Total_Alquileres DESC
LIMIT 10;
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej2_top10_modelos.csv

echo -e "${GREEN}   ✅ ej2_top10_modelos.csv${NC}"

# 5. Alquileres por año
echo "📊 9/12 - Exportando: Alquileres por Año (Punto 5d)..."
hive --silent -e "
SET hive.cli.print.header=true;
USE car_rental_db;
SELECT
    year as Anio,
    COUNT(*) as Total_Alquileres,
    ROUND(AVG(rating), 2) as Rating_Promedio,
    ROUND(AVG(rate_daily), 2) as Tarifa_Promedio_USD
FROM car_rental_analytics
WHERE year BETWEEN 2010 AND 2015
GROUP BY year
ORDER BY year;
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej2_alquileres_por_anio.csv

echo -e "${GREEN}   ✅ ej2_alquileres_por_anio.csv${NC}"

# 6. Top 5 Ciudades Ecológicas
echo "📊 10/12 - Exportando: Ciudades Ecológicas (Punto 5e)..."
hive --silent -e "
SET hive.cli.print.header=true;
USE car_rental_db;
SELECT
    city as Ciudad,
    state_name as Estado,
    COUNT(*) as Total_Alquileres,
    ROUND(AVG(rating), 2) as Rating_Promedio,
    SUM(CASE WHEN fuelType = 'hybrid' THEN 1 ELSE 0 END) as Hibridos,
    SUM(CASE WHEN fuelType = 'electric' THEN 1 ELSE 0 END) as Electricos
FROM car_rental_analytics
WHERE (fuelType = 'hybrid' OR fuelType = 'electric')
  AND city IS NOT NULL
GROUP BY city, state_name
ORDER BY Total_Alquileres DESC
LIMIT 5;
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej2_top5_ciudades_ecologicas.csv

echo -e "${GREEN}   ✅ ej2_top5_ciudades_ecologicas.csv${NC}"

# 7. Reviews por Combustible
echo "📊 11/12 - Exportando: Reviews por Combustible (Punto 5f)..."
hive --silent -e "
SET hive.cli.print.header=true;
USE car_rental_db;
SELECT
    fuelType as Tipo_Combustible,
    COUNT(*) as Total_Vehiculos,
    ROUND(AVG(reviewCount), 2) as Promedio_Reviews,
    MIN(reviewCount) as Min_Reviews,
    MAX(reviewCount) as Max_Reviews,
    ROUND(AVG(rating), 2) as Rating_Promedio
FROM car_rental_analytics
GROUP BY fuelType
ORDER BY Promedio_Reviews DESC;
" | sed 's/\t/,/g' > $OUTPUT_DIR/ej2_reviews_por_combustible.csv

echo -e "${GREEN}   ✅ ej2_reviews_por_combustible.csv${NC}"
echo ""

# ============================================
# CREAR ARCHIVO ZIP
# ============================================
echo -e "${BLUE}📦 Comprimiendo archivos...${NC}"
cd /tmp
tar -czf looker_exports.tar.gz looker_exports/
echo -e "${GREEN}   ✅ looker_exports.tar.gz creado${NC}"
echo ""

# ============================================
# RESUMEN
# ============================================
echo -e "${BLUE}╔════════════════════════════════════════════════╗"
echo -e "║  ✅ EXPORTACIÓN COMPLETADA                     ║"
echo -e "╚════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}📊 Archivos generados:${NC}"
ls -lh $OUTPUT_DIR | tail -n +2 | awk '{print "   📄 " $9 " (" $5 ")"}'
echo ""

echo -e "${YELLOW}📋 Total de archivos: $(ls $OUTPUT_DIR | wc -l)${NC}"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🔧 SIGUIENTE PASO: Copiar archivos a Windows${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "En PowerShell (Windows), ejecuta:"
echo ""
echo -e "${GREEN}# Crear carpeta en Desktop"
echo "mkdir C:\\Users\\enz_9\\Desktop\\looker_exports"
echo ""
echo "# Copiar todos los archivos"
echo "docker cp edvai_hadoop:/tmp/looker_exports C:\\Users\\enz_9\\Desktop\\"
echo ""
echo "# O copiar el ZIP comprimido"
echo "docker cp edvai_hadoop:/tmp/looker_exports.tar.gz C:\\Users\\enz_9\\Desktop\\"
echo -e "${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}📚 GUÍA COMPLETA EN:${NC}"
echo "   ejercicios-Finales/LOOKER_STUDIO_PASO_A_PASO.md"
echo ""

echo -e "${GREEN}🎉 ¡Listo para crear visualizaciones en Looker Studio!${NC}"
echo ""

