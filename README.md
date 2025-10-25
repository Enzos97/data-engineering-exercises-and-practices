# 📊 Data Engineering Exercises and Practices

Este repositorio contiene ejercicios prácticos de **ingeniería de datos** enfocados en la ingesta de datos usando **Hadoop**, **HDFS** y **Sqoop**. Incluye scripts automatizados para diferentes escenarios de ingesta.

---

## 🎯 Objetivos

- Practicar la ingesta de datos desde fuentes externas hacia HDFS
- Automatizar procesos de ETL usando scripts bash
- Conectar bases de datos relacionales (PostgreSQL) con Hadoop usando Sqoop
- Gestionar archivos temporales y limpieza de datos

---

## 📁 Estructura del Repositorio

```
data-engineering-exercises-and-practices/
├── ejercicio-3-practica-de-ingest-local/     # Ingesta desde fuentes externas
│   ├── scripts/
│   │   └── landing.sh                        # Script de ingesta local
│   ├── images/                               # Capturas de pantalla
│   └── README.md
├── ejercicio-4-practica-ingest-sqoop/        # Ingesta desde PostgreSQL
│   ├── scripts/
│   │   └── sqoop.sh                          # Script de comandos Sqoop
│   └── README.md
├── ejercicio-5-practica-sqoop-nifi/          # Práctica completa Sqoop + NiFi
│   ├── practica-sqoop/                       # Ejercicios de Sqoop
│   │   ├── scripts/
│   │   │   └── sqoop-exercises.sh            # Script completo de Sqoop
│   │   ├── ejercicios-resueltos.md           # Resultados de ejercicios
│   │   └── README.md
│   ├── practica-nifi/                        # Ejercicios de NiFi
│   │   ├── nifi-flow-diagram.md              # Explicación del flujo
│   │   └── README.md
│   ├── images/                               # Diagramas de flujo
│   └── README.md
├── ejercicio-6-practica-ingest-gcp/          # Práctica de ingesta en GCP
│   ├── scripts/
│   │   ├── upload_csvs.sh                    # Script de subida a GCS
│   │   └── README.md
│   ├── images/                               # Capturas de buckets y transfer
│   │   ├── bucket-multiregional-us.jpg
│   │   ├── bucket-regional-finlandia.jpg
│   │   └── storage-transfer-service.jpg
│   ├── ejercicios-resueltos.md               # Resultados de ejercicios
│   └── README.md
├── ejercicio-7-practica-nifi-spark/          # Práctica NiFi + Spark
│   ├── scripts/
│   │   ├── download_parquet.sh               # Script de descarga
│   │   └── README.md
│   ├── nifi/
│   │   ├── nifi-flow-guide.md                # Guía del flujo NiFi
│   │   └── README.md
│   ├── spark/
│   │   ├── spark-analysis.md                 # Análisis con PySpark
│   │   └── README.md
│   ├── images/                               # Capturas de flujo NiFi
│   │   └── nifi-process.jpg
│   ├── ejercicios-resueltos.md               # Resultados completos
│   └── README.md
├── ejercicio-8-practica-airflow-hive-spark/  # Práctica Airflow + Hive + Spark
│   ├── scripts/
│   │   ├── download_and_ingest.sh            # Script de descarga e ingesta
│   │   ├── process_airport_trips.py          # Procesamiento con Spark
│   │   └── README.md
│   ├── airflow/
│   │   ├── airport_trips_processing.py       # DAG de Airflow
│   │   └── README.md
│   ├── hive/
│   │   ├── hive-setup.sql                    # Scripts SQL de Hive
│   │   └── README.md
│   ├── images/                               # Capturas de pantalla
│   │   ├── ejercicio1-create-tripdata.jpg
│   │   ├── ejercicio2-describe-airporttrips.jpg
│   │   ├── ejercicio5-airflow.jpg
│   │   └── README.md
│   ├── ejercicios-resueltos.md               # Resultados completos
│   └── README.md
└── README.md                                 # Este archivo
```

---

## 🚀 Ejercicios Incluidos

### 1️⃣ **Ejercicio 3: Ingesta Local con Hadoop**

**Descripción:** Descarga un archivo CSV desde GitHub, lo mueve a HDFS y limpia archivos temporales.

**Características:**
- ✅ Descarga automática desde GitHub
- ✅ Gestión de directorios temporales
- ✅ Subida a HDFS
- ✅ Limpieza automática de archivos

**Archivo:** `ejercicio-3-practica-de-ingest-local/scripts/landing.sh`

