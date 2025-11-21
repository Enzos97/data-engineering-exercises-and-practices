# 🚀 Guía de Instalación y Ejecución - Ejercicio 11

Esta guía proporciona instrucciones paso a paso para instalar, configurar y ejecutar el pipeline completo del Ejercicio 11 - Titanic con NiFi + Airflow + Hive.

## 📋 Requisitos Previos

### Contenedores Docker
- ✅ Contenedor Hadoop (`edvai_hadoop`)
- ✅ Contenedor NiFi (`nifi`)
- ✅ Ambos contenedores en la misma red Docker

### Software Instalado
- ✅ Apache Hadoop con HDFS
- ✅ Apache Hive con metastore
- ✅ Apache Airflow
- ✅ Apache NiFi
- ✅ Python 3 con Pandas

### Verificación de Requisitos

```bash
# Verificar contenedores
docker ps | grep -E 'hadoop|nifi'

# Verificar servicios en Hadoop
docker exec -it edvai_hadoop bash
jps  # Debe mostrar NameNode, DataNode, ResourceManager, etc.

# Verificar Python y Pandas
python3 --version
python3 -c "import pandas; print(pandas.__version__)"

# Verificar Hive
hive --version

# Verificar Airflow
airflow version

# Verificar NiFi (acceder a https://localhost:8443/nifi)
```

## 🏗️ Arquitectura del Pipeline

```
┌─────────────┐
│   AWS S3    │ ← wget
│ titanic.csv │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│           Contenedor NiFi               │
│  /home/nifi/ingest → /home/nifi/bucket  │
│           GetFile → PutFile             │
│           GetFile → PutHDFS             │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│              HDFS                       │
│         /nifi/titanic.csv               │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│       Airflow + Pandas                  │
│  Transformaciones:                      │
│  - Remover SibSp, Parch                 │
│  - Rellenar edad con promedio           │
│  - Cabin nulo → 0                       │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│              Hive                       │
│    titanic_db.titanic_processed         │
└─────────────────────────────────────────┘
```

## 📂 Paso 1: Preparar Estructura de Directorios

### En el Contenedor NiFi

```bash
# Acceder al contenedor NiFi
docker exec -it nifi bash

# Crear directorios necesarios
mkdir -p /home/nifi/scripts
mkdir -p /home/nifi/ingest
mkdir -p /home/nifi/bucket
mkdir -p /home/nifi/hadoop

# Verificar estructura
ls -la /home/nifi/
```

### En el Contenedor Hadoop

```bash
# Acceder al contenedor Hadoop
docker exec -it edvai_hadoop bash

# Cambiar a usuario hadoop
su hadoop

# Crear directorios en HDFS
hdfs dfs -mkdir -p /nifi
hdfs dfs -chmod 777 /nifi

# Crear directorios locales
mkdir -p /home/hadoop/scripts
mkdir -p /home/hadoop/hive
mkdir -p /home/hadoop/airflow/dags

# Verificar estructura HDFS
hdfs dfs -ls -h /
```

## 📥 Paso 2: Copiar Archivos al Contenedor NiFi

### Script de Descarga

```bash
# Desde el host (directorio del proyecto)
cd ejercicio-11-practica-titanic-nifi-airflow-hive/scripts/

# Copiar script al contenedor NiFi
docker cp ingest.sh nifi:/home/nifi/scripts/

# Dar permisos de ejecución
docker exec -it nifi chmod +x /home/nifi/scripts/ingest.sh

# Verificar
docker exec -it nifi ls -la /home/nifi/scripts/
```

### Archivos de Configuración de Hadoop

```bash
# Copiar configuraciones de Hadoop
cd ../nifi/

docker cp core-site.xml nifi:/home/nifi/hadoop/
docker cp hdfs-site.xml nifi:/home/nifi/hadoop/

# Verificar
docker exec -it nifi ls -la /home/nifi/hadoop/
docker exec -it nifi cat /home/nifi/hadoop/core-site.xml
```

