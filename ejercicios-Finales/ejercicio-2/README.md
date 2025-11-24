# Ejercicio Final 2 - Car Rental Analytics: Airflow + PySpark + Hive

Este ejercicio implementa un pipeline ETL completo para análisis de alquileres de automóviles usando **Apache Airflow** con patrón Padre-Hijo, **PySpark** para transformaciones y JOINs complejos, y **Apache Hive** para almacenamiento y análisis SQL de datos de car rental.

## 🎯 Objetivos

- Crear Data Warehouse en Hive con schema específico
- Ingestar 2 datasets desde S3 (car rental + georef USA)
- Desarrollar script PySpark con transformaciones y JOIN
- Orquestar con Airflow usando patrón Padre-Hijo (2 DAGs)
- Aplicar análisis de negocio con 6 consultas SQL
- Elaborar conclusiones y proponer arquitectura alternativa

## 📋 Ejercicios Incluidos

### 1️⃣ **Crear Hive Database y Tabla (Punto 1)**
- Base de datos: `car_rental_db`
- Tabla: `car_rental_analytics`
- Schema con 11 columnas específicas

### 2️⃣ **Script de Ingest (Punto 2)**
- Descargar `CarRentalData.csv` desde S3
- Descargar `georef-united-states-of-america-state.csv`
- Subir ambos archivos a HDFS `/car_rental/raw`

### 3️⃣ **Script Spark con Transformaciones (Punto 3)**
- Renombrar columnas (sin espacios, sin puntos)
- Redondear `rating` float → int
- JOIN car_rental + georef por state code
- Eliminar registros con rating NULL
- Convertir `fuelType` a minúsculas
- Excluir el estado de Texas
- Insertar resultado en Hive

### 4️⃣ **Orquestación Airflow (Punto 4)**
- **DAG Padre**: Ingesta archivos → Dispara DAG hijo
- **DAG Hijo**: Procesa datos → Carga en Hive
- Patrón Parent-Child con `TriggerDagRunOperator`

### 5️⃣ **Consultas de Negocio (Punto 5)**

#### 5a. Alquileres ecológicos con rating >= 4
- Filtro: hybrid o electric con rating ≥ 4

#### 5b. Top 5 estados con menor cantidad de alquileres
- GROUP BY + ORDER BY ASC

#### 5c. Top 10 modelos más rentados (con marca)
- GROUP BY make, model

#### 5d. Alquileres por año (2010-2015)
- Análisis temporal con estadísticas

#### 5e. Top 5 ciudades con más alquileres ecológicos
- Filtro: hybrid o electric

#### 5f. Promedio de reviews por tipo de combustible
- Segmentación por fuelType

### 6️⃣ **Conclusiones y Recomendaciones (Punto 6)**
- Análisis de resultados
- Insights de negocio
- Recomendaciones estratégicas

### 7️⃣ **Arquitectura Alternativa (Punto 7)**
- Propuesta on-premise o cloud
- Comparativa de tecnologías

## 📁 Estructura del Proyecto

```
ejercicios-Finales/ejercicio-2/
├── README.md                         # Este archivo
├── GUIA_EJECUCION.md                 # Guía paso a paso completa
├── INICIO_RAPIDO.md                  # Quick start guide
├── RESUMEN_PROYECTO.md               # Resumen ejecutivo
├── CONCLUSIONES_Y_ARQUITECTURA.md    # Puntos 6 y 7
├── scripts/
│   ├── download_data.sh             # Script bash para descarga e ingest
│   └── process_car_rental.py        # Script PySpark de transformación
├── airflow/
│   ├── car_rental_parent_dag.py     # DAG Padre (ingesta)
│   ├── car_rental_child_dag.py      # DAG Hijo (procesamiento)
│   └── README.md                     # Documentación de DAGs
├── hive/
│   ├── car_rental_setup.sql         # CREATE DATABASE + TABLE
│   ├── queries.sql                  # Consultas de negocio (Punto 5)
│   └── README.md                     # Documentación de Hive
└── images/                           # Capturas de pantalla
```