### 2️⃣ **Ejercicio 4: Ingesta con Sqoop**

**Descripción:** Conecta PostgreSQL con Hadoop usando Sqoop para importar datos.

**Características:**
- ✅ Conexión JDBC con PostgreSQL
- ✅ Listado de tablas
- ✅ Consultas SQL directas
- ✅ Importación completa y filtrada
- ✅ Formato Parquet

**Archivo:** `ejercicio-4-practica-ingest-sqoop/scripts/sqoop.sh`

### 3️⃣ **Ejercicio 5: Práctica Completa Sqoop + NiFi**

**Descripción:** Práctica integral que combina Sqoop para ingesta de datos y NiFi para procesamiento de flujos de datos.

**Características:**
- ✅ **Sqoop**: 4 ejercicios completos con resultados reales
- ✅ **NiFi**: Configuración y flujo de procesamiento
- ✅ **Scripts automatizados**: Comandos listos para ejecutar
- ✅ **Documentación detallada**: Guías paso a paso
- ✅ **Diagramas visuales**: Flujos de NiFi explicados

**Archivos principales:**
- `ejercicio-5-practica-sqoop-nifi/practica-sqoop/scripts/sqoop-exercises.sh`
- `ejercicio-5-practica-sqoop-nifi/practica-nifi/README.md`
- `ejercicio-5-practica-sqoop-nifi/images/nifi-flow-diagram.jpg`

### 4️⃣ **Ejercicio 6: Práctica Ingest GCP**

**Descripción:** Práctica de ingesta de datos en Google Cloud Platform utilizando Google Cloud Storage y Storage Transfer Service.

**Características:**
- ✅ **Buckets GCP**: Creación de buckets regionales y multiregionales
- ✅ **gsutil CLI**: Subida automatizada de archivos CSV
- ✅ **Storage Transfer**: Migración entre buckets
- ✅ **Scripts automatizados**: Procesos de subida masiva
- ✅ **Capturas visuales**: Evidencia de resultados

**Archivos principales:**
- `ejercicio-6-practica-ingest-gcp/scripts/upload_csvs.sh`
- `ejercicio-6-practica-ingest-gcp/ejercicios-resueltos.md`
- `ejercicio-6-practica-ingest-gcp/images/` (capturas de pantalla)

### 5️⃣ **Ejercicio 7: Práctica NiFi + Spark**

**Descripción:** Práctica integral que combina Apache NiFi para procesamiento de flujos de datos y Apache Spark para análisis de datos, utilizando un dataset real de taxis de NYC.

**Características:**
- ✅ **NiFi**: Flujo de procesamiento con GetFile y PutHDFS
- ✅ **Spark**: Análisis de datos con PySpark y SQL
- ✅ **Dataset real**: Datos de taxis amarillos de NYC
- ✅ **Scripts automatizados**: Descarga y procesamiento
- ✅ **6 consultas de análisis**: Insights de negocio

**Archivos principales:**
- `ejercicio-7-practica-nifi-spark/scripts/download_parquet.sh`
- `ejercicio-7-practica-nifi-spark/nifi/nifi-flow-guide.md`
- `ejercicio-7-practica-nifi-spark/spark/spark-analysis.md`
- `ejercicio-7-practica-nifi-spark/ejercicios-resueltos.md`

### 6️⃣ **Ejercicio 8: Práctica Airflow + Hive + Spark**

**Descripción:** Práctica integral que integra Apache Airflow para orquestación de workflows, Apache Hive para almacenamiento de datos estructurados y Apache Spark para procesamiento distribuido, utilizando datos reales de taxis de Nueva York.

**Características:**
- ✅ **Hive**: Base de datos y tabla externa con formato Parquet
- ✅ **Spark**: Procesamiento distribuido con filtros específicos
- ✅ **Airflow**: Orquestación completa del pipeline ETL
- ✅ **Dataset real**: NYC Taxi Data (2.7M registros)
- ✅ **Pipeline automatizado**: Descarga → Procesamiento → Verificación
- ✅ **Filtros específicos**: Aeropuertos + pago en efectivo

**Archivos principales:**
- `ejercicio-8-practica-airflow-hive-spark/scripts/download_and_ingest.sh`
- `ejercicio-8-practica-airflow-hive-spark/scripts/process_airport_trips.py`
- `ejercicio-8-practica-airflow-hive-spark/airflow/airport_trips_processing.py`
- `ejercicio-8-practica-airflow-hive-spark/hive/hive-setup.sql`
- `ejercicio-8-practica-airflow-hive-spark/ejercicios-resueltos.md`

