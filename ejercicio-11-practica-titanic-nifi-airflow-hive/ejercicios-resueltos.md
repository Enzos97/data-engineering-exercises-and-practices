# Ejercicios Resueltos - Clase 10: Práctica NiFi + Airflow + Hive (Titanic)

**Consigna**: Realizar un pipeline completo de ETL usando NiFi para ingesta, Airflow para procesamiento y Hive para almacenamiento y análisis de datos del Titanic.

---

## Ejercicio 1: Script Bash para Descargar Titanic.csv

### 📝 Enunciado

En el shell de Nifi, crear un script `.sh` que descargue el archivo `titanic.csv` al directorio `/home/nifi/ingest` (crearlo si es necesario). Ejecutarlo con `./home/nifi/ingest/ingest.sh`

**URL del archivo**: https://data-engineer-edvai-public.s3.amazonaws.com/titanic.csv

### 💻 Solución

#### Paso 1: Conectarse al contenedor NiFi

```bash
docker exec -it nifi bash
```

#### Paso 2: Navegar o crear el directorio

```bash
cd /home/nifi
mkdir -p ingest
cd ingest
```

#### Paso 3: Crear el script de descarga

```bash
cat <<EOF > /home/nifi/ingest/ingest.sh
#!/bin/bash

echo "=== DESCARGANDO ARCHIVO TITANIC.CSV ==="
echo "Fecha: \$(date)"

# Crear directorio si no existe
mkdir -p /home/nifi/ingest

# Descargar archivo
echo "Descargando titanic.csv..."
curl -o /home/nifi/ingest/titanic.csv \\
https://data-engineer-edvai-public.s3.amazonaws.com/titanic.csv

# Verificar descarga
if [ \$? -eq 0 ]; then
    echo "✅ Descarga completada exitosamente"
    echo "📊 Tamaño del archivo: \$(ls -lh /home/nifi/ingest/titanic.csv | awk '{print \$5}')"
else
    echo "❌ Error en la descarga"
    exit 1
fi

echo "=== PROCESO COMPLETADO ==="
EOF
```

#### Paso 4: Dar permisos de ejecución

```bash
chmod +x /home/nifi/ingest/ingest.sh
```

#### Paso 5: Ejecutar el script

```bash
/home/nifi/ingest/ingest.sh
```

**Salida esperada**:
```
=== DESCARGANDO ARCHIVO TITANIC.CSV ===
Fecha: Thu Nov 20 03:42:20 AM UTC 2025
Descargando titanic.csv...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 60353  100 60353    0     0  78578      0 --:--:-- --:--:-- --:--:-- 78584
✅ Descarga completada exitosamente
📊 Tamaño del archivo: 59K
=== PROCESO COMPLETADO ===
```

#### Paso 6: Verificar el archivo descargado

```bash
ls -la /home/nifi/ingest/
head -5 /home/nifi/ingest/titanic.csv
```

**Salida esperada**:
```
PassengerId,Survived,Pclass,Name,Sex,Age,SibSp,Parch,Ticket,Fare,Cabin,Embarked
1,0,3,"Braund, Mr. Owen Harris",male,22,1,0,A/5 21171,7.25,,S
2,1,1,"Cumings, Mrs. John Bradley (Florence Briggs Thayer)",female,38,1,0,PC 17599,71.2833,C85,C
3,1,3,"Heikkinen, Miss. Laina",female,26,0,0,STON/O2. 3101282,7.925,,S
4,1,1,"Futrelle, Mrs. Jacques Heath (Lily May Peel)",female,35,1,0,113803,53.1,C123,S
```

### 📊 Captura de Pantalla

> **Archivo**: `images/ejercicio1-descarga-titanic.png`

---

## Ejercicios 2-6: Flujo NiFi

### 📝 Enunciado

Usando procesos en NiFi:
- **Ejercicio 2**: Preparar directorios necesarios
- **Ejercicio 3**: Tomar el archivo `titanic.csv` desde `/home/nifi/ingest`
- **Ejercicio 4**: Mover el archivo a `/home/nifi/bucket`
- **Ejercicio 5**: Tomar el archivo desde `/home/nifi/bucket`
- **Ejercicio 6**: Ingestarlo en HDFS `/nifi`

### 💻 Solución