## 🚀 Tecnologías Utilizadas

- **Apache Spark (PySpark)** - Procesamiento distribuido y JOIN
- **Apache Airflow** - Orquestación con patrón Padre-Hijo
- **Apache Hive** - Data warehouse y consultas SQL
- **HDFS** - Sistema de archivos distribuido
- **Python** - Lenguaje de programación
- **Bash** - Scripting y automatización
- **Docker** - Contenedorización

## 📊 Datasets Utilizados

### CarRentalData.csv
- **URL**: https://data-engineer-edvai-public.s3.amazonaws.com/CarRentalData.csv
- **Registros**: ~10,000 alquileres
- **Formato**: CSV con estructura JSON anidada
- **Campos principales**: fuelType, rating, renterTripsTaken, reviewCount, location (city, state, lat, lng), vehicle (make, model, year), rate (daily), owner (id)

### georef-united-states-of-america-state.csv
- **URL**: https://data-engineer-edvai-public.s3.amazonaws.com/georef-united-states-of-america-state.csv
- **Registros**: 51 estados USA
- **Formato**: CSV con delimitador `;`
- **Campos principales**: Official Code State, Official Name State, United States Postal Service state abbreviation

### Schema Final: car_rental_analytics

| Campo | Tipo | Descripción |
|-------|------|-------------|
| fuelType | STRING | Tipo de combustible (diesel, electric, gasoline, hybrid, other) |
| rating | INT | Rating del vehículo (1-5, redondeado) |
| renterTripsTaken | INT | Cantidad de viajes del arrendatario |
| reviewCount | INT | Cantidad de reseñas del vehículo |
| city | STRING | Ciudad donde se encuentra el vehículo |
| state_name | STRING | Nombre completo del estado (ej: California) |
| owner_id | INT | ID del propietario del vehículo |
| rate_daily | INT | Tarifa diaria de alquiler |
| make | STRING | Marca del vehículo (ej: Toyota, Honda) |
| model | STRING | Modelo del vehículo (ej: Camry, Accord) |
| year | INT | Año de fabricación del vehículo |

## 🔧 Requisitos Previos