---

## 🔧 Requisitos Previos

### Entorno de Desarrollo
- **Docker** con contenedores de Hadoop y PostgreSQL
- **Bash** para ejecutar scripts
- Acceso a terminal del contenedor Hadoop

### Contenedores Necesarios
```bash
# Contenedor Hadoop
docker exec -it edvai_hadoop bash
su hadoop

# Verificar PostgreSQL
docker inspect edvai_postgres
```

---

## 📋 Cómo Ejecutar

### Ejercicio 3: Ingesta Local
```bash
# 1. Navegar al directorio
cd ejercicio-3-practica-de-ingest-local/scripts/

# 2. Dar permisos de ejecución
chmod +x landing.sh

# 3. Ejecutar el script
./landing.sh

# 4. Verificar en HDFS
hdfs dfs -ls /ingest
```

### Ejercicio 4: Ingesta con Sqoop
```bash
# 1. Navegar al directorio
cd ejercicio-4-practica-ingest-sqoop/scripts/

# 2. Dar permisos de ejecución
chmod +x sqoop.sh

# 3. Ejecutar el script
./sqoop.sh
```

### Ejercicio 5: Práctica Completa Sqoop + NiFi
```bash
# 1. Ejecutar ejercicios de Sqoop
cd ejercicio-5-practica-sqoop-nifi/practica-sqoop/scripts/
chmod +x sqoop-exercises.sh
./sqoop-exercises.sh

# 2. Configurar NiFi (ver documentación)
cd ../../practica-nifi/
# Seguir guía en README.md para configuración de NiFi
```

### Ejercicio 6: Práctica Ingest GCP
```bash
# 1. Ejecutar script de subida de archivos
cd ejercicio-6-practica-ingest-gcp/scripts/
chmod +x upload_csvs.sh
./upload_csvs.sh

# 2. Verificar archivos en buckets
gsutil ls gs://data-bucket-demo-1/
gsutil ls gs://demo-bucket-edvai/

# 3. Ver documentación completa
cd ../
# Revisar README.md y ejercicios-resueltos.md
```

### Ejercicio 7: Práctica NiFi + Spark
```bash
# 1. Ejecutar script de descarga
cd ejercicio-7-practica-nifi-spark/scripts/
chmod +x download_parquet.sh
./download_parquet.sh

# 2. Configurar flujo en NiFi (ver documentación)
cd ../nifi/
# Seguir guía en nifi-flow-guide.md

# 3. Ejecutar análisis con Spark
cd ../spark/
# Seguir guía en spark-analysis.md

# 4. Ver resultados completos
cd ../
# Revisar ejercicios-resueltos.md
```

### Ejercicio 8: Práctica Airflow + Hive + Spark
```bash
# 1. Configurar Hive (base de datos y tabla)
cd ejercicio-8-practica-airflow-hive-spark/hive/
# Seguir guía en README.md para configuración de Hive

# 2. Ejecutar scripts de procesamiento
cd ../scripts/
chmod +x download_and_ingest.sh
chmod +x process_airport_trips.py
./download_and_ingest.sh
spark-submit process_airport_trips.py

# 3. Configurar DAG de Airflow
cd ../airflow/
# Copiar airport_trips_processing.py a /home/hadoop/airflow/dags/

# 4. Ejecutar DAG en Airflow
# Acceder a interfaz web de Airflow y ejecutar DAG manualmente

# 5. Ver resultados completos
cd ../
# Revisar ejercicios-resueltos.md
```

---

## 📊 Datos Utilizados