**⚠️ Importante**: Verificar que la IP en `core-site.xml` coincida con la IP del contenedor Hadoop:

```bash
# Obtener IP del contenedor Hadoop
docker inspect edvai_hadoop | grep IPAddress

# Si es diferente de 172.17.0.2, actualizar core-site.xml
```

## 📥 Paso 3: Copiar Archivos al Contenedor Hadoop

### Scripts Hive

```bash
# Desde el host
cd ejercicio-11-practica-titanic-nifi-airflow-hive/hive/

# Copiar script SQL
docker cp titanic-setup.sql edvai_hadoop:/home/hadoop/hive/

# Verificar
docker exec -it edvai_hadoop ls -la /home/hadoop/hive/
```

### DAG de Airflow

```bash
# Copiar DAG
cd ../airflow/

docker cp titanic_dag.py edvai_hadoop:/home/hadoop/airflow/dags/

# Verificar
docker exec -it edvai_hadoop ls -la /home/hadoop/airflow/dags/
```

## ▶️ Paso 4: Ejecutar el Pipeline

### 4.1. Descargar Datos (NiFi)

```bash
# Ejecutar script de descarga
docker exec -it nifi /home/nifi/scripts/ingest.sh
```

**Salida esperada**:
```
=== INICIANDO DESCARGA DE TITANIC.CSV ===
1. Creando directorio de ingesta: /home/nifi/ingest
2. Descargando titanic.csv desde ...
✅ Descarga completada exitosamente: /home/nifi/ingest/titanic.csv
=== PROCESO DE DESCARGA COMPLETADO ===
```

**Verificación**:
```bash
docker exec -it nifi ls -lh /home/nifi/ingest/
docker exec -it nifi wc -l /home/nifi/ingest/titanic.csv  # Debe ser 892
```

### 4.2. Configurar Flujo en NiFi

1. **Acceder a NiFi**: https://localhost:8443/nifi

2. **Crear procesador GetFile (Origen)**:
   - Arrastar "Processor" al canvas
   - Buscar "GetFile"
   - Configurar:
     - Input Directory: `/home/nifi/ingest`
     - File Filter: `titanic.csv`
     - Keep Source File: `false`

3. **Crear procesador PutFile (Bucket)**:
   - Agregar "PutFile"
   - Configurar:
     - Directory: `/home/nifi/bucket`
     - Conflict Resolution Strategy: `replace`

4. **Crear procesador GetFile (Bucket)**:
   - Agregar segundo "GetFile"
   - Configurar:
     - Input Directory: `/home/nifi/bucket`
     - File Filter: `titanic.csv`
     - Keep Source File: `false`

5. **Crear procesador PutHDFS**:
   - Agregar "PutHDFS"
   - Configurar:
     - Hadoop Configuration Resources:
       ```
       /home/nifi/hadoop/core-site.xml,/home/nifi/hadoop/hdfs-site.xml
       ```
     - Directory: `/nifi`
     - Conflict Resolution Strategy: `replace`

6. **Conectar procesadores**:
   - GetFile (ingest) → success → PutFile
   - PutFile → success → GetFile (bucket)
   - GetFile (bucket) → success → PutHDFS

7. **Ejecutar flujo**:
   - Seleccionar todos los procesadores (Ctrl+A)
   - Click derecho → Start

**Verificación**:
```bash
# Verificar archivo en HDFS
docker exec -it edvai_hadoop bash
hdfs dfs -ls /nifi
hdfs dfs -cat /nifi/titanic.csv | head -5
```

### 4.3. Crear Base de Datos y Tabla en Hive

```bash
# Acceder al contenedor Hadoop
docker exec -it edvai_hadoop bash
su hadoop

# Ejecutar script SQL
hive -f /home/hadoop/hive/titanic-setup.sql
```

**Salida esperada**:
```
OK
Time taken: ...
OK
Time taken: ...
OK
titanic_raw
OK
col_name     data_type     comment
passengerid  int
survived     int
...
```

