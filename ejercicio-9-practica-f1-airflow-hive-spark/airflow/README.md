# Airflow - Ejercicio 9: Formula 1

Esta carpeta contiene la configuración y documentación del DAG de Apache Airflow para orquestar el pipeline de procesamiento de datos de Formula 1.

## 📁 Archivos Incluidos

### 1️⃣ **f1_processing.py**
DAG principal de Airflow que orquesta todo el pipeline de procesamiento de datos F1.

## 🎯 Configuración del DAG

### Información Básica
- **DAG ID**: `f1_processing`
- **Descripción**: "Orquesta la descarga, ingestión y procesamiento de datos de Formula 1"
- **Propietario**: `hadoop`
- **Programación**: Manual (sin schedule)
- **Tags**: `['spark', 'hive', 'etl', 'f1']`

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

### 2️⃣ **ingesta_datos_f1** (BashOperator)
- **Tipo**: BashOperator
- **Comando**: `bash -c 'bash /home/hadoop/scripts/f1_download_and_ingest.sh'`
- **Propósito**: Descarga archivos CSV de Formula 1 e ingesta en HDFS
- **Dependencias**: `inicio`

### 3️⃣ **procesa_spark_f1** (BashOperator)
- **Tipo**: BashOperator
- **Comando**: `bash -c 'spark-submit /home/hadoop/scripts/process_f1_data.py'`
- **Propósito**: Procesa datos con Spark y genera resultados para tablas Hive
- **Dependencias**: `ingesta_datos_f1`

### 4️⃣ **verifica_driver_results** (BashOperator)
- **Tipo**: BashOperator
- **Comando**: `beeline -u jdbc:hive2://localhost:10000 -e "USE f1; SELECT COUNT(*) AS total_drivers FROM driver_results;"`
- **Propósito**: Verifica que los datos de corredores se procesaron correctamente
- **Dependencias**: `procesa_spark_f1`

### 5️⃣ **verifica_constructor_results** (BashOperator)
- **Tipo**: BashOperator
- **Comando**: `beeline -u jdbc:hive2://localhost:10000 -e "USE f1; SELECT COUNT(*) AS total_constructors FROM constructor_results;"`
- **Propósito**: Verifica que los datos de constructores se procesaron correctamente
- **Dependencias**: `verifica_driver_results`

### 6️⃣ **fin_proceso** (DummyOperator)
- **Tipo**: DummyOperator
- **Propósito**: Marca el final del pipeline
- **Dependencias**: `verifica_constructor_results`

## 🔗 Flujo de Dependencias

```
inicio → ingesta_datos_f1 → procesa_spark_f1 → verifica_driver_results → verifica_constructor_results → fin_proceso
```

## 🚀 Instalación y Configuración

### 1. Copiar DAG a la carpeta de Airflow
```bash
cp f1_processing.py /home/hadoop/airflow/dags/
```

### 2. Verificar permisos
```bash
chmod +x /home/hadoop/airflow/dags/f1_processing.py
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
- **Tiempo total estimado**: ~5-10 minutos
- **Tareas totales**: 6
- **Archivos procesados**: 4 CSV (results, drivers, constructors, races)

## 🔍 Logs y Debugging

### Acceso a Logs
1. Ir a la interfaz web de Airflow
2. Seleccionar el DAG `f1_processing`
3. Hacer clic en la tarea específica
4. Ver logs detallados de ejecución

### Logs Importantes
- **ingesta_datos_f1**: Logs de descarga y subida a HDFS de 4 archivos CSV
- **procesa_spark_f1**: Logs de procesamiento con Spark (JOINs, agrupaciones, filtros)
- **verifica_driver_results**: Resultado de conteo de corredores
- **verifica_constructor_results**: Resultado de conteo de constructores

## ⚠️ Troubleshooting

### Error: "Script not found"
```bash
# Verificar que los scripts existen
ls -la /home/hadoop/scripts/f1_download_and_ingest.sh
ls -la /home/hadoop/scripts/process_f1_data.py

# Verificar permisos
chmod +x /home/hadoop/scripts/f1_download_and_ingest.sh
chmod +x /home/hadoop/scripts/process_f1_data.py
```

### Error: "Hive connection failed"
```bash
# Verificar que Hive está ejecutándose
jps | grep HiveServer2

# Verificar conectividad
beeline -u jdbc:hive2://localhost:10000

# Verificar que la base de datos f1 existe
beeline -u jdbc:hive2://localhost:10000 -e "SHOW DATABASES;"
```

### Error: "Spark job failed"
```bash
# Verificar configuración de Spark
spark-submit --version

# Verificar logs de Spark
tail -f /home/hadoop/spark/logs/spark-*.log

# Verificar que los archivos CSV están en HDFS
hdfs dfs -ls /user/hadoop/f1/raw/
```

### Error: "Tabla no encontrada en Hive"
```bash
# Verificar que las tablas externas existen
beeline -u jdbc:hive2://localhost:10000 -e "USE f1; SHOW TABLES;"

# Verificar esquemas de las tablas
beeline -u jdbc:hive2://localhost:10000 -e "USE f1; DESCRIBE driver_results;"
beeline -u jdbc:hive2://localhost:10000 -e "USE f1; DESCRIBE constructor_results;"
```

## 📈 Métricas de Rendimiento

### Tiempos de Ejecución Estimados
- **inicio**: ~1 segundo
- **ingesta_datos_f1**: ~1-3 minutos (dependiendo de velocidad de conexión)
- **procesa_spark_f1**: ~2-5 minutos (dependiendo del tamaño de datos)
- **verifica_driver_results**: ~10 segundos
- **verifica_constructor_results**: ~10 segundos
- **fin_proceso**: ~1 segundo

### Recursos Utilizados
- **CPU**: Moderado durante procesamiento Spark
- **Memoria**: ~2-4 GB durante procesamiento
- **Red**: Descarga de archivos CSV desde S3
- **Almacenamiento**: Archivos CSV en HDFS

## 🎯 Resultados Esperados

Al ejecutar el DAG exitosamente, deberías ver:

1. ✅ **Todas las tareas en estado SUCCESS**
2. ✅ **4 archivos CSV descargados y procesados**
3. ✅ **Datos procesados en tablas externas de Hive:**
   - `driver_results`: Corredores con mayor cantidad de puntos
   - `constructor_results`: Constructores en Spanish Grand Prix 1991
4. ✅ **Verificación exitosa con beeline mostrando conteos**
5. ✅ **Pipeline completo automatizado**

## 📋 Consultas de Verificación

Después de ejecutar el DAG, puedes verificar los resultados manualmente:

### Verificar driver_results
```sql
USE f1;
SELECT * FROM driver_results ORDER BY points DESC LIMIT 10;
```

### Verificar constructor_results
```sql
USE f1;
SELECT * FROM constructor_results ORDER BY points DESC;
```

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

## 📸 Capturas de Pantalla

Después de ejecutar el DAG, captura:
1. **Vista del DAG** en Airflow mostrando todas las tareas en SUCCESS
2. **Resultados en Hive** mostrando los conteos y datos de las tablas

## 🔗 Referencias

- **Documentación de scripts**: `../scripts/README.md`
- **Configuración de Hive**: `../hive/README.md`
- **Diccionario de datos F1**: [Kaggle - Formula 1 Dataset](https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020)

