# Scripts - Ejercicio 8

Esta carpeta contiene los scripts necesarios para automatizar el pipeline de procesamiento de datos NYC Taxi.

## 📁 Archivos Incluidos

### 1️⃣ **download_and_ingest.sh**
Script de bash para descarga e ingesta automática de archivos Parquet.

**Funcionalidades:**
- ✅ Verificación de servicios HDFS
- ✅ Descarga de archivos desde URLs públicas
- ✅ Validación de conectividad
- ✅ Subida automática a HDFS
- ✅ Limpieza de archivos temporales
- ✅ Logging detallado del proceso

**Uso:**
```bash
chmod +x download_and_ingest.sh
./download_and_ingest.sh
```

### 2️⃣ **process_airport_trips.py**
Script de Python para procesamiento de datos con Spark.

**Funcionalidades:**
- ✅ Lectura de archivos Parquet desde HDFS
- ✅ Unión de datasets de enero y febrero 2021
- ✅ Filtrado de viajes a aeropuertos pagados en efectivo
- ✅ Inserción de resultados en tabla Hive
- ✅ Estadísticas y validaciones de datos

**Uso:**
```bash
spark-submit process_airport_trips.py
```

## 🔧 Configuración Requerida

### Variables de Entorno
```bash
export HADOOP_HOME=/home/hadoop/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```

### Servicios Necesarios
- **HDFS**: NameNode y DataNode ejecutándose
- **Hive**: Metastore configurado
- **Spark**: Disponible en el PATH
- **Internet**: Para descarga de archivos

## 📊 URLs de Datos

- **Enero 2021**: `https://data-engineer-edvai-public.s3.amazonaws.com/yellow_tripdata_2021-01.parquet`
- **Febrero 2021**: `https://data-engineer-edvai-public.s3.amazonaws.com/yellow_tripdata_2021-02.parquet`

## 🎯 Resultados Esperados

### Descarga e Ingesta
- **Archivos descargados**: 2 archivos Parquet (~41.5 MB total)
- **Ubicación HDFS**: `/user/hadoop/tripdata/raw/`
- **Tiempo estimado**: 30-60 segundos

### Procesamiento Spark
- **Registros procesados**: ~2.7 millones
- **Filtros aplicados**: Viajes a aeropuertos + pago efectivo
- **Resultado final**: 1 registro insertado en Hive
- **Tiempo estimado**: 1-2 minutos

## 🚨 Troubleshooting

### Error: "Servicios HDFS no detectados"
```bash
# Verificar servicios
jps | grep -E "NameNode|DataNode"

# Iniciar servicios si es necesario
start-dfs.sh
```

### Error: "No hay conexión a internet"
```bash
# Verificar conectividad
ping google.com
wget --spider https://data-engineer-edvai-public.s3.amazonaws.com/yellow_tripdata_2021-01.parquet
```

### Error: "Spark session failed"
```bash
# Verificar configuración de Spark
spark-submit --version
# Verificar configuración de Hive
hive --version
```

## 📝 Logs y Monitoreo

Los scripts incluyen logging detallado que muestra:
- ✅ Estado de cada paso del proceso
- 📊 Métricas de rendimiento
- ❌ Errores específicos con códigos de salida
- 📅 Timestamps de inicio y finalización

## 🔄 Integración con Airflow

Estos scripts están diseñados para ser ejecutados como tareas de Airflow:
- **BashOperator**: Para `download_and_ingest.sh`
- **BashOperator**: Para `process_airport_trips.py`
- **Dependencias**: Secuenciales con validaciones