**Verificación**:
```bash
# Verificar base de datos
hive -e "SHOW DATABASES;" | grep titanic

# Verificar tabla
hive -e "USE titanic_db; SHOW TABLES;"

# Verificar datos (debe ser 0 en titanic_processed)
hive -e "USE titanic_db; SELECT COUNT(*) FROM titanic_raw;"
hive -e "USE titanic_db; SELECT COUNT(*) FROM titanic_processed;"
```

### 4.4. Ejecutar DAG de Airflow

#### Opción A: Desde la UI de Airflow

1. Acceder a http://localhost:8080
2. Buscar `titanic_processing_dag`
3. Activar el toggle (debe estar en ON)
4. Click en "Trigger DAG" (botón ▶)
5. Monitorear ejecución en "Graph" o "Grid"

#### Opción B: Desde línea de comandos

```bash
# Verificar que el DAG existe
airflow dags list | grep titanic

# Trigger manual
airflow dags trigger titanic_processing_dag

# Ver estado
airflow dags list-runs -d titanic_processing_dag

# Ver logs (cambiar fecha si es necesario)
airflow tasks logs titanic_processing_dag transform_and_load_hive $(date +%Y-%m-%d)
```

**Logs esperados** (parcial):
```
--- Iniciando descarga desde HDFS ---
✅ Archivo descargado de HDFS a /tmp/titanic_raw.csv
--- Cargando datos con Pandas ---
📊 Total de registros cargados: 891
--- Aplicando transformaciones ---
  • Removiendo columnas SibSp y Parch
  • Calculando promedios de edad por género
    - Promedio edad hombres: 30.73
    - Promedio edad mujeres: 27.92
...
✅ Datos cargados en tabla titanic_db.titanic_processed
=== PROCESO COMPLETADO EXITOSAMENTE ===
```

**Verificación**:
```bash
# Verificar datos en Hive (debe ser 891)
hive -e "USE titanic_db; SELECT COUNT(*) FROM titanic_processed;"

# Ver muestra de datos
hive -e "USE titanic_db; SELECT * FROM titanic_processed LIMIT 5;"
```

### 4.5. Ejecutar Consultas Analíticas

```bash
# Sobrevivientes por género
hive -e "
USE titanic_db;
SELECT 
    Sex,
    SUM(Survived) as Sobrevivientes,
    COUNT(*) as Total
FROM titanic_processed
GROUP BY Sex;
"

# Sobrevivientes por clase
hive -e "
USE titanic_db;
SELECT 
    Pclass,
    SUM(Survived) as Sobrevivientes
FROM titanic_processed
GROUP BY Pclass
ORDER BY Pclass;
"

# Mayor edad que sobrevivió
hive -e "
USE titanic_db;
SELECT Name, Age, Sex, Pclass
FROM titanic_processed
WHERE Survived = 1 AND Age IS NOT NULL
ORDER BY Age DESC
LIMIT 1;
"

# Menor edad que sobrevivió
hive -e "
USE titanic_db;
SELECT Name, Age, Sex, Pclass
FROM titanic_processed
WHERE Survived = 1 AND Age IS NOT NULL
ORDER BY Age ASC
LIMIT 1;
"
```

## ✅ Verificación Final

### Checklist de Verificación

- [ ] Archivo descargado en `/home/nifi/ingest/titanic.csv`
- [ ] Archivo procesado por NiFi y en HDFS `/nifi/titanic.csv`
- [ ] Base de datos `titanic_db` creada en Hive
- [ ] Tabla `titanic_raw` creada y apuntando a HDFS
- [ ] Tabla `titanic_processed` creada (vacía inicialmente)
- [ ] DAG `titanic_processing_dag` visible en Airflow
- [ ] DAG ejecutado exitosamente
- [ ] 891 registros en `titanic_processed`
- [ ] Consultas analíticas funcionando
- [ ] Resultados coherentes con dataset original

### Comandos de Verificación Rápida

