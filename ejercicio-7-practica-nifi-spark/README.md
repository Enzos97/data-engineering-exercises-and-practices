# Ejercicio 7 - Práctica NiFi + Spark

Este ejercicio combina **Apache NiFi** para el procesamiento de flujos de datos y **Apache Spark** para el análisis de datos, utilizando un dataset real de taxis de Nueva York.

## 🎯 Objetivos

- Crear flujos de datos en NiFi para ingesta automática
- Procesar archivos Parquet con NiFi
- Realizar análisis de datos con PySpark
- Aplicar consultas SQL sobre datasets de taxis
- Generar insights de negocio a partir de datos reales

## 📋 Ejercicios Incluidos

### 1️⃣ **Configuración del Ambiente**
- Crear script de descarga de archivo Parquet
- Configurar directorios en contenedor NiFi
- Verificar descarga del archivo

### 2️⃣ **Flujo de NiFi**
- **GetFile**: Obtener archivo desde `/home/nifi/ingest`
- **PutHDFS**: Ingestar archivo a HDFS en directorio `/nifi`
- Configurar procesadores y conexiones

### 3️⃣ **Análisis con PySpark**
- Cargar datos desde HDFS
- Crear vista temporal para consultas SQL
- Ejecutar 6 consultas de análisis de datos

## 📁 Estructura del Ejercicio

```
ejercicio-7-practica-nifi-spark/
├── README.md                    # Documentación principal
├── scripts/
│   ├── download_parquet.sh     # Script de descarga
│   └── README.md               # Documentación de scripts
├── nifi/
│   ├── nifi-flow-guide.md      # Guía del flujo de NiFi
│   └── README.md               # Documentación de NiFi
├── spark/
│   ├── spark-analysis.md       # Análisis de datos con Spark
│   └── README.md               # Documentación de Spark
├── images/                     # Capturas de pantalla
│   └── nifi-process.jpg       # Flujo de NiFi
└── ejercicios-resueltos.md     # Resultados completos
```

## 🚀 Tecnologías Utilizadas

- **Apache NiFi** - Procesamiento de flujos de datos
- **Apache Spark** - Motor de procesamiento distribuido
- **PySpark** - API de Python para Spark
- **HDFS** - Sistema de archivos distribuido
- **Parquet** - Formato de datos columnar
- **SQL** - Consultas estructuradas

## 📊 Dataset Utilizado

- **Fuente**: NYC Taxi Data (Yellow Taxi)
- **Archivo**: `yellow_tripdata_2021-01.parquet`
- **Tamaño**: ~20.6 MB
- **Registro**: Enero 2021
- **Diccionario**: [NYC TLC Data Dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf)

## 🔧 Requisitos Previos

- Contenedor de NiFi ejecutándose
- Contenedor de Hadoop ejecutándose
- PySpark disponible en el ambiente
- Acceso a internet para descarga de archivos
- Conocimientos básicos de SQL y Python
