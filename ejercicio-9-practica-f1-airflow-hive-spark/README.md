# Ejercicio 9 - Práctica F1: Airflow + Hive + Spark

Este ejercicio integra **Apache Airflow** para orquestación de workflows, **Apache Hive** para almacenamiento de datos estructurados y **Apache Spark** para procesamiento distribuido, utilizando datos reales de Formula 1 World Championship (1950-2020).

## 🎯 Objetivos

- Crear tablas externas en Hive para almacenamiento de datos de Formula 1
- Desarrollar scripts de automatización para ingesta de datos desde S3
- Procesar datos con Spark para generar resultados específicos
- Orquestar todo el pipeline con Apache Airflow
- Implementar un flujo completo de ETL automatizado

## 📋 Ejercicios Incluidos

### 1️⃣ **Configuración de Base de Datos Hive**
- Crear base de datos `f1` en Hive
- Definir tabla externa `driver_results` con esquema específico
- Definir tabla externa `constructor_results` con esquema específico
- Verificar estructura y metadatos de las tablas

### 2️⃣ **Verificación de Esquemas**
- Mostrar el esquema de `driver_results`
- Mostrar el esquema de `constructor_results`

### 3️⃣ **Script de Ingesta Automatizada**
- Crear script bash para descarga de archivos CSV desde S3
- Implementar validaciones de conectividad y servicios
- Configurar subida automática a HDFS
- Incluir limpieza de archivos temporales

### 4️⃣ **Procesamiento con Spark**
- Desarrollar script Python para procesamiento de datos
- Insertar en `driver_results` los corredores con mayor cantidad de puntos en la historia
- Insertar en `constructor_results` quienes obtuvieron más puntos en el Spanish Grand Prix en 1991

### 5️⃣ **Orquestación con Airflow**
- Crear DAG para automatización del pipeline
- Configurar tareas secuenciales y dependencias
- Implementar verificación de resultados
- Monitorear ejecución del workflow

## 📁 Estructura del Ejercicio

```
ejercicio-9-practica-f1-airflow-hive-spark/
├── README.md                    # Documentación principal
├── scripts/
│   ├── f1_download_and_ingest.sh # Script de descarga e ingesta desde S3
│   ├── process_f1_data.py       # Procesamiento con Spark
│   └── README.md               # Documentación de scripts
├── airflow/
│   ├── f1_processing.py        # DAG de Airflow
│   └── README.md               # Documentación de Airflow
├── hive/
│   ├── f1-setup.sql            # Scripts SQL de Hive
│   └── README.md               # Documentación de Hive
├── images/                     # Capturas de pantalla
└── ejercicios-resueltos.md     # Resultados completos
```

## 🚀 Tecnologías Utilizadas

- **Apache Airflow** - Orquestación de workflows
- **Apache Hive** - Data warehouse y consultas SQL
- **Apache Spark** - Procesamiento distribuido de datos
- **PySpark** - API de Python para Spark
- **HDFS** - Sistema de archivos distribuido
- **CSV** - Formato de datos delimitado
- **Bash Scripting** - Automatización de procesos
- **AWS S3** - Almacenamiento de datos fuente

## 📊 Dataset Utilizado

- **Fuente**: Formula 1 World Championship (1950-2020)
- **Archivos**: 
  - `results.csv` - Resultados de carreras
  - `drivers.csv` - Información de corredores
  - `constructors.csv` - Información de constructores
  - `races.csv` - Información de carreras
- **Diccionario**: [Kaggle - Formula 1 Dataset](https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020)

## 🔗 URLs de Datos

Los archivos CSV están disponibles en S3:

- `results.csv`: https://data-engineer-edvai-public.s3.amazonaws.com/results.csv
- `drivers.csv`: https://data-engineer-edvai-public.s3.amazonaws.com/drivers.csv
- `constructors.csv`: https://data-engineer-edvai-public.s3.amazonaws.com/constructors.csv
- `races.csv`: https://data-engineer-edvai-public.s3.amazonaws.com/races.csv

## 🔧 Requisitos Previos

- Contenedor de Hadoop ejecutándose
- Apache Hive configurado y funcionando
- Apache Spark disponible en el ambiente
- Apache Airflow instalado y configurado
- Acceso a internet para descarga de archivos desde S3
- Conocimientos básicos de SQL, Python y Bash

## 📖 Guías Adicionales

- **Configuración de Hive**: `hive/README.md`
- **Scripts de Automatización**: `scripts/README.md` (por crear)
- **Configuración de Airflow**: `airflow/README.md` (por crear)
- **Resultados de Ejercicios**: `ejercicios-resueltos.md` (por crear)

## 🎯 Resultados Esperados

Al completar este ejercicio, habrás:

1. ✅ Configurado una base de datos Hive con tablas externas para F1
2. ✅ Automatizado la descarga e ingesta de datos CSV desde S3 a HDFS
3. ✅ Procesado datos con Spark para encontrar top corredores y constructores
4. ✅ Orquestado todo el pipeline con Apache Airflow
5. ✅ Verificado la integridad de los datos procesados

## 📝 Notas Importantes

- Las tablas externas apuntan a ubicaciones específicas en HDFS
- Los datos deben ser procesados antes de insertarse en las tablas (JOINs entre CSV)
- Los scripts de Spark deben generar los archivos CSV con el formato correcto
- El DAG de Airflow debe ejecutarse en el orden correcto: descarga → procesamiento → verificación

