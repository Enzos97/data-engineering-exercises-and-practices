# Ejercicio Final 3 - Google Cloud Dataprep

## 📋 Google Skills Boost LAB

**Título:** Creating a Data Transformation Pipeline with Cloud Dataprep  
**Duración:** 1 hora 15 minutos  
**Costo:** 5 Créditos  
**Estado:** ✅ Completado

---

## 📝 Respuestas a Preguntas

### 1. ¿Para qué se utiliza Data Prep?

Data Prep es un servicio de preparación de datos **sin código (no-code)** para limpiar, transformar y enriquecer datos de forma visual antes de cargarlos en BigQuery o Cloud Storage.

---

### 2. ¿Qué cosas se pueden realizar con DataPrep?

- ✅ **Limpieza de datos**: Eliminar duplicados, valores nulos, outliers
- ✅ **Transformaciones**: Renombrar columnas, cambiar tipos de datos, crear columnas calculadas
- ✅ **Enriquecimiento**: JOIN de múltiples fuentes, agregar columnas derivadas
- ✅ **Filtrado**: Filtrar filas por condiciones específicas
- ✅ **Agregaciones**: GROUP BY, SUM, AVG, COUNT
- ✅ **Normalización**: Estandarizar formatos (fechas, strings, números)
- ✅ **Detección automática**: Identificar anomalías y sugerir transformaciones

---

### 3. ¿Por qué otra/s herramientas lo podrías reemplazar? ¿Por qué?

| Herramienta | Razón de Reemplazo |
|-------------|-------------------|
| **Apache Spark/PySpark** | Mayor control, procesamiento masivo (TB+), transformaciones complejas |
| **dbt (Data Build Tool)** | Transformaciones SQL versionadas, CI/CD, testing automatizado |
| **Cloud Dataflow** | Procesamiento en streaming, pipelines en tiempo real |
| **Pandas (Python)** | Scripts personalizados, integración con ML, flexibilidad total |
| **Talend / Informatica** | ETL empresarial, conectores legacy, auditoría |

**¿Por qué reemplazar?**
- Si necesitas **código versionado** → dbt o PySpark
- Si necesitas **streaming** → Dataflow
- Si necesitas **control total** → PySpark/Pandas
- Si el equipo **sabe programar** → PySpark (más barato)

**¿Por qué NO reemplazar?**
- Usuarios de negocio sin conocimientos técnicos
- Prototipado rápido
- Presupuesto limitado (pago por uso)

---

### 4. ¿Cuáles son los casos de uso comunes de Data Prep de GCP?

1. **Preparación de datos para BigQuery**: Limpiar CSVs antes de cargar en DW
2. **Integración de fuentes múltiples**: JOIN de Cloud SQL + CSV + JSON
3. **Limpieza de logs**: Parsear logs de aplicaciones, normalizar campos
4. **Preparación para ML**: Feature engineering, one-hot encoding, normalización
5. **Migración de datos**: Transformar datos de legacy a formato moderno
6. **Validación de calidad**: Detectar datos faltantes, duplicados, inconsistencias
7. **Enriquecimiento de datos**: Agregar columnas calculadas, lookups

---

### 5. ¿Cómo se cargan los datos en Data Prep de GCP?

**Fuentes soportadas:**
- ✅ **Cloud Storage (GCS)**: CSV, JSON, Avro, Parquet
- ✅ **BigQuery**: Tablas existentes
- ✅ **Cloud SQL**: MySQL, PostgreSQL
- ✅ **Google Sheets**: Hojas de cálculo
- ✅ **URL HTTP**: Archivos públicos

**Proceso:**
1. Conectar fuente de datos
2. Seleccionar archivo/tabla
3. Data Prep infiere schema automáticamente
4. Preview de datos (primeras 10k filas)
5. Iniciar transformaciones

---

### 6. ¿Qué tipos de datos se pueden preparar en Data Prep de GCP?

**Formatos:**
- CSV, TSV (delimitados)
- JSON (estructurado y semi-estructurado)
- Avro
- Parquet (columnar)
- Excel (.xlsx)
- Text files

**Tipos de datos:**
- String, Integer, Float, Boolean, Date, Timestamp
- Arrays, Structs (JSON anidado)
- Binarios (conversión a base64)

**Tamaño máximo:** Hasta **2 TB** por dataset

---

### 7. ¿Qué pasos se pueden seguir para limpiar y transformar datos en Data Prep de GCP?

**Pipeline típico:**

```
1. IMPORTAR datos → Preview automático
2. DETECTAR anomalías → Sugerencias automáticas
3. ELIMINAR columnas innecesarias → Drop
4. RENOMBRAR columnas → Nombres descriptivos
5. CAMBIAR tipos de datos → String → Date, Int → Float
6. MANEJAR nulos → Reemplazar con 0, media, o eliminar filas
7. ELIMINAR duplicados → Distinct
8. FILTRAR filas → Condiciones WHERE
9. CREAR columnas calculadas → Derivaciones
10. JOIN con otras fuentes → LEFT/INNER/OUTER JOIN
11. AGREGAR (GROUP BY) → SUM, AVG, COUNT
12. EXPORTAR a BigQuery o GCS
```

**Interfaz visual:** Cada paso se registra como "receta" replicable.

---

### 8. ¿Cómo se pueden automatizar tareas de preparación de datos en Data Prep de GCP?

**Métodos de automatización:**

1. **Programar ejecución (Scheduling)**:
   - Diario, semanal, mensual
   - Trigger por llegada de nuevo archivo

2. **API de Dataprep**:
   ```python
   # Ejecutar receta via API
   POST /v4/jobGroups
   {
     "wrangledDataset": {"id": 12345},
     "runParameters": {"overrides": {...}}
   }
   ```

3. **Integración con Cloud Composer (Airflow)**:
   ```python
   from airflow.providers.google.cloud.operators.dataprep import DataprepRunJobOperator
   
   run_dataprep = DataprepRunJobOperator(
       task_id='run_dataprep_recipe',
       recipe_id=12345
   )
   ```

4. **Cloud Functions + Pub/Sub**:
   - Trigger automático cuando llega archivo a GCS
   - Cloud Function ejecuta receta Dataprep

5. **Parámetros dinámicos**:
   - Variables en receta (ej: fecha actual)
   - Sobrescribir valores en tiempo de ejecución

---

### 9. ¿Qué tipos de visualizaciones se pueden crear en Data Prep de GCP?

**Visualizaciones incorporadas:**

- 📊 **Histogramas**: Distribución de valores numéricos
- 📈 **Column profile**: Estadísticas por columna (min, max, media, nulos)
- 🥧 **Value distribution**: Frecuencia de valores categóricos
- 🔢 **Data quality score**: Porcentaje de datos válidos
- 🎯 **Missing values chart**: Porcentaje de nulos por columna
- 📉 **Outlier detection**: Valores fuera de rango esperado
- 🔗 **Relationship matrix**: Correlación entre columnas

**Limitación:** No es una herramienta de BI completa (solo EDA - Exploratory Data Analysis)

**Para visualizaciones avanzadas:**
- Exportar a **Looker Studio** (Data Studio)
- Exportar a **Looker** (BI empresarial)
- Conectar BigQuery con **Tableau** o **Power BI**

---

### 10. ¿Cómo se puede garantizar la calidad de los datos en Data Prep de GCP?

**Mecanismos de calidad:**

1. **Data Quality Rules**:
   ```
   - Column NOT NULL
   - Value IN ('A', 'B', 'C')
   - Range BETWEEN 0 AND 100
   - Regex MATCH '^[A-Z]{2}[0-9]{6}$'
   ```

2. **Sugerencias automáticas**:
   - Detecta outliers (valores extremos)
   - Identifica formatos inconsistentes
   - Sugiere correcciones

3. **Validación pre-proceso**:
   - Schema validation (tipos de datos esperados)
   - Row count validation (número esperado de filas)

4. **Alertas post-proceso**:
   - Email si calidad < threshold (ej: >10% nulos)
   - Detener pipeline si falla validación crítica

5. **Monitoreo continuo**:
   - Cloud Logging: registra cada ejecución
   - Cloud Monitoring: métricas de calidad
   - BigQuery: audit logs

6. **Testing de recetas**:
   - Ejecutar en subset de datos
   - Comparar output esperado vs real
   - Versionado de recetas (rollback si falla)

**Best practice:** Combinar Data Prep con **dbt tests** para validación exhaustiva.

---

## 🏗️ Arquitectura Propuesta: GCP con Data Prep

### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    CAPA DE INGESTA                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐           ┌──────────────┐               │
│  │  AWS S3      │           │  Cloud SQL   │               │
│  │  (Parquet)   │           │  (PostgreSQL)│               │
│  └──────┬───────┘           └──────┬───────┘               │
│         │                          │                        │
│         │ Transfer Service         │ Cloud SQL Connector    │
│         ▼                          ▼                        │
│  ┌────────────────────────────────────┐                    │
│  │     Cloud Storage (GCS)            │                    │
│  │     gs://car-rental-raw/           │                    │
│  │     • parquet files (S3)           │                    │
│  │     • export from Cloud SQL        │                    │
│  └──────────────┬─────────────────────┘                    │
│                 │                                            │
└─────────────────┼────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│              CAPA DE PROCESAMIENTO                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────┐                │
│  │      Cloud Dataprep (Trifacta)         │                │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │                │
│  │  1️⃣ Conectar fuentes:                  │                │
│  │     • GCS (parquet from S3)            │                │
│  │     • Cloud SQL (via connector)        │                │
│  │                                         │                │
│  │  2️⃣ Transformaciones (sin código):     │                │
│  │     • Filtrar datos inconsistentes     │                │
│  │     • Limpiar valores nulos            │                │
│  │     • JOIN de ambas fuentes            │                │
│  │     • Renombrar columnas               │                │
│  │     • Crear columnas calculadas        │                │
│  │     • Normalizar formatos              │                │
│  │                                         │                │
│  │  3️⃣ Validación de calidad:             │                │
│  │     • Detectar outliers                │                │
│  │     • Verificar schema                 │                │
│  │     • Alertas si calidad < 95%         │                │
│  │                                         │                │
│  │  4️⃣ Output:                            │                │
│  │     • Formato: Avro/Parquet            │                │
│  │     • Destino: BigQuery                │                │
│  └────────────────┬───────────────────────┘                │
│                   │                                          │
│                   │ (ejecuta Dataflow jobs)                 │
│                   ▼                                          │
│  ┌────────────────────────────────────────┐                │
│  │      Cloud Dataflow (backend)          │                │
│  │      • Ejecuta transformaciones        │                │
│  │      • Escalado automático             │                │
│  └────────────────┬───────────────────────┘                │
│                   │                                          │
└───────────────────┼──────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│              CAPA DE ALMACENAMIENTO                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────┐                │
│  │         BigQuery (DW)                  │                │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │                │
│  │  Dataset: car_rental_analytics         │                │
│  │  Tables:                                │                │
│  │    • fact_rentals                      │                │
│  │    • dim_vehicles                      │                │
│  │    • dim_customers                     │                │
│  │    • dim_locations                     │                │
│  │                                         │                │
│  │  Features:                              │                │
│  │    • Particionado por fecha            │                │
│  │    • Clustering por location           │                │
│  │    • Compresión automática             │                │
│  └────────────────┬───────────────────────┘                │
│                   │                                          │
└───────────────────┼──────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
┌──────────────────┐   ┌──────────────────┐
│   CAPA DE BI     │   │   CAPA DE ML     │
├──────────────────┤   ├──────────────────┤
│                  │   │                  │
│ Looker Studio    │   │ Vertex AI        │
│ (Data Studio)    │   │ (AutoML)         │
│ ━━━━━━━━━━━━━━━━ │   │ ━━━━━━━━━━━━━━━━ │
│ • Dashboards     │   │ • Regresión      │
│ • KPIs           │   │   Lineal         │
│ • Filtros        │   │ • Predicción de  │
│ • Compartir      │   │   demanda        │
│                  │   │ • AutoML Tables  │
│ Alternativa:     │   │                  │
│ • Looker         │   │ Alternativa:     │
│ • Tableau        │   │ • BigQuery ML    │
│ • Power BI       │   │ • Notebooks      │
│                  │   │                  │
└──────────────────┘   └──────────────────┘

         ┌────────────────────────────┐
         │   ORQUESTACIÓN             │
         ├────────────────────────────┤
         │  Cloud Composer (Airflow)  │
         │  • Schedule diario         │
         │  • Trigger por archivo     │
         │  • Monitoreo               │
         └────────────────────────────┘

         ┌────────────────────────────┐
         │   MONITOREO                │
         ├────────────────────────────┤
         │  • Cloud Logging           │
         │  • Cloud Monitoring        │
         │  • Alertas (email/Slack)   │
         └────────────────────────────┘
```

---

## 📋 Componentes de la Arquitectura

### 1. Ingesta

**AWS S3 → GCS:**
```bash
# Transfer Service (configuración one-time)
gsutil -m cp -r s3://bucket-source/parquet/* gs://car-rental-raw/parquet/
```

**Cloud SQL → GCS:**
```sql
-- Exportar tabla a GCS (desde Cloud SQL)
EXPORT DATA OPTIONS(
  uri='gs://car-rental-raw/sql_export/*.csv',
  format='CSV',
  overwrite=true
) AS
SELECT * FROM rentals WHERE date >= '2024-01-01';
```

---

### 2. Procesamiento (Cloud Dataprep)

**Receta de transformación:**
1. Importar parquet desde GCS
2. Importar export de Cloud SQL
3. JOIN por `rental_id`
4. Filtrar: `WHERE status = 'completed'`
5. Limpiar nulos: `rating` → reemplazar con media
6. Normalizar: `fuelType` → lowercase
7. Crear columna: `revenue = rate_daily * days_rented`
8. Validar: rating BETWEEN 1 AND 5
9. Exportar a BigQuery: `car_rental_analytics.fact_rentals`

---

### 3. Almacenamiento (BigQuery)

```sql
-- Tabla particionada y clusterizada
CREATE TABLE car_rental_analytics.fact_rentals
(
  rental_id INT64,
  rental_date DATE,
  vehicle_id INT64,
  customer_id INT64,
  location STRING,
  fuelType STRING,
  rating INT64,
  revenue FLOAT64
)
PARTITION BY rental_date
CLUSTER BY location, fuelType;
```

---

### 4. BI (Looker Studio)

**Dashboards:**
- 📊 Revenue por mes/ciudad
- 🚗 Vehículos más rentados
- ⭐ Satisfacción por tipo de combustible
- 📍 Mapa de calor por ubicación

---

### 5. ML (Vertex AI)

**Modelo de regresión lineal:**
```python
# Predecir demanda de alquileres
from google.cloud import aiplatform

# AutoML Tables
dataset = aiplatform.TabularDataset.create(
    display_name="car_rental_demand",
    bq_source="bq://project.car_rental_analytics.fact_rentals"
)

model = aiplatform.AutoMLTabularTrainingJob(
    display_name="rental_demand_forecast",
    optimization_objective="minimize-rmse",
)

model.run(
    dataset=dataset,
    target_column="revenue",
    training_fraction_split=0.8,
    validation_fraction_split=0.1,
    test_fraction_split=0.1,
)
```

**Alternativa: BigQuery ML**
```sql
CREATE OR REPLACE MODEL car_rental_analytics.demand_forecast
OPTIONS(
  model_type='LINEAR_REG',
  input_label_cols=['revenue']
) AS
SELECT
  rental_date,
  location,
  fuelType,
  rating,
  revenue
FROM car_rental_analytics.fact_rentals;
```

---

## 🎯 Ventajas de esta Arquitectura

| Ventaja | Descripción |
|---------|-------------|
| ✅ **Sin código** | Equipo de negocio puede transformar datos |
| ✅ **Visual** | Interfaz drag-and-drop, fácil de entender |
| ✅ **Escalable** | Dataflow backend maneja TB de datos |
| ✅ **Integrado** | Nativo con BigQuery, Cloud SQL, GCS |
| ✅ **Económico** | Pago por uso (vs licencias ETL tradicionales) |
| ✅ **Rápido** | Prototipado en minutos, no días |

---

## 💰 Costos Estimados Mensuales

| Servicio | Uso | Costo USD/mes |
|----------|-----|---------------|
| Cloud Storage (GCS) | 100 GB | $2.00 |
| Cloud Dataprep | 100 GB procesados | $15.00 |
| Cloud Dataflow | 10 GB-hours | $5.00 |
| BigQuery (storage) | 200 GB | $4.00 |
| BigQuery (queries) | 1 TB procesados | $5.00 |
| Looker Studio | Gratis | $0.00 |
| Vertex AI (AutoML) | 1 modelo/mes | $50.00 |
| **TOTAL** | | **~$81/mes** |

---

## 📚 Referencias

- [Cloud Dataprep Documentation](https://cloud.google.com/dataprep/docs)
- [BigQuery ML](https://cloud.google.com/bigquery-ml/docs)
- [Vertex AI](https://cloud.google.com/vertex-ai/docs)
- [Looker Studio](https://lookerstudio.google.com/)

---

**Autor:** Data Engineering Team - Edvai  
**Fecha:** 2025-11-24  
**Ejercicio:** Final 3 - Google Cloud Dataprep

