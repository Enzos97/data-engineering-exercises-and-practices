# Airflow - Ejercicio 8

Esta carpeta contiene la configuración y documentación del DAG de Apache Airflow para orquestar el pipeline de procesamiento de datos NYC Taxi.

## 📁 Archivos Incluidos

### 1️⃣ **airport_trips_processing.py**
DAG principal de Airflow que orquesta todo el pipeline de procesamiento.

## 🎯 Configuración del DAG

### Información Básica
- **DAG ID**: `airport_trips_processing`
- **Descripción**: "Orquesta la descarga, ingestión y procesamiento de datos NYC Taxi"
- **Propietario**: `hadoop`
- **Programación**: Manual (sin schedule)
- **Tags**: `['spark', 'hive', 'etl']`

### Argumentos por Defecto
```python
default_args = {
    'owner': 'hadoop',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}
```

## 🔄 Tareas del DAG

### 1️⃣ **inicio** (DummyOperator)
- **Tipo**: DummyOperator
- **Propósito**: Marca el inicio del pipeline
- **Dependencias**: Ninguna

### 2️⃣ **ingesta_datos** (BashOperator)
- **Tipo**: BashOperator
- **Comando**: `bash -c 'bash /home/hadoop/scripts/download_and_ingest.sh'`
- **Propósito**: Descarga archivos Parquet e ingesta en HDFS
- **Dependencias**: `inicio`

### 3️⃣ **procesa_spark** (BashOperator)
- **Tipo**: BashOperator
- **Comando**: `bash -c 'spark-submit /home/hadoop/scripts/process_airport_trips.py'`
- **Propósito**: Procesa datos con Spark y filtra viajes
- **Dependencias**: `ingesta_datos`

### 4️⃣ **verifica_tabla_hive** (BashOperator)
- **Tipo**: BashOperator
- **Comando**: `bash -c 'beeline -u jdbc:hive2://localhost:10000 -e "USE tripdata; SELECT COUNT(*) AS total FROM airport_trips;"'`
- **Propósito**: Verifica que los datos se insertaron correctamente
- **Dependencias**: `procesa_spark`

### 5️⃣ **fin_proceso** (DummyOperator)
- **Tipo**: DummyOperator
- **Propósito**: Marca el final del pipeline
- **Dependencias**: `verifica_tabla_hive`

## 🔗 Flujo de Dependencias

```
inicio → ingesta_datos → procesa_spark → verifica_tabla_hive → fin_proceso
```

## 🚀 Instalación y Configuración

### 1. Copiar DAG a la carpeta de Airflow
```bash
cp airport_trips_processing.py /home/hadoop/airflow/dags/
```

### 2. Verificar permisos
```bash
chmod +x /home/hadoop/airflow/dags/airport_trips_processing.py
```

### 3. Reiniciar Airflow (si es necesario)
```bash
# Reiniciar scheduler
airflow scheduler --daemon

# Reiniciar webserver
airflow webserver --daemon
```

## 📊 Monitoreo del DAG

### Vista de Grafo
- Muestra el flujo secuencial de tareas
- Indica el estado de cada tarea (SUCCESS, FAILED, RUNNING)
- Permite ver logs individuales de cada tarea

### Métricas de Ejecución
- **Tiempo total**: ~13 minutos
- **Tareas exitosas**: 5/5
- **Registros procesados**: 2,741,478
- **Resultado final**: 1 registro insertado

## 🔍 Logs y Debugging

### Acceso a Logs
1. Ir a la interfaz web de Airflow
2. Seleccionar el DAG `airport_trips_processing`
3. Hacer clic en la tarea específica
4. Ver logs detallados de ejecución

### Logs Importantes
- **ingesta_datos**: Logs de descarga y subida a HDFS
- **procesa_spark**: Logs de procesamiento con Spark
- **verifica_tabla_hive**: Resultado de la consulta de verificación

## ⚠️ Troubleshooting

### Error: "Script not found"
```bash
# Verificar que los scripts existen
ls -la /home/hadoop/scripts/
# Verificar permisos
chmod +x /home/hadoop/scripts/*.sh
chmod +x /home/hadoop/scripts/*.py
```

### Error: "Hive connection failed"
```bash
# Verificar que Hive está ejecutándose
jps | grep HiveServer2
# Verificar conectividad
beeline -u jdbc:hive2://localhost:10000
```

### Error: "Spark job failed"
```bash
# Verificar configuración de Spark
spark-submit --version
# Verificar logs de Spark
tail -f /home/hadoop/spark/logs/spark-*.log
```

## 📈 Métricas de Rendimiento

### Tiempos de Ejecución
- **inicio**: ~1 segundo
- **ingesta_datos**: ~2 minutos
- **procesa_spark**: ~2 minutos
- **verifica_tabla_hive**: ~10 segundos
- **fin_proceso**: ~1 segundo

### Recursos Utilizados
- **CPU**: Moderado durante procesamiento Spark
- **Memoria**: ~2-4 GB durante procesamiento
- **Red**: Descarga de ~41.5 MB de datos
- **Almacenamiento**: ~41.5 MB en HDFS

## 🎯 Resultados Esperados

Al ejecutar el DAG exitosamente, deberías ver:

1. ✅ **Todas las tareas en estado SUCCESS**
2. ✅ **2 archivos Parquet descargados y procesados**
3. ✅ **1 registro filtrado e insertado en Hive**
4. ✅ **Verificación exitosa con beeline**
5. ✅ **Pipeline completo automatizado**

## 🔄 Automatización Adicional

### Programación Automática
Para ejecutar el DAG automáticamente, modificar:
```python
schedule_interval='@daily',  # Ejecutar diariamente
# o
schedule_interval='0 2 * * *',  # Ejecutar a las 2 AM todos los días
```

### Notificaciones
Para agregar notificaciones por email:
```python
default_args = {
    'email_on_failure': True,
    'email_on_retry': True,
    'email': ['admin@company.com'],
}
```