#### Paso 1: Preparar directorios en NiFi (Ejercicio 2)

```bash
# Dentro del contenedor NiFi
mkdir -p /home/nifi/bucket
mkdir -p /home/nifi/hadoop
```

#### Paso 2: Crear archivos de configuración de Hadoop

**Crear `core-site.xml`**:

```bash
cat <<EOF > /home/nifi/hadoop/core-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://172.17.0.2:9000</value>
        </property>
</configuration>
EOF
```

**Crear `hdfs-site.xml`**:

```bash
cat <<EOF > /home/nifi/hadoop/hdfs-site.xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
        <property>
                <name>dfs.replication</name>
                <value>1</value>
        </property>

        <property>
                <name>dfs.name.dir</name>
                <value>file:///home/hadoop/hadoopdata/hdfs/namenode</value>
        </property>

        <property>
                <name>dfs.data.dir</name>
                <value>file:///home/hadoop/hadoopdata/hdfs/datanode</value>
        </property>
</configuration>
EOF
```

#### Paso 3: Preparar HDFS en Hadoop

```bash
# En otra terminal, conectarse al contenedor Hadoop
docker exec -it edvai_hadoop bash
su hadoop

# Crear directorio en HDFS
hdfs dfs -mkdir -p /nifi

# Dar permisos completos
hdfs dfs -chmod 777 /nifi

# Verificar
hdfs dfs -ls /
```

**Salida esperada**:
```
drwxrwxrwx   - hadoop supergroup          0 2025-11-20 01:44 /nifi
```

#### Paso 4: Configurar Flujo en NiFi (Ejercicios 3-6)

**Acceder a la UI de NiFi**: https://localhost:8443/nifi

**Flujo del Pipeline**:

```
┌────────────────┐       ┌────────────────┐       ┌────────────────┐       ┌────────────────┐
│   GetFile      │   →   │   PutFile      │   →   │   GetFile      │   →   │   PutHDFS      │
│ /nifi/ingest   │       │ /nifi/bucket   │       │ /nifi/bucket   │       │ /nifi          │
└────────────────┘       └────────────────┘       └────────────────┘       └────────────────┘
   Ejercicio 3            Ejercicio 4            Ejercicio 5             Ejercicio 6
```

**Procesador 1 - GetFile** (Ejercicio 3):
- **Processor**: GetFile
- **Input Directory**: `/home/nifi/ingest`
- **File Filter**: `titanic.csv`
- **Keep Source File**: false (para mover, no copiar)

**Procesador 2 - PutFile** (Ejercicio 4):
- **Processor**: PutFile
- **Directory**: `/home/nifi/bucket`
- **Conflict Resolution Strategy**: replace

**Procesador 3 - GetFile** (Ejercicio 5):
- **Processor**: GetFile
- **Input Directory**: `/home/nifi/bucket`
- **File Filter**: `titanic.csv`
- **Keep Source File**: false

**Procesador 4 - PutHDFS** (Ejercicio 6):
- **Processor**: PutHDFS
- **Hadoop Configuration Resources**: 
  ```
  /home/nifi/hadoop/core-site.xml,/home/nifi/hadoop/hdfs-site.xml
  ```
- **Directory**: `/nifi`
- **Conflict Resolution Strategy**: replace

#### Paso 5: Ejecutar el flujo

1. Conectar todos los procesadores en secuencia
2. Start cada procesador en orden
3. Monitorear que el archivo se mueva correctamente

#### Paso 6: Verificar en HDFS

```bash
# En el contenedor Hadoop
hdfs dfs -ls /nifi
hdfs dfs -cat /nifi/titanic.csv | head -5
```

**Salida esperada**:
```
Found 3 items
-rw-r--r--   1 nifi supergroup      60353 2025-11-20 01:44 /nifi/titanic.csv
```

### 📊 Capturas de Pantalla

> **Archivos**: 
> - `images/ejercicio2-directorios.png`
> - `images/ejercicio3-6-nifi-flow.png`
> - `images/verificacion-hdfs.png`

---

## Ejercicio 7: Pipeline Airflow con Transformaciones

### 📝 Enunciado

Una vez que tengamos el archivo `titanic.csv` en HDFS, realizar un pipeline en Airflow que ingeste este archivo y lo cargue en HIVE, teniendo en cuenta las siguientes transformaciones:

a) Remover las columnas SibSp y Parch  
b) Por cada fila calcular el promedio de edad de los hombres en caso que sea hombre y promedio de edad de las mujeres en caso que sea mujer  
c) Si el valor de cabina es nulo, dejarlo en 0 (cero)

### 💻 Solución

#### Paso 1: Crear la tabla en Hive

```bash
# Conectarse al contenedor Hadoop
docker exec -it edvai_hadoop bash
su hadoop

# Abrir Hive
hive
```

```sql
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS titanic_db;

-- Usar base de datos
USE titanic_db;

-- Crear tabla
CREATE TABLE IF NOT EXISTS titanic_processed (
    PassengerId INT,
    Survived INT,
    Pclass INT,
    Name STRING,
    Sex STRING,
    Age FLOAT,
    Ticket STRING,
    Fare FLOAT,
    Cabin STRING,
    Embarked STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Verificar estructura
DESC titanic_processed;

-- Salir
exit;
```

**Salida esperada**:
```
OK
Time taken: 3.707 seconds

OK
Time taken: 0.1 seconds

OK
Time taken: 0.671 seconds
```

#### Paso 2: Instalar Pandas (si no está instalado)

```bash
pip install pandas
```

#### Paso 3: Crear el DAG de Airflow

```bash
cd /home/hadoop/airflow/dags
nano titanic_dag.py
```

**Contenido del DAG**: (Ver archivo `airflow/titanic_dag.py`)

#### Paso 4: Verificar sintaxis del DAG

```bash
python3 /home/hadoop/airflow/dags/titanic_dag.py
```

Si no hay errores, el script se ejecutará sin salida.

#### Paso 5: Verificar que Airflow detecta el DAG

```bash
airflow dags list | grep titanic
```

**Salida esperada**:
```
titanic_processing_dag
```

#### Paso 6: Ejecutar el DAG

**Opción A - Desde la UI de Airflow**:
1. Acceder a http://localhost:8080
2. Buscar `titanic_processing_dag`
3. Activar el toggle
4. Click en "Trigger DAG"

**Opción B - Desde línea de comandos**:
```bash
airflow dags trigger titanic_processing_dag
```

#### Paso 7: Monitorear ejecución

```bash
# Ver logs
airflow tasks logs titanic_processing_dag transform_and_load_hive $(date +%Y-%m-%d)
```

**Salida esperada** (resumen):
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
  • Reemplazando valores nulos de Cabin con 0
  • Limpiando comas en el campo Name
✅ Transformaciones completadas. Registros finales: 891
--- Guardando archivo procesado ---
✅ Archivo guardado en /tmp/titanic_final.csv
--- Subiendo archivo procesado a HDFS ---
✅ Archivo subido a HDFS: /tmp/titanic_final.csv
--- Cargando datos en Hive ---
✅ Datos cargados en tabla titanic_db.titanic_processed