```bash
# Verificar todo el pipeline
echo "=== VERIFICACIÓN COMPLETA ==="

# 1. NiFi - Archivo descargado
echo "1. Archivo en NiFi:"
docker exec -it nifi ls -lh /home/nifi/ingest/

# 2. HDFS - Archivo ingestado
echo "2. Archivo en HDFS:"
docker exec -it edvai_hadoop hdfs dfs -ls /nifi

# 3. Hive - Base de datos
echo "3. Base de datos Hive:"
docker exec -it edvai_hadoop hive -e "SHOW DATABASES;" | grep titanic

# 4. Hive - Tablas
echo "4. Tablas Hive:"
docker exec -it edvai_hadoop hive -e "USE titanic_db; SHOW TABLES;"

# 5. Hive - Conteo de registros
echo "5. Registros en titanic_processed:"
docker exec -it edvai_hadoop hive -e "USE titanic_db; SELECT COUNT(*) FROM titanic_processed;"

# 6. Airflow - DAG
echo "6. DAG en Airflow:"
docker exec -it edvai_hadoop airflow dags list | grep titanic

echo "=== VERIFICACIÓN COMPLETADA ==="
```

## 🐛 Troubleshooting

### Problema: NiFi no puede conectarse a HDFS

**Síntomas**: Error en PutHDFS "Could not connect to HDFS"

**Solución**:
```bash
# Verificar IP del contenedor Hadoop
docker inspect edvai_hadoop | grep IPAddress

# Actualizar core-site.xml con la IP correcta
# Reiniciar procesadores en NiFi
```

### Problema: Archivo no aparece en HDFS

**Síntomas**: `hdfs dfs -ls /nifi` no muestra titanic.csv

**Solución**:
```bash
# Verificar permisos
hdfs dfs -chmod 777 /nifi

# Verificar que NiFi ejecutó exitosamente
# Revisar logs de PutHDFS en NiFi UI

# Re-ejecutar flujo NiFi
```

### Problema: DAG no aparece en Airflow

**Síntomas**: `airflow dags list` no muestra `titanic_processing_dag`

**Solución**:
```bash
# Verificar sintaxis del DAG
python3 /home/hadoop/airflow/dags/titanic_dag.py

# Reiniciar scheduler
pkill -f "airflow scheduler"
airflow scheduler &

# Esperar 30 segundos y verificar
airflow dags list | grep titanic
```

### Problema: Error "ModuleNotFoundError: No module named 'pandas'"

**Síntomas**: DAG falla con error de Pandas

**Solución**:
```bash
# Instalar Pandas
pip3 install pandas

# Verificar instalación
python3 -c "import pandas; print(pandas.__version__)"

# Re-ejecutar DAG
airflow dags trigger titanic_processing_dag
```

### Problema: Tabla `titanic_processed` vacía

**Síntomas**: `SELECT COUNT(*)` retorna 0

**Solución**:
```bash
# Verificar ejecución del DAG
airflow dags list-runs -d titanic_processing_dag

# Ver logs del DAG
airflow tasks logs titanic_processing_dag transform_and_load_hive $(date +%Y-%m-%d)

# Re-ejecutar DAG si es necesario
airflow dags trigger titanic_processing_dag
```

## 📚 Recursos Adicionales

- [Documentación completa](README.md)
- [Ejercicios resueltos paso a paso](ejercicios-resueltos.md)
- [Configuración de NiFi](nifi/README.md)
- [Configuración de Airflow](airflow/README.md)
- [Configuración de Hive](hive/README.md)

---

**¡Felicidades! 🎉 Has completado la instalación y ejecución del Ejercicio 11.**

Si todos los pasos se ejecutaron correctamente, deberías tener:
- ✅ Pipeline completo funcionando
- ✅ 891 registros procesados en Hive
- ✅ Consultas analíticas respondidas
- ✅ Captura de pantalla del DAG exitoso

---

**Última actualización**: 2025-11-20