- Contenedor Hadoop/Hive ejecutándose
- Apache Spark instalado y configurado
- Apache Airflow instalado y funcionando
- Python 3.8+ con PySpark
- HDFS accesible (hdfs://172.17.0.2:9000)
- Java 11 instalado
- Acceso a internet para descarga de datos

## 🚀 Pipeline Completo

```
┌─────────────────────────────────────────────────────────────┐
│         PASO 1: HIVE SETUP (Crear DB y Tabla)               │
│  CREATE DATABASE car_rental_db;                              │
│  CREATE TABLE car_rental_analytics (...);                    │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         PASO 2: INGEST (Descarga + HDFS)                     │
│  CSV Files (S3) → /tmp/car_rental → HDFS:/car_rental/raw   │
│  • CarRentalData.csv (~600 KB)                              │
│  • georef_usa_states.csv (~12 KB)                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         PASO 3: PROCESAMIENTO (PySpark)                      │
│  process_car_rental.py                                       │
│  1. Leer CSV desde HDFS                                      │
│  2. Renombrar columnas (location.city → city)               │
│  3. Redondear rating (float → int)                          │
│  4. Eliminar rating NULL                                     │
│  5. fuelType a minúsculas                                    │
│  6. Excluir Texas (state != 'TX')                           │
│  7. JOIN con georef (state_code → state_name)               │
│  8. Seleccionar 11 columnas finales                         │
│  9. Escribir a Hive (.saveAsTable)                          │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         PASO 4: ORQUESTACIÓN (Airflow)                       │
│  ┌─────────────────────────────────────┐                    │
│  │   DAG PADRE (car_rental_parent_dag) │                    │
│  │   inicio → crear_tabla → download   │                    │
│  │        → verificar → trigger_hijo    │                    │
│  └──────────────┬──────────────────────┘                    │
│                 │ TriggerDagRunOperator                      │
│                 ▼                                            │
│  ┌─────────────────────────────────────┐                    │
│  │   DAG HIJO (car_rental_child_dag)   │                    │
│  │   inicio → spark_process → verificar│                    │
│  │        → estadisticas → fin          │                    │
│  └─────────────────────────────────────┘                    │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         PASO 5: ANÁLISIS (Hive SQL - 6 Consultas)           │
│  5a. Alquileres ecológicos rating >= 4                      │
│  5b. Top 5 estados con menos alquileres                     │
│  5c. Top 10 modelos más rentados                            │
│  5d. Alquileres por año (2010-2015)                         │
│  5e. Top 5 ciudades ecológicas                              │
│  5f. Promedio reviews por combustible                       │
└─────────────────────────────────────────────────────────────┘
```

## 📖 Guías de Uso

### Ejecución Paso a Paso (Como se Ejecutó en Consola)

#### PASO 1: Crear Tabla en Hive

```bash
# Terminal 1: Acceder al contenedor
docker exec -it edvai_hadoop bash
su hadoop

# Entrar a Hive
hive
```

Dentro de Hive CLI:

```sql
CREATE DATABASE IF NOT EXISTS car_rental_db;

USE car_rental_db;

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

SHOW TABLES;

DESCRIBE FORMATTED car_rental_analytics;

SELECT COUNT(*) as total_registros FROM car_rental_analytics;

exit;
```

#### PASO 2: Crear y Ejecutar Script de Ingest

```bash
# Terminal 2: Abrir otra terminal y acceder al contenedor
docker exec -it edvai_hadoop bash
su hadoop
cd /home/hadoop/scripts

# Crear el archivo con nano
nano download_data.sh
```

**Copiar el contenido completo del script desde:**  
`ejercicios-Finales/ejercicio-2/scripts/download_data.sh`

**Guardar y salir de nano:**
```
Ctrl + O → Enter → Ctrl + X
```

**Dar permisos y ejecutar:**

```bash
chmod +x download_data.sh
./download_data.sh
```

**Salida esperada:**
```
==========================================
🚗 CAR RENTAL DATA DOWNLOAD
==========================================
✅ Directorio creado: /tmp/car_rental
📥 Paso 2: Descargando CarRentalData.csv...
✅ Descarga exitosa: CarRentalData.csv
📥 Paso 3: Descargando georef USA states...
✅ Descarga exitosa: georef_usa_states.csv
⬆️  Paso 8: Subiendo archivos a HDFS...
✅ DESCARGA COMPLETADA EXITOSAMENTE
```

#### PASO 3: Crear y Ejecutar Script de Procesamiento Spark

```bash
# En la misma terminal (o abrir otra)
docker exec -it edvai_hadoop bash
su hadoop
cd /home/hadoop/scripts

# Crear el archivo con nano
nano process_car_rental.py
```

**Copiar el contenido completo del script desde:**  
`ejercicios-Finales/ejercicio-2/scripts/process_car_rental.py`

**Guardar y salir de nano:**
```
Ctrl + O → Enter → Ctrl + X
```

**Dar permisos y ejecutar:**

```bash
chmod +x process_car_rental.py
spark-submit ./process_car_rental.py
```

**Salida esperada:**
```
============================================================
🚗 CAR RENTAL DATA PROCESSING
============================================================
✅ Sesión de Spark creada exitosamente
✅ Datos cargados: 10085 registros
✅ Transformaciones aplicadas
✅ JOIN completado
✅ Datos insertados en Hive
✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE
```

#### PASO 4: Crear DAGs de Airflow

```bash
# Acceder al contenedor
docker exec -it edvai_hadoop bash
su hadoop
cd /home/hadoop/airflow/dags

# Crear DAG Padre
nano car_rental_parent_dag.py
```

**Copiar el contenido completo del script desde:**  
`ejercicios-Finales/ejercicio-2/airflow/car_rental_parent_dag.py`

**Guardar:** `Ctrl + O → Enter → Ctrl + X`

```bash
# Crear DAG Hijo
nano car_rental_child_dag.py
```

**Copiar el contenido completo del script desde:**  
`ejercicios-Finales/ejercicio-2/airflow/car_rental_child_dag.py`

**Guardar:** `Ctrl + O → Enter → Ctrl + X`

**Dar permisos:**

```bash
chmod +x car_rental_parent_dag.py
chmod +x car_rental_child_dag.py
```

#### PASO 5: Ejecutar DAGs en Airflow

**Opción A: Desde la UI de Airflow**

1. Acceder a `http://localhost:8080`
2. Buscar `car_rental_parent_dag`
3. Activar el toggle
4. Click en "Trigger DAG"
5. Monitorear ejecución (el DAG hijo se dispara automáticamente)

**Opción B: Desde CLI**

```bash
# Reiniciar scheduler (si es necesario)
pkill -f "airflow scheduler"
sleep 3
nohup airflow scheduler > /tmp/scheduler.log 2>&1 &

# Activar DAGs
airflow dags unpause car_rental_parent_dag
airflow dags unpause car_rental_child_dag

# Verificar que están activos
airflow dags list | grep car_rental

# Ejecutar DAG padre (dispara el hijo automáticamente)
airflow dags trigger car_rental_parent_dag
```

#### PASO 6: Verificar Datos en Hive

```bash
# Volver a Hive para verificar
hive -e "USE car_rental_db; SELECT COUNT(*) FROM car_rental_analytics;"

# Ver muestra de datos
hive -e "USE car_rental_db; SELECT * FROM car_rental_analytics LIMIT 5;"
```

## 🎯 Resultados Obtenidos (Reales)

### Datos Procesados
- **Total registros procesados**: 4,844 alquileres
- **Estados únicos**: 50 (sin Texas)
- **Tipos de combustible**: 4 (diesel, electric, gasoline, hybrid)
- **Rating mínimo**: 1
- **Rating máximo**: 5
- **Años de vehículos**: 1990-2024

### Análisis de Negocio

#### **Punto 5a - Alquileres ecológicos con rating >= 4**

**Total: 771 alquileres ecológicos**

| Tipo | Cantidad | Rating Promedio | Total Viajes |
|------|----------|-----------------|--------------|
| Electric | 542 | 4.99 | 17,601 |
| Hybrid | 229 | 4.99 | 9,348 |

**Insight:** Los vehículos eléctricos representan el 70% de los alquileres ecológicos con excelente rating.

---

#### **Punto 5b - Top 5 estados con menos alquileres**

| Estado | Total Alquileres | Rating Promedio | Tarifa Diaria Promedio |
|--------|------------------|-----------------|------------------------|
| 1. Montana | 1 | 5.0 | $74.00 |
| 2. West Virginia | 3 | 5.0 | $59.33 |
| 3. New Hampshire | 3 | 5.0 | $83.00 |
| 4. Delaware | 4 | 5.0 | $54.50 |
| 5. Mississippi | 4 | 5.0 | $41.75 |

**Insight:** Estados con baja densidad poblacional tienen pocos alquileres pero ratings perfectos (5.0).

---

#### **Punto 5c - Top 10 modelos más rentados (con marca)**

| Posición | Marca | Modelo | Alquileres | Rating | Tarifa/Día | Total Viajes |
|----------|-------|--------|------------|--------|------------|--------------|
| 1 | Tesla | Model 3 | 288 | 4.98 | $128.01 | 9,794 |
| 2 | Ford | Mustang | 136 | 4.96 | $74.87 | 5,882 |
| 3 | Tesla | Model S | 122 | 4.98 | $135.42 | 3,952 |
| 4 | Jeep | Wrangler | 108 | 4.99 | $78.25 | 4,762 |
| 5 | Tesla | Model X | 103 | 4.99 | $192.70 | 3,638 |
| 6 | Toyota | Corolla | 78 | 4.96 | $35.55 | 4,676 |
| 7 | Mercedes-Benz | C-Class | 78 | 4.96 | $79.27 | 2,818 |
| 8 | BMW | 3 Series | 76 | 4.99 | $62.62 | 3,293 |
| 9 | Chevrolet | Corvette | 68 | 4.99 | $176.21 | 4,164 |
| 10 | Chevrolet | Camaro | 61 | 5.0 | $87.02 | 2,797 |

**Insights clave:**
- 🚗 **Tesla domina el mercado**: 3 modelos en el top 5 (513 alquileres, 35% del top 10)
- 💰 **Economía vs. Premium**: Corolla ($35.55) vs. Model X ($192.70)
- ⭐ **Excelentes ratings**: Todos los modelos >4.96, Camaro con 5.0 perfecto

---

#### **Punto 5d - Alquileres por año (2010-2015)**

| Año | Alquileres | Rating Promedio | Tarifa/Día Promedio | Marcas Únicas | Total Viajes |
|-----|------------|-----------------|---------------------|---------------|--------------|
| 2010 | 144 | 4.97 | $61.01 | 30 | 6,754 |
| 2011 | 200 | 4.98 | $69.72 | 30 | 8,141 |
| 2012 | 225 | 4.97 | $60.83 | 28 | 9,999 |
| 2013 | 305 | 4.97 | $78.30 | 35 | 12,328 |
| 2014 | 382 | 4.98 | $84.48 | 36 | 15,477 |
| 2015 | 532 | 4.98 | $94.53 | 37 | 18,799 |
| **TOTAL** | **1,788** | **4.97** | **$75.81** | **46** | **71,498** |

**Estadísticas del periodo:**
- 📈 **Crecimiento sostenido**: De 144 (2010) a 532 (2015) alquileres/año (+269%)
- 💵 **Aumento de tarifas**: De $61 (2010) a $94.53 (2015) por día (+55%)
- 🏭 **Diversidad**: 46 marcas diferentes, 302 modelos distintos

---

#### **Punto 5e - Top 5 ciudades con más alquileres ecológicos**

| Ciudad | Estado | Total Ecológicos | Rating | Híbridos | Eléctricos | Tarifa/Día |
|--------|--------|------------------|--------|----------|------------|------------|
| 1. San Diego | California | 44 | 5.0 | 13 | 31 | $105.68 |
| 2. Las Vegas | Nevada | 34 | 4.97 | 2 | 32 | $145.47 |
| 3. Portland | Oregon | 20 | 5.0 | 4 | 16 | $115.00 |
| 4. Phoenix | Arizona | 17 | 5.0 | 9 | 8 | $90.82 |
| 5. San Jose | California | 15 | 5.0 | 4 | 11 | $90.53 |

**Insights:**
- 🌴 **California lidera**: 2 ciudades en el top 5 (San Diego + San Jose)
- ⚡ **Preferencia eléctrica**: 88 eléctricos vs 32 híbridos (73% vs 27%)
- ⭐ **Ratings perfectos**: 4 de 5 ciudades con rating 5.0
- 💰 **Tarifas premium**: Las Vegas más cara ($145.47/día)

---

#### **Punto 5f - Promedio de reviews por tipo de combustible**

| Tipo Combustible | Vehículos | Promedio Reviews | Mín | Máx | Rating | Total Reviews |
|------------------|-----------|------------------|-----|-----|--------|---------------|
| 1. **Hybrid** | 229 | **34.87** | 1 | 193 | 4.99 | 7,986 |
| 2. **Gasoline** | 4,015 | **31.93** | 1 | 321 | 4.98 | 128,187 |
| 3. **Electric** | 542 | **28.34** | 1 | 248 | 4.99 | 15,360 |
| 4. **Diesel** | 58 | **17.50** | 1 | 103 | 4.98 | 1,015 |

**Insights clave:**
- 🌱 **Híbridos más comentados**: 34.87 reviews promedio (mayor engagement)
- ⛽ **Gasolina domina volumen**: 4,015 vehículos (83% del total)
- ⚡ **Eléctricos en crecimiento**: 542 vehículos, rating 4.99
- 🚜 **Diesel minoritario**: Solo 58 vehículos (1.2% del mercado)

**Conclusión General:**
- Rating promedio general: **4.98/5.0** (excelente satisfacción)
- Vehículos ecológicos (hybrid + electric): **771 unidades** (15.9% del total)
- Tendencia clara hacia electrificación de la flota

## 📝 Notas Importantes

### Transformaciones Críticas

**1. Manejo de Columnas Anidadas**

El archivo `CarRentalData.csv` tiene estructura JSON anidada:
```python
# Problema: location.city, location.state
# Solución: Usar backticks y alias
col("`location.city`").alias("city")
col("`location.state`").alias("state")
```

**2. Mapeo del State Code**

```python
# Problema: FIPS code vs USPS abbreviation
# Solución: Usar columna correcta para JOIN
df_states.select(
    col("`United States Postal Service state abbreviation`").alias("state_code")
)
```

**3. Exclusión de Texas**

```python
# Aplicar ANTES del JOIN para eficiencia
df_rental_sin_texas = df_rental.filter(col("state") != "TX")
```

### Patrón Airflow Padre-Hijo

**DAG Padre**:
- Responsabilidad: Ingesta de datos
- Dispara: DAG Hijo usando `TriggerDagRunOperator`
- Configuración: `wait_for_completion=False`

**DAG Hijo**:
- Responsabilidad: Procesamiento y carga
- Se ejecuta solo cuando es disparado por el padre
- Configuración: `schedule_interval=None`

## 🔧 Troubleshooting

### Problema: "cannot resolve 'location.city'"
**Causa**: Columnas anidadas no reconocidas  
**Solución**: Usar backticks `` `location.city` ``

### Problema: "DataFrame está vacío después de JOIN"
**Causa**: Mismatch en state codes (FIPS vs USPS)  
**Solución**: Usar `United States Postal Service state abbreviation`

### Problema: "DAG hijo no se ejecuta"
**Causa**: DAG hijo pausado o no detectado  
**Solución**:
```bash
airflow dags list | grep car_rental
airflow dags unpause car_rental_child_dag
```

### Problema: "JAVA_HOME incorrecto"
**Causa**: Script apunta a Java 8  
**Solución**:
```bash
# En download_data.sh, cambiar a:
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

## 🔗 Referencias

- [PySpark SQL Functions](https://spark.apache.org/docs/latest/api/python/reference/pyspark.sql/functions.html)
- [Hive Language Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual)
- [Airflow TriggerDagRunOperator](https://airflow.apache.org/docs/apache-airflow/stable/howto/operator/trigger_dagrun.html)
- [Cornell Car Rental Dataset](https://www.kaggle.com/datasets/kushleshkumar/cornell-car-rental-dataset)

## 📧 Contacto

Para consultas sobre el pipeline de car rental analytics, contactar al equipo de Data Engineering de Edvai.

---

**Cliente**: Car Rental Analytics Company  
**Autor**: Data Engineering Team - Edvai  
**Fecha**: 2025-11-24  
**Versión**: 2.0 (PySpark + Airflow Parent-Child Pattern)  
**Tecnología Principal**: Apache Spark + Airflow + Hive