=== PROCESO COMPLETADO EXITOSAMENTE ===
```

#### Paso 8: Verificar datos en Hive

```bash
hive -e "SELECT COUNT(*) FROM titanic_db.titanic_processed;"
```

**Salida esperada**:
```
OK
891
Time taken: 5.234 seconds, Fetched: 1 row(s)
```

### 📊 Capturas de Pantalla

> **Archivos**: 
> - `images/ejercicio7-airflow-dag.png`
> - `images/ejercicio7-logs-airflow.png`
> - `images/ejercicio7-verify-hive.png`

---

## Ejercicio 8: Consultas de Negocio en Hive

### 📝 Enunciado

Una vez con la información en el datawarehouse calcular:

a) Cuántos hombres y cuántas mujeres sobrevivieron  
b) Cuántas personas sobrevivieron según cada clase (Pclass)  
c) Cuál fue la persona de mayor edad que sobrevivió  
d) Cuál fue la persona más joven que sobrevivió

### 💻 Solución

#### a) Sobrevivientes por género

```bash
hive -e "SELECT Sex, COUNT(*) as Cantidad FROM titanic_db.titanic_processed WHERE Survived = 1 GROUP BY Sex;"
```

**Salida esperada**:
```
OK
female  233
male    109
Time taken: 6.916 seconds, Fetched: 2 row(s)
```

**Análisis**: 233 mujeres y 109 hombres sobrevivieron. Las mujeres tuvieron una tasa de supervivencia significativamente mayor.

#### b) Sobrevivientes por clase

```bash
hive -e "SELECT Pclass, COUNT(*) as Cantidad FROM titanic_db.titanic_processed WHERE Survived = 1 GROUP BY Pclass;"
```

**Salida esperada**:
```
OK
1       136
2       87
3       119
Time taken: 6.06 seconds, Fetched: 3 row(s)
```

**Análisis**: 
- Primera clase: 136 sobrevivientes
- Segunda clase: 87 sobrevivientes  
- Tercera clase: 119 sobrevivientes

#### c) Persona de mayor edad que sobrevivió

```bash
hive -e "SELECT Name, Age FROM titanic_db.titanic_processed WHERE Survived = 1 AND Age > 0 ORDER BY Age DESC LIMIT 1;"
```

**Salida esperada**:
```
OK
Barkworth Mr. Algernon Henry Wilson     80.0
Time taken: 6.939 seconds, Fetched: 1 row(s)
```

**Análisis**: El Sr. Algernon Henry Wilson Barkworth de 80 años fue el sobreviviente de mayor edad.

#### d) Persona más joven que sobrevivió

```bash
hive -e "SELECT Name, Age FROM titanic_db.titanic_processed WHERE Survived = 1 AND Age > 0 ORDER BY Age ASC LIMIT 1;"
```

**Salida esperada**:
```
OK
Thomas Master. Assad Alexander  0.42
Time taken: 5.499 seconds, Fetched: 1 row(s)
```

**Análisis**: El pequeño Assad Alexander Thomas de 0.42 años (aproximadamente 5 meses) fue el sobreviviente más joven.

### Consultas Adicionales de Análisis

#### Tasa de supervivencia general

```sql
SELECT 
    Survived,
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM titanic_db.titanic_processed), 2) as porcentaje
FROM titanic_db.titanic_processed
GROUP BY Survived;
```

**Resultado**:
```
0    549    61.62%  (No sobrevivieron)
1    342    38.38%  (Sobrevivieron)
```

#### Tasa de supervivencia por género

```sql
SELECT 
    Sex,
    SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) as sobrevivieron,
    SUM(CASE WHEN Survived = 0 THEN 1 ELSE 0 END) as fallecieron,
    ROUND(SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as tasa_supervivencia
FROM titanic_db.titanic_processed
GROUP BY Sex;
```

**Resultado**:
```
female    233    81    74.20%
male      109    468   18.89%
```

### 📊 Capturas de Pantalla

> **Archivos**: 
> - `images/ejercicio8a-genero.png`
> - `images/ejercicio8b-clase.png`
> - `images/ejercicio8c-mayor-edad.png`
> - `images/ejercicio8d-menor-edad.png`

---

## 📊 Resumen del Pipeline Completo

```
┌─────────────────────────────────────────────────────────────┐
│                   1. Descarga (NiFi)                         │
│         Script bash → titanic.csv en /home/nifi/ingest      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              2-6. Flujo NiFi (Movimiento)                    │
│   GetFile → PutFile → GetFile → PutHDFS → /nifi/titanic.csv│
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│            7. Procesamiento (Airflow + Pandas)               │
│   • Descarga desde HDFS                                      │
│   • Transformaciones (remover columnas, rellenar edad)       │
│   • Carga en Hive                                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              8. Análisis (Hive SQL)                          │
│   • Sobrevivientes por género                                │
│   • Sobrevivientes por clase                                 │
│   • Persona más joven y mayor que sobrevivió                 │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Resultados Clave

### Datos Procesados
- **Total de registros**: 891 pasajeros
- **Sobrevivientes**: 342 (38.38%)
- **Fallecidos**: 549 (61.62%)

### Insights de Negocio
1. **Género**: Las mujeres tuvieron 74.20% de supervivencia vs 18.89% los hombres
2. **Clase Social**: La primera clase tuvo mejor tasa de supervivencia
3. **Edad**: Los sobrevivientes van desde 0.42 años hasta 80 años
4. **Política de evacuación**: "Mujeres y niños primero" claramente aplicada

---

**Fecha de completitud**: 2025-11-20  
**Autor**: Edvai Team  
**Versión**: 1.0

