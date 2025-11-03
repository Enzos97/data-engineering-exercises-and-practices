# Scripts - Ejercicio 9: Formula 1

Esta carpeta contiene los scripts necesarios para automatizar el pipeline de procesamiento de datos de Formula 1.

## 📁 Archivos Incluidos

### 1️⃣ **f1_download_and_ingest.sh**
Script de bash para descarga e ingesta automática de archivos CSV de Formula 1.

**Funcionalidades:**
- ✅ Verificación de servicios HDFS
- ✅ Descarga de 4 archivos CSV desde URLs públicas de S3
- ✅ Validación de conectividad
- ✅ Subida automática a HDFS
- ✅ Limpieza de archivos temporales
- ✅ Logging detallado del proceso

**Archivos descargados:**
- `results.csv` - Resultados de carreras
- `drivers.csv` - Información de corredores
- `constructors.csv` - Información de constructores
- `races.csv` - Información de carreras

**Uso:**
```bash
chmod +x f1_download_and_ingest.sh
./f1_download_and_ingest.sh
```

**Ubicación HDFS resultante:**
```
/user/hadoop/f1/raw/
├── results.csv
├── drivers.csv
├── constructors.csv
└── races.csv
```

### 2️⃣ **process_f1_data.py**
Script de Python para procesamiento de datos con Spark.

**Funcionalidades:**
- ✅ Lectura de archivos CSV desde HDFS (results, drivers, constructors, races)
- ✅ JOIN entre tablas para relacionar datos
- ✅ Punto 4a: Encuentra corredores con mayor cantidad de puntos en la historia
- ✅ Punto 4b: Encuentra constructores con más puntos en Spanish Grand Prix 1991
- ✅ Generación de archivos CSV para tablas externas de Hive
- ✅ Estadísticas y validaciones de datos
- ✅ Guardado en ubicaciones HDFS correctas para tablas externas

**Uso:**
```bash
spark-submit process_f1_data.py
```

**Procesamiento realizado:**
1. Lee 4 archivos CSV desde `/user/hadoop/f1/raw/`
2. **Punto 4a**: JOIN results + drivers → Agrupa por corredor → Suma puntos → Ordena descendente
3. **Punto 4b**: JOIN results + constructors + races → Filtra Spanish GP 1991 → Agrupa por constructor → Suma puntos
4. Guarda resultados en CSV en ubicaciones de tablas externas

## 🔧 Configuración Requerida

### Variables de Entorno
```bash
export HADOOP_HOME=/home/hadoop/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```

### Servicios Necesarios
- **HDFS**: NameNode y DataNode ejecutándose
- **Hive**: Metastore configurado con base de datos `f1`
- **Spark**: Disponible en el PATH
- **Internet**: Para descarga de archivos desde S3

## 📊 URLs de Datos

Todos los archivos están disponibles en el bucket S3 público:

- **results.csv**: `https://data-engineer-edvai-public.s3.amazonaws.com/results.csv`
- **drivers.csv**: `https://data-engineer-edvai-public.s3.amazonaws.com/drivers.csv`
- **constructors.csv**: `https://data-engineer-edvai-public.s3.amazonaws.com/constructors.csv`
- **races.csv**: `https://data-engineer-edvai-public.s3.amazonaws.com/races.csv`

## 🎯 Resultados Esperados

### Descarga e Ingesta
- **Archivos descargados**: 4 archivos CSV
- **Ubicación HDFS**: `/user/hadoop/f1/raw/`
- **Tiempo estimado**: 1-3 minutos (dependiendo de la velocidad de conexión)

### Procesamiento Spark (Punto 4)
- **Archivos leídos**: 4 archivos CSV (results, drivers, constructors, races)
- **Resultado final**: 
  - Archivo CSV con todos los corredores ordenados por puntos totales (punto 4a)
  - Archivo CSV con constructores de Spanish Grand Prix 1991 ordenados por puntos (punto 4b)
- **Ubicación HDFS destino**: 
  - `/user/hive/warehouse/f1.db/driver_results/` (para tabla externa driver_results)
  - `/user/hive/warehouse/f1.db/constructor_results/` (para tabla externa constructor_results)
- **Formato**: CSV con headers

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
wget --spider https://data-engineer-edvai-public.s3.amazonaws.com/results.csv
```

### Error: "Error creando directorio HDFS"
```bash
# Verificar permisos y estado de HDFS
hdfs dfs -ls /
hdfs dfs -mkdir -p /user/hadoop/f1/raw
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
- 📊 Métricas de rendimiento (tamaños de archivos, conteos)
- ❌ Errores específicos con códigos de salida
- 📅 Timestamps de inicio y finalización

## 🔄 Integración con Airflow

Estos scripts están diseñados para ser ejecutados como tareas de Airflow:
- **BashOperator**: Para `f1_download_and_ingest.sh`
- **BashOperator**: Para `process_f1_data.py`
- **Dependencias**: Secuenciales con validaciones

## 📋 Estructura de Datos

### results.csv
Contiene información de resultados de carreras individuales:
- resultId, raceId, driverId, constructorId, points, etc.

### drivers.csv
Contiene información de los corredores:
- driverId, driverRef, number, code, forename, surname, nationality, etc.

### constructors.csv
Contiene información de los constructores:
- constructorId, constructorRef, name, nationality, url

### races.csv
Contiene información de las carreras:
- raceId, year, round, circuitId, name, date, time, url

## 🔗 Referencias

- **Diccionario de datos**: [Kaggle - Formula 1 Dataset](https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020)

