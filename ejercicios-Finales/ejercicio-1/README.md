# Ejercicio Final 1 - Aviación Civil: Airflow + PySpark + Hive

Este ejercicio implementa un pipeline ETL completo para procesar datos de aviación argentina usando **Apache Airflow** para orquestación, **PySpark** para transformaciones distribuidas (sin Pandas), y **Apache Hive** para almacenamiento y análisis SQL de datos de vuelos y aeropuertos.

## 🎯 Objetivos

- Implementar ingesta automatizada de archivos CSV desde S3 a HDFS
- Crear tablas estructuradas en Hive con schemas específicos
- Desarrollar script PySpark con transformaciones complejas
- Orquestar pipeline con Apache Airflow
- Aplicar análisis de negocio con SQL
- Elaborar conclusiones y proponer arquitectura alternativa

## 📋 Ejercicios Incluidos

### 1️⃣ **Ingest de Archivos (Punto 1)**
- Descargar 3 archivos CSV desde S3
- Subir archivos a HDFS `/ingest`
- Verificar archivos en sistema distribuido

### 2️⃣ **Creación de Tablas en Hive (Punto 2)**
- Base de datos: `aviacion`
- Tabla 1: `aeropuerto_tabla` (vuelos 2021-2022)
- Tabla 2: `aeropuerto_detalles_tabla` (detalles aeropuertos)
- Aplicar schemas específicos según PDF

### 3️⃣ **Script PySpark con Transformaciones (Punto 4)**
- Eliminar columnas innecesarias (inhab, fir, calidad del dato)
- Filtrar vuelos internacionales (solo domésticos)
- Rellenar valores NULL con 0 (pasajeros, distancia_ref)
- Convertir fechas a formato Date
- Normalizar nombres de columnas (tildes, paréntesis)
- Mapeo correcto de columnas de aeropuertos

### 4️⃣ **Orquestación con Airflow (Punto 3)**
- DAG: `aviacion_processing_spark_dag`
- Flujo: crear_tablas → procesar_datos → verificar
- Ejecución automatizada del pipeline
- Integración con Spark

### 5️⃣ **Verificar Tipos de Datos (Punto 5)**
- Schema de aeropuerto_tabla
- Validar tipos: fecha DATE, pasajeros INT, etc.

### 6️⃣ **Análisis: Vuelos por Periodo (Punto 6)**
- Contar vuelos entre 01/12/2021 y 31/01/2022
- Resultado esperado: ~57,984 vuelos

### 7️⃣ **Análisis: Pasajeros por Aerolínea (Punto 7)**
- Suma de pasajeros de Aerolíneas Argentinas
- Periodo: 01/01/2021 - 30/06/2022
- Resultado esperado: ~7.4M pasajeros

### 8️⃣ **Tablero de Vuelos con Ciudades (Punto 8)**
- JOIN entre vuelos y aeropuertos
- Mostrar ciudades de origen y destino
- Top 10 vuelos ordenados por fecha

### 9️⃣ **Top 10 Aerolíneas (Punto 9)**
- Ranking por pasajeros transportados
- Visualización con gráfico de barras
- Periodo: 2021-2022

### 🔟 **Top 10 Aeronaves desde Buenos Aires (Punto 10)**
- Despegues desde CABA y Buenos Aires
- Conteo por modelo de aeronave
- Visualización con gráfico de barras

### 1️⃣1️⃣ **Datos Externos Recomendados (Punto 11)**
- Datos meteorológicos (clima, vientos, visibilidad)
- Calendario de feriados y eventos
- Datos económicos (precios, inflación, tipo de cambio)
- Capacidad de aeronaves (asientos totales)
- Datos de puntualidad y retrasos
- Información de aeropuertos (capacidad, pistas)

### 1️⃣2️⃣ **Conclusiones y Recomendaciones (Punto 12)**

#### Calidad de Datos
- ✅ Dataset robusto: 143,000 registros de vuelos procesados
- ✅ Cobertura temporal completa: 18 meses (2021-2022)
- ⚠️ Valores NULL en pasajeros (~5%) y distancia_ref (~10%)
- ⚠️ Vuelos internacionales representan 47.5% del total (excluidos)

#### Concentración del Mercado
- **Aerolíneas Argentinas**: Dominancia del 70% del mercado doméstico
- **Top 3 aerolíneas**: Concentran >85% de los pasajeros
- **Low-cost**: Crecimiento de Flybondi y JetSmart (competencia)

#### Patrones de Temporalidad
- **Alta temporada**: Diciembre-Enero (verano argentino)
- **Frecuencia**: ~475 vuelos/día promedio
- **Rutas principales**: Buenos Aires (EZE/AEP) ⟷ Provincias

#### Recomendaciones Operativas
1. **Calidad de Datos**: Implementar validaciones en origen
2. **Diversificación**: Incentivar competencia para reducir monopolio
3. **Capacidad**: Optimizar slots en aeropuertos congestionados (AEP)
4. **Sostenibilidad**: Monitorear emisiones por aeronave
5. **Conectividad**: Mejorar rutas interprovinciales directas

📄 **Ver documento completo:** `CONCLUSIONES_Y_ARQUITECTURA.md`

### 1️⃣3️⃣ **Arquitectura Alternativa (Punto 13)**

#### Opción 1: Cloud AWS

**Arquitectura Propuesta:**
```
S3 → Glue ETL → Athena/Redshift → QuickSight
         ↓
    Step Functions (orquestación)
```

**Stack Tecnológico:**
- **Almacenamiento**: S3 (datos raw y procesados)
- **ETL**: AWS Glue (Spark managed)
- **Orquestación**: Step Functions / MWAA (Airflow managed)
- **DW**: Redshift Spectrum o Athena
- **BI**: QuickSight o Tableau
- **Gobierno**: Glue Data Catalog

**Ventajas:**
✅ Escalabilidad automática  
✅ Pago por uso (no infraestructura idle)  
✅ Integración nativa entre servicios  
✅ Managed services (menos DevOps)  

**Desventajas:**
❌ Costo variable (difícil presupuesto)  
❌ Vendor lock-in  
❌ Curva de aprendizaje AWS  

**Costo Estimado:** USD 300-800/mes (143k registros/mes)

---

#### Opción 2: Cloud GCP

**Arquitectura Propuesta:**
```
GCS → Dataproc → BigQuery → Data Studio
        ↓
  Cloud Composer (Airflow managed)
```

**Stack Tecnológico:**
- **Almacenamiento**: Cloud Storage
- **ETL**: Dataproc (Spark) o Dataflow
- **Orquestación**: Cloud Composer (Airflow managed)
- **DW**: BigQuery (columnar, serverless)
- **BI**: Looker o Data Studio

**Ventajas:**
✅ BigQuery extremadamente rápido para analítica  
✅ Integración con TensorFlow (ML futuro)  
✅ Costos más predecibles que AWS  

**Costo Estimado:** USD 250-700/mes

---

#### Opción 3: On-Premise Mejorado

**Arquitectura Propuesta:**
```
NiFi → HDFS → Spark (yarn) → Hive → Superset
              ↓
         Airflow (orchestration)
```

**Mejoras vs Actual:**
- **Alta Disponibilidad**: Cluster multi-nodo (3+ nodes)
- **Monitoreo**: Prometheus + Grafana
- **Backup**: Snapshots HDFS + DR site
- **CI/CD**: Jenkins para deployments
- **Seguridad**: Kerberos + Ranger

**Ventajas:**
✅ Control total de datos (cumplimiento normativo)  
✅ Costo fijo predecible  
✅ Sin latencia de red cloud  
✅ Privacidad de datos sensibles  

**Desventajas:**
❌ CAPEX inicial alto (hardware)  
❌ Requiere equipo DevOps dedicado  
❌ Escalabilidad limitada por hardware  

**Costo Estimado:**  
- **CAPEX**: USD 30,000 (cluster 5 nodos)  
- **OPEX**: USD 2,000/mes (salarios, electricidad, mantenimiento)

---

#### Recomendación Final

**Para ANAC (organismo gubernamental):**

🏆 **Híbrido: On-Premise + Cloud Backup**

**Justificación:**
1. **Datos sensibles**: Información de vuelos puede ser estratégica
2. **Presupuesto estatal**: CAPEX más fácil de aprobar que OPEX recurrente
3. **Soberanía de datos**: Cumplimiento normativo argentino
4. **DR en Cloud**: S3 Glacier para backups (bajo costo)

**Configuración Recomendada:**
- **Producción**: On-premise (Hadoop cluster)
- **Backup/DR**: AWS S3 Glacier
- **BI Público**: Athena + QuickSight (consultas públicas)
- **ML/Innovación**: GCP Dataproc (proyectos piloto)

📄 **Ver documento completo:** `CONCLUSIONES_Y_ARQUITECTURA.md` con diagramas, costos y roadmap de implementación.

## 📁 Estructura del Proyecto

```
ejercicios-Finales/ejercicio-1/
├── README.md                           # Documentación principal
├── SOLUCION_COMPLETA_EJERCICIO_1.md    # Guía paso a paso completa
├── TESTEAR_EN_HIVE.md                  # Instrucciones de testing
├── CONCLUSIONES_Y_ARQUITECTURA.md      # Puntos 12 y 13 (Análisis completo)
├── scripts/
│   ├── ingest_aviacion.sh             # Script bash para descarga e ingest
│   └── process_aviacion_spark.py      # Script PySpark de transformación
├── airflow/
│   └── aviacion_spark_dag.py          # DAG de Airflow
└── hive/
    └── queries_aviacion.sql           # CREATE TABLE + Consultas SQL
```

## 🚀 Tecnologías Utilizadas

- **Apache Spark (PySpark)** - Procesamiento distribuido de datos
- **Apache Airflow** - Orquestación de pipelines
- **Apache Hive** - Data warehouse y consultas SQL
- **HDFS** - Sistema de archivos distribuido
- **Python** - Lenguaje de programación
- **Bash** - Scripting y automatización
- **Docker** - Contenedorización

## 📊 Datasets Utilizados

### Vuelos 2021
- **URL**: https://data-engineer-edvai-public.s3.amazonaws.com/2021-informe-ministerio.csv
- **Registros**: ~115,000 vuelos
- **Formato**: CSV con delimitador `;`
- **Periodo**: 01/01/2021 - 31/12/2021

### Vuelos 2022 (Primer Semestre)
- **URL**: https://data-engineer-edvai-public.s3.amazonaws.com/202206-informe-ministerio.csv
- **Registros**: ~28,000 vuelos
- **Formato**: CSV con delimitador `;`
- **Periodo**: 01/01/2022 - 30/06/2022

### Detalles de Aeropuertos
- **URL**: https://data-engineer-edvai-public.s3.amazonaws.com/aeropuertos_detalle.csv
- **Registros**: 54 aeropuertos argentinos
- **Formato**: CSV con delimitador `;`

### Schema Tabla 1: aeropuerto_tabla

| Campo | Tipo | Descripción |
|-------|------|-------------|
| fecha | DATE | Fecha del vuelo (YYYY-MM-DD) |
| horaUTC | STRING | Hora UTC del vuelo |
| clase_de_vuelo | STRING | Tipo de vuelo (Regular, Privado, etc.) |
| clasificacion_de_vuelo | STRING | Doméstico/Internacional |
| tipo_de_movimiento | STRING | Aterrizaje/Despegue |
| aeropuerto | STRING | Código IATA del aeropuerto |
| origen_destino | STRING | Código del aeropuerto de origen/destino |
| aerolinea_nombre | STRING | Nombre de la aerolínea |
| aeronave | STRING | Modelo de la aeronave |
| pasajeros | INT | Cantidad de pasajeros |

### Schema Tabla 2: aeropuerto_detalles_tabla

| Campo | Tipo | Descripción |
|-------|------|-------------|
| aeropuerto | STRING | Código del aeropuerto |
| oac | STRING | Código OACI |
| iata | STRING | Código IATA |
| tipo | STRING | Tipo de aeropuerto |
| denominacion | STRING | Nombre completo del aeropuerto |
| coordenadas_latitud | STRING | Latitud geográfica |
| coordenadas_longitud | STRING | Longitud geográfica |
| elev | FLOAT | Elevación en metros |
| uom_elev | STRING | Unidad de medida de elevación |
| ref | STRING | Referencia geográfica |
| distancia_ref | FLOAT | Distancia a referencia |
| direccion_ref | STRING | Dirección a referencia |
| condicion | STRING | Condición operativa |
| control | STRING | Tipo de control |
| region | STRING | Región geográfica |
| uso | STRING | Uso del aeropuerto |
| trafico | STRING | Tipo de tráfico |
| sna | STRING | Sistema nacional de aeropuertos |
| concesionado | STRING | Estado de concesión |
| provincia | STRING | Provincia argentina |

## 🔧 Requisitos Previos

- Contenedor Hadoop/Hive ejecutándose
- Apache Spark instalado y configurado
- Apache Airflow instalado y funcionando
- Python 3.8+ con PySpark
- HDFS accesible (hdfs://172.17.0.2:9000)
- Java 11 instalado
- Acceso a internet para descarga de datos

## 🚀 Pipeline Completo

```
┌─────────────────────────────────────────────────────────────┐
│         PASO 1: INGEST (Descarga + HDFS)                    │
│  CSV Files (S3) → /home/hadoop/landing → HDFS:/ingest      │
│  • 2021-informe-ministerio.csv (32 MB)                      │
│  • 202206-informe-ministerio.csv (22 MB)                    │
│  • aeropuertos_detalle.csv (136 KB)                         │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         PASO 2: CREACIÓN DE TABLAS (Hive)                   │
│  CREATE DATABASE aviacion;                                   │
│  • aeropuerto_tabla (10 columnas)                           │
│  • aeropuerto_detalles_tabla (20 columnas)                  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         PASO 3: PROCESAMIENTO (PySpark)                      │
│  process_aviacion_spark.py                                   │
│  • Leer CSV desde HDFS                                       │
│  • Union de 2021 + 2022 (unionByName)                       │
│  • Normalizar columnas (tildes, paréntesis)                 │
│  • Filtrar vuelos internacionales                           │
│  • Rellenar NULL con 0                                      │
│  • Convertir fechas DD/MM/YYYY → DATE                       │
│  • JOIN vuelos + aeropuertos                                │
│  • Escribir a Hive (.saveAsTable)                           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         PASO 4: ORQUESTACIÓN (Airflow DAG)                   │
│  aviacion_processing_spark_dag                               │
│  inicio → crear_tablas → procesar_spark → verificar → fin  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         PASO 5-10: ANÁLISIS (Hive SQL)                       │
│  • Punto 5: DESCRIBE (tipos de datos)                       │
│  • Punto 6: COUNT vuelos (dic 2021 - ene 2022)              │
│  • Punto 7: SUM pasajeros (Aerolíneas Argentinas)           │
│  • Punto 8: Tablero con ciudades (JOIN)                     │
│  • Punto 9: Top 10 aerolíneas (GROUP BY + ORDER BY)         │
│  • Punto 10: Top 10 aeronaves Buenos Aires                  │
└─────────────────────────────────────────────────────────────┘
```

## 📖 Guías de Uso

### Ejecución Paso a Paso (Como se Ejecutó en Consola)

#### PASO 1: Crear Tablas en Hive

```bash
# Terminal 1: Acceder al contenedor
docker exec -it edvai_hadoop bash
su hadoop

# Entrar a Hive
hive
```

Dentro de Hive CLI:

```sql
CREATE DATABASE IF NOT EXISTS aviacion;

USE aviacion;

-- Tabla 1: Vuelos (Schema según PDF Página 2)
CREATE TABLE IF NOT EXISTS aeropuerto_tabla (
    fecha DATE,
    horaUTC STRING,
    clase_de_vuelo STRING,
    clasificacion_de_vuelo STRING,
    tipo_de_movimiento STRING,
    aeropuerto STRING,
    origen_destino STRING,
    aerolinea_nombre STRING,
    aeronave STRING,
    pasajeros INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");

-- Tabla 2: Detalles Aeropuertos (Schema según PDF Página 3)
CREATE TABLE IF NOT EXISTS aeropuerto_detalles_tabla (
    aeropuerto STRING,
    oac STRING,
    iata STRING,
    tipo STRING,
    denominacion STRING,
    coordenadas_latitud STRING,
    coordenadas_longitud STRING,
    elev FLOAT,
    uom_elev STRING,
    ref STRING,
    distancia_ref FLOAT,
    direccion_ref STRING,
    condicion STRING,
    control STRING,
    region STRING,
    uso STRING,
    trafico STRING,
    sna STRING,
    concesionado STRING,
    provincia STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");

SHOW TABLES;

exit;
```

#### PASO 2: Crear y Ejecutar Script de Ingest

```bash
# Terminal 2: Abrir otra terminal y acceder al contenedor
docker exec -it edvai_hadoop bash
su hadoop
cd /home/hadoop/scripts

# Crear el archivo con nano
nano ingest_aviacion.sh
```

**Copiar el contenido completo del script desde:**  
`ejercicios-Finales/ejercicio-1/scripts/ingest_aviacion.sh`

**Guardar y salir de nano:**
```
Ctrl + O → Enter → Ctrl + X
```

**Dar permisos y ejecutar:**

```bash
chmod +x ingest_aviacion.sh
bash ingest_aviacion.sh
```

**Salida esperada:**
```
==========================================
✈️  AVIACIÓN CIVIL - DESCARGA DE DATOS
==========================================
✅ Directorio creado: /home/hadoop/landing
✅ Descarga exitosa: 2021-informe-ministerio.csv
✅ Descarga exitosa: 202206-informe-ministerio.csv
✅ Descarga exitosa: aeropuertos_detalle.csv
✅ Todos los archivos subidos
✅ INGEST COMPLETADO EXITOSAMENTE
```

#### PASO 3: Crear y Ejecutar Script de Procesamiento Spark

```bash
# En la misma terminal (o abrir otra)
docker exec -it edvai_hadoop bash
su hadoop
cd /home/hadoop/scripts

# Crear el archivo con nano
nano process_aviacion_spark.py
```

**Copiar el contenido completo del script desde:**  
`ejercicios-Finales/ejercicio-1/scripts/process_aviacion_spark.py`

**Guardar y salir de nano:**
```
Ctrl + O → Enter → Ctrl + X
```

**Ejecutar con Spark:**

```bash
spark-submit process_aviacion_spark.py
```

**Salida esperada:**
```
============================================================
✈️ PROCESAMIENTO DE DATOS DE AVIACIÓN CON PYSPARK
============================================================
✅ Sesión de Spark creada exitosamente
✅ Datos 2021 cargados: 115000 registros
✅ Datos 2022 cargados: 28000 registros
✅ Unión de datasets completada
✅ Vuelos internacionales excluidos
✅ Datos insertados en Hive
✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE
```

#### PASO 4: Crear DAG de Airflow

```bash
# Acceder al contenedor
docker exec -it edvai_hadoop bash
su hadoop
cd /home/hadoop/airflow/dags

# Crear DAG
nano aviacion_spark_dag.py
```

**Copiar el contenido completo del script desde:**  
`ejercicios-Finales/ejercicio-1/airflow/aviacion_spark_dag.py`

**Guardar:** `Ctrl + O → Enter → Ctrl + X`

**Reiniciar Airflow y ejecutar:**

```bash
# Reiniciar scheduler
pkill -f "airflow scheduler"
sleep 3
nohup airflow scheduler > /tmp/scheduler.log 2>&1 &

# Activar DAG
airflow dags unpause aviacion_processing_spark_dag

# Ejecutar DAG
airflow dags trigger aviacion_processing_spark_dag
```

#### PASO 5: Ejecutar Consultas de Negocio

```bash
# Entrar a Hive
hive

# Usar la base de datos
USE aviacion;

-- Punto 6: Vuelos entre 01/12/2021 y 31/01/2022
SELECT COUNT(*) as total_vuelos
FROM aeropuerto_tabla
WHERE fecha BETWEEN '2021-12-01' AND '2022-01-31';

-- Punto 7: Pasajeros de Aerolíneas Argentinas
SELECT SUM(pasajeros) as total_pasajeros
FROM aeropuerto_tabla
WHERE aerolinea_nombre = 'AEROLINEAS ARGENTINAS SA'
AND fecha BETWEEN '2021-01-01' AND '2022-06-30';

-- Ver archivo queries_aviacion.sql para más consultas

exit;
```

## 🎯 Resultados Esperados

### Datos Procesados
- **Total registros vuelos**: 143,000 (después de filtrar internacionales)
- **Registros aeropuertos**: 54
- **Vuelos internacionales excluidos**: 67,941
- **Valores NULL tratados**: Pasajeros, distancia_ref
- **Formato de fechas**: DD/MM/YYYY → YYYY-MM-DD

### Análisis de Negocio

**Punto 6 - Vuelos Diciembre 2021 - Enero 2022**:
- Total: 57,984 vuelos

**Punto 7 - Pasajeros Aerolíneas Argentinas (2021-2022)**:
- Total: 7,484,860 pasajeros
- Representa ~70% del mercado

**Punto 9 - Top 3 Aerolíneas**:
1. AEROLINEAS ARGENTINAS SA: 7,484,860 pasajeros
2. JETSMART AIRLINES S.A.: 1,511,650 pasajeros
3. FB LÍNEAS AÉREAS - FLYBONDI: 1,482,473 pasajeros

**Punto 10 - Top 3 Aeronaves Buenos Aires**:
1. EMB-ERJ190100IGW: 12,470 despegues
2. CE-150-L: 8,117 despegues
3. CE-152: 7,980 despegues

## 📝 Notas Importantes

### Correcciones Aplicadas al Script PySpark

**1. Normalización de Columnas con Paréntesis**

Problema: `Clase de Vuelo (todos los vuelos)` no se normalizaba correctamente.

```python
def normalizar_nombre_columna(nombre):
    nombre = nombre.lower()
    nombre = nombre.replace('ó', 'o').replace('í', 'i')
    nombre = nombre.replace('á', 'a').replace('é', 'e')
    # CORRECCIÓN: Eliminar paréntesis y su contenido
    nombre = re.sub(r'\s*\([^)]*\)', '', nombre)
    return nombre
```

**2. Mapeo de Columnas de Aeropuertos**

Problema: Las columnas reales no coincidían con las esperadas.

```python
# Corrección aplicada:
df_aeropuertos_final = df_aeropuertos.select(
    col('local').alias('aeropuerto'),     # local → aeropuerto
    col('oaci').alias('oac'),             # oaci → oac
    col('latitud').alias('coordenadas_latitud'),
    col('longitud').alias('coordenadas_longitud'),
    # ... resto de columnas
)
```

### Diferencias: Pandas vs PySpark

| Operación | Pandas | PySpark |
|-----------|--------|---------|
| Lectura CSV | `pd.read_csv()` | `spark.read.csv()` |
| Concatenar | `pd.concat([df1, df2])` | `df1.unionByName(df2)` |
| Filtrar | `df[df['col'] == val]` | `df.filter(col('col') == val)` |
| NULL a 0 | `df['col'].fillna(0)` | `when(col('col').isNull(), 0)` |
| Fechas | `pd.to_datetime()` | `to_date(col('fecha'), 'dd/MM/yyyy')` |
| Escribir Hive | `LOAD DATA` | `.write.saveAsTable()` |

### Configuración de Entorno

```bash
# Variables de entorno necesarias
export HADOOP_HOME=/home/hadoop/hadoop
export SPARK_HOME=/home/hadoop/spark
export HIVE_HOME=/home/hadoop/hive
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$SPARK_HOME/bin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$PATH
```

## 🔧 Troubleshooting

### Problema: "cannot resolve 'clase de vuelo'"
**Causa**: Función normalizar no eliminaba paréntesis  
**Solución**: Usar `re.sub(r'\s*\([^)]*\)', '', nombre)`

### Problema: "cannot resolve 'aeropuerto' (tabla aeropuertos)"
**Causa**: Columna real es `local`, no `aeropuerto`  
**Solución**: Usar `col('local').alias('aeropuerto')`

### Problema: "DAG no aparece en Airflow"
**Causa**: Scheduler no detectó cambios  
**Solución**:
```bash
pkill -f "airflow scheduler"
nohup airflow scheduler > /tmp/scheduler.log 2>&1 &
sleep 10
airflow dags list | grep aviacion
```

### Problema: "java: command not found"
**Causa**: `JAVA_HOME` incorrecto  
**Solución**:
```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

## 🔗 Referencias

- [PySpark SQL Functions](https://spark.apache.org/docs/latest/api/python/reference/pyspark.sql/functions.html)
- [Hive Language Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual)
- [Spark + Hive Integration](https://spark.apache.org/docs/latest/sql-data-sources-hive-tables.html)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Datos Abiertos Argentina - Aviación](https://datos.gob.ar/lv/dataset/transporte-aterrizajes-despegues-procesados-por-administracion-nacional-aviacion-civil-anac)

## 📧 Contacto

Para consultas sobre el pipeline de aviación civil, contactar al equipo de Data Engineering de Edvai.

---

**Cliente**: Administración Nacional de Aviación Civil  
**Autor**: Data Engineering Team - Edvai  
**Fecha**: 2025-11-24  
**Versión**: 2.0 (PySpark - Sin Pandas)  
**Tecnología Principal**: Apache Spark + Airflow + Hive
