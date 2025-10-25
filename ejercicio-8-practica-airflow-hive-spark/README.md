# Ejercicio 8 - Práctica Airflow + Hive + Spark

Este ejercicio integra **Apache Airflow** para orquestación de workflows, **Apache Hive** para almacenamiento de datos estructurados y **Apache Spark** para procesamiento distribuido, utilizando datos reales de taxis de Nueva York.

## 🎯 Objetivos

- Crear tablas externas en Hive para almacenamiento de datos
- Desarrollar scripts de automatización para ingesta de datos
- Procesar datos con Spark y aplicar filtros específicos
- Orquestar todo el pipeline con Apache Airflow
- Implementar un flujo completo de ETL automatizado

## 📋 Ejercicios Incluidos

### 1️⃣ **Configuración de Base de Datos Hive**
- Crear base de datos `tripdata` en Hive
- Definir tabla externa `airport_trips` con esquema específico
- Configurar almacenamiento en formato Parquet
- Verificar estructura y metadatos de la tabla

### 2️⃣ **Script de Ingesta Automatizada**
- Crear script bash para descarga de archivos Parquet
- Implementar validaciones de conectividad y servicios
- Configurar subida automática a HDFS
- Incluir limpieza de archivos temporales

### 3️⃣ **Procesamiento con Spark**
- Desarrollar script Python para procesamiento de datos
- Unir datasets de enero y febrero 2021
- Aplicar filtros específicos (aeropuertos + pago en efectivo)
- Insertar resultados en tabla Hive

### 4️⃣ **Orquestación con Airflow**
- Crear DAG para automatización del pipeline
- Configurar tareas secuenciales y dependencias
- Implementar verificación de resultados
- Monitorear ejecución del workflow

## 📁 Estructura del Ejercicio

```
ejercicio-8-practica-airflow-hive-spark/
├── README.md                    # Documentación principal
├── scripts/
│   ├── download_and_ingest.sh   # Script de descarga e ingesta
│   ├── process_airport_trips.py # Procesamiento con Spark
│   └── README.md               # Documentación de scripts
├── airflow/
│   ├── airport_trips_processing.py # DAG de Airflow
│   └── README.md               # Documentación de Airflow
├── hive/
│   ├── hive-setup.sql          # Scripts SQL de Hive
│   └── README.md               # Documentación de Hive
├── images/                     # Capturas de pantalla
│   ├── ejercicio1-create-tripdata.jpg
│   ├── ejercicio2-describe-airporttrips.jpg
│   └── ejercicio5-airflow.jpg
└── ejercicios-resueltos.md     # Resultados completos
```

## 🚀 Tecnologías Utilizadas

- **Apache Airflow** - Orquestación de workflows
- **Apache Hive** - Data warehouse y consultas SQL
- **Apache Spark** - Procesamiento distribuido de datos
- **PySpark** - API de Python para Spark
- **HDFS** - Sistema de archivos distribuido
- **Parquet** - Formato de datos columnar
- **Bash Scripting** - Automatización de procesos

## 📊 Dataset Utilizado

- **Fuente**: NYC Taxi Data (Yellow Taxi)
- **Archivos**: 
  - `yellow_tripdata_2021-01.parquet` (~20.7 MB)
  - `yellow_tripdata_2021-02.parquet` (~20.8 MB)
- **Registro**: Enero y Febrero 2021
- **Diccionario**: [NYC TLC Data Dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf)

## 🔧 Requisitos Previos

- Contenedor de Hadoop ejecutándose
- Apache Hive configurado y funcionando
- Apache Spark disponible en el ambiente
- Apache Airflow instalado y configurado
- Acceso a internet para descarga de archivos
- Conocimientos básicos de SQL, Python y Bash

## 📖 Guías Adicionales

- **Scripts de Automatización**: `scripts/README.md`
- **Configuración de Airflow**: `airflow/README.md`
- **Configuración de Hive**: `hive/README.md`
- **Resultados de Ejercicios**: `ejercicios-resueltos.md`

## 🎯 Resultados Esperados

Al completar este ejercicio, habrás:

1. ✅ Configurado una base de datos Hive con tabla externa
2. ✅ Automatizado la descarga e ingesta de datos a HDFS
3. ✅ Procesado datos con Spark aplicando filtros específicos
4. ✅ Orquestado todo el pipeline con Apache Airflow
5. ✅ Verificado la integridad de los datos procesados

## 📈 Métricas del Pipeline

- **Datos procesados**: ~2.7 millones de registros
- **Filtros aplicados**: Viajes a aeropuertos pagados en efectivo
- **Resultado final**: 1 registro filtrado e insertado
- **Tiempo de ejecución**: ~2-3 minutos (dependiendo del hardware)