### Ejercicio 3
- **Fuente:** [starwars.csv](https://github.com/fpineyro/homework-0/blob/master/starwars.csv)
- **Destino:** `/ingest/` en HDFS
- **Formato:** CSV

### Ejercicio 4
- **Fuente:** Base de datos Northwind (PostgreSQL)
- **Tabla:** `region`
- **Destino:** `/sqoop/ingest/` en HDFS
- **Formato:** Parquet

### Ejercicio 5
- **Sqoop**: Base de datos Northwind (PostgreSQL)
  - **Tablas:** `orders`, `products`, `customers`
  - **Destino:** `/sqoop/ingest/` en HDFS
  - **Formato:** Parquet
- **NiFi**: Archivo `starwars.csv`
  - **Procesamiento:** CSV → Avro
  - **Destino:** `/nifi/` en HDFS
  - **Formato:** Avro

### Ejercicio 6
- **GCP Storage**: Archivos CSV locales
  - **Fuente**: Directorio local con 5 archivos CSV
  - **Destino**: `gs://data-bucket-demo-1/` (US multiregional)
  - **Formato:** CSV
- **Storage Transfer**: Migración entre buckets
  - **Origen**: `gs://data-bucket-demo-1/`
  - **Destino**: `gs://demo-bucket-edvai/` (Finlandia regional)
  - **Formato:** CSV

### Ejercicio 7
- **NiFi**: Archivo Parquet de NYC Taxi Data
  - **Fuente**: S3 (https://data-engineer-edvai-public.s3.amazonaws.com/)
  - **Procesamiento**: GetFile → PutHDFS
  - **Destino**: `/nifi/` en HDFS
  - **Formato:** Parquet
- **Spark**: Análisis de datos
  - **Fuente**: HDFS `/nifi/yellow_tripdata_2021-01.parquet`
  - **Procesamiento**: PySpark + SQL
  - **Resultados**: 6 consultas de análisis
  - **Formato:** Parquet

### Ejercicio 8
- **Hive**: Base de datos y tabla externa
  - **Base de datos**: `tripdata`
  - **Tabla**: `airport_trips` (EXTERNAL TABLE)
  - **Formato**: Parquet
  - **Ubicación**: `/user/hive/warehouse/tripdata.db/airport_trips`
- **Spark**: Procesamiento de datos NYC Taxi
  - **Fuente**: HDFS `/user/hadoop/tripdata/raw/` (2 archivos Parquet)
  - **Procesamiento**: PySpark con filtros específicos
  - **Filtros**: Aeropuertos + pago en efectivo (payment_type = 2)
  - **Resultado**: 1 registro filtrado e insertado
  - **Formato:** Parquet
- **Airflow**: Orquestación del pipeline
  - **DAG**: `airport_trips_processing`
  - **Tareas**: Descarga → Procesamiento → Verificación
  - **Resultado**: Pipeline automatizado completo

---

## 🛠️ Tecnologías Utilizadas

- **Hadoop** - Framework de procesamiento distribuido
- **HDFS** - Sistema de archivos distribuido
- **Sqoop** - Herramienta de transferencia de datos
- **NiFi** - Procesamiento de flujos de datos
- **Apache Spark** - Motor de procesamiento distribuido
- **PySpark** - API de Python para Spark
- **Apache Airflow** - Orquestación de workflows
- **Apache Hive** - Data warehouse y consultas SQL
- **Google Cloud Storage** - Almacenamiento de objetos en la nube
- **gsutil** - Herramienta CLI de Google Cloud
- **Storage Transfer Service** - Migración de datos en GCP
- **PostgreSQL** - Base de datos relacional
- **Bash** - Scripting y automatización
- **Docker** - Contenedores
- **Parquet** - Formato de datos columnar
- **Avro** - Formato de serialización de datos
- **SQL** - Consultas estructuradas

---

## 📝 Notas Importantes

- Los scripts incluyen manejo de errores y mensajes informativos
- Se realizan limpiezas automáticas de archivos temporales
- Los directorios se crean automáticamente si no existen
- Las conexiones JDBC requieren configuración de red entre contenedores
- NiFi requiere configuración adicional de librerías HDFS para versiones 2.0+
- Los ejercicios incluyen resultados reales y métricas de rendimiento
- GCP requiere autenticación y configuración de proyecto
- Storage Transfer Service permite migración eficiente entre buckets
- Los buckets regionales optimizan latencia, los multiregionales optimizan disponibilidad
- Spark requiere configuración de memoria y paralelismo para optimizar rendimiento
- Los archivos Parquet ofrecen mejor compresión y rendimiento que CSV
- Las consultas SQL en Spark permiten análisis eficiente de grandes volúmenes de datos
- Airflow requiere configuración de DAGs y monitoreo de tareas
- Hive necesita configuración de metastore y permisos de HDFS
- Los DAGs de Airflow permiten orquestación compleja de pipelines ETL
- Las tablas externas en Hive facilitan la integración con Spark
- Los filtros específicos en Spark optimizan el procesamiento de grandes datasets

---

## 👨‍💻 Autor

**Enzo** - Prácticas de Data Engineering

---

## 📚 Recursos Adicionales

- [Documentación de Hadoop](https://hadoop.apache.org/docs/)
- [Guía de Sqoop](https://sqoop.apache.org/docs/)
- [Docker para Data Engineering](https://docs.docker.com/)