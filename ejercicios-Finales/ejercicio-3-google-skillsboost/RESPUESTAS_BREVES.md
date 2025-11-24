# Ejercicio 3 - Respuestas Resumidas

## Google Cloud Dataprep - Respuestas Concisas

### 1. ¿Para qué se utiliza Data Prep?
Servicio **sin código** para limpiar, transformar y enriquecer datos visualmente antes de cargarlos en BigQuery.

### 2. ¿Qué cosas se pueden realizar con DataPrep?
Limpieza, transformaciones, JOIN, filtrado, agregaciones, normalización y detección de anomalías.

### 3. ¿Por qué otra/s herramientas lo podrías reemplazar? ¿Por qué?
**PySpark** (control total, procesamiento masivo), **dbt** (SQL versionado, CI/CD), **Dataflow** (streaming), **Pandas** (scripts personalizados). Depende de si el equipo programa y necesita código versionado.

### 4. ¿Cuáles son los casos de uso comunes?
Preparación para BigQuery, integración de fuentes múltiples, limpieza de logs, preparación para ML, migración de datos, validación de calidad.

### 5. ¿Cómo se cargan los datos?
Desde **Cloud Storage** (CSV, JSON, Parquet), **BigQuery**, **Cloud SQL**, **Google Sheets** o **URLs HTTP**.

### 6. ¿Qué tipos de datos se pueden preparar?
CSV, JSON, Avro, Parquet, Excel. Tipos: String, Int, Float, Date, Timestamp, Arrays, Structs. Hasta **2 TB** por dataset.

### 7. ¿Qué pasos para limpiar y transformar?
Importar → Detectar anomalías → Eliminar columnas → Renombrar → Cambiar tipos → Manejar nulos → Eliminar duplicados → Filtrar → Calcular columnas → JOIN → Agregar → Exportar.

### 8. ¿Cómo automatizar tareas?
**Scheduling** (diario/semanal), **API** (trigger programático), **Cloud Composer** (Airflow), **Cloud Functions** (trigger por archivo), **Parámetros dinámicos**.

### 9. ¿Qué visualizaciones se pueden crear?
Histogramas, column profile, distribución de valores, data quality score, missing values chart, outlier detection, matriz de correlación. **No es BI completo** (solo EDA).

### 10. ¿Cómo garantizar calidad de datos?
**Data Quality Rules** (NOT NULL, IN, BETWEEN, regex), **sugerencias automáticas**, **validación pre/post proceso**, **alertas**, **monitoreo continuo** (Cloud Logging/Monitoring), **testing de recetas**.

---

## Arquitectura GCP Resumida

```
AWS S3 (Parquet) ──┐
                   ├─> GCS ──> Dataprep ──> BigQuery ─┬─> Looker Studio (BI)
Cloud SQL ─────────┘                                   └─> Vertex AI (ML)
                          ↑
                   Cloud Composer (orquestación)
```

**Componentes:**
- **Ingesta**: S3 → GCS (Transfer Service), Cloud SQL → GCS (export)
- **Procesamiento**: Cloud Dataprep (transformaciones sin código)
- **Almacenamiento**: BigQuery (particionado por fecha)
- **BI**: Looker Studio (dashboards)
- **ML**: Vertex AI AutoML (regresión lineal)
- **Orquestación**: Cloud Composer (Airflow)

**Costo:** ~$81/mes

---

**✅ LAB Completado:** [Adjuntar captura `images/lab-completed.png`]

