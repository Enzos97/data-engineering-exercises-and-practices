# Ejercicios Finales - Data Engineering EDVai

## 📋 Índice de Ejercicios

### ✈️ Ejercicio Final 1 - Aviación Civil (Airflow + PySpark + Hive)

**Tecnologías:** Apache Airflow, PySpark, Apache Hive, HDFS  
**Dataset:** 143,000 vuelos domésticos argentinos (2021-2022)  
**Estado:** ✅ Completado

**Puntos desarrollados:**
- ✅ Ingest automatizado (S3 → HDFS)
- ✅ Transformaciones PySpark (sin Pandas)
- ✅ Pipeline Airflow
- ✅ 6 consultas de análisis SQL
- ✅ Conclusiones y recomendaciones
- ✅ Arquitectura alternativa (Híbrida: On-Premise + Cloud)

📁 **Carpeta:** [`ejercicio-1/`](./ejercicio-1/)

**Documentación:**
- [`README.md`](./ejercicio-1/README.md) - Documentación principal
- [`SOLUCION_COMPLETA_EJERCICIO_1.md`](./ejercicio-1/SOLUCION_COMPLETA_EJERCICIO_1.md) - Guía paso a paso
- [`CONCLUSIONES_Y_ARQUITECTURA.md`](./ejercicio-1/CONCLUSIONES_Y_ARQUITECTURA.md) - Análisis completo
- [`TESTEAR_EN_HIVE.md`](./ejercicio-1/TESTEAR_EN_HIVE.md) - Testing en Hive

---

### 🚗 Ejercicio Final 2 - Car Rental Analytics (NiFi + Airflow + PySpark + Hive)

**Tecnologías:** Apache Airflow (Padre-Hijo), PySpark, Apache Hive, HDFS  
**Dataset:** 4,844 alquileres de vehículos USA (50 estados)  
**Estado:** ✅ Completado

**Puntos desarrollados:**
- ✅ Ingest (S3 + georef USA → HDFS)
- ✅ Transformaciones PySpark (JOIN, filtros, normalización)
- ✅ Patrón Airflow Padre-Hijo
- ✅ 6 consultas de negocio con datos reales
- ✅ Conclusiones con 14 recomendaciones estratégicas
- ✅ Arquitectura alternativa (Cloud AWS/GCP vs On-Premise)

📁 **Carpeta:** [`ejercicio-2/`](./ejercicio-2/)

**Documentación:**
- [`README.md`](./ejercicio-2/README.md) - Documentación principal con resultados reales
- [`GUIA_EJECUCION.md`](./ejercicio-2/GUIA_EJECUCION.md) - Guía detallada paso a paso
- [`CONCLUSIONES_Y_ARQUITECTURA.md`](./ejercicio-2/CONCLUSIONES_Y_ARQUITECTURA.md) - Análisis completo con datos reales
- [`RESUMEN_PROYECTO.md`](./ejercicio-2/RESUMEN_PROYECTO.md) - Resumen ejecutivo

**Hallazgos clave:**
- 🚗 Tesla domina el mercado premium (35% del top 10)
- ⚡ 771 alquileres ecológicos (15.9% del total)
- ⭐ Rating promedio excepcional: 4.98/5.0
- 📈 Crecimiento 2010-2015: +269%

---

### ☁️ Ejercicio Final 3 - Google Cloud Dataprep (Google Skills Boost LAB)

**Tecnologías:** Google Cloud Dataprep, BigQuery, Vertex AI, Looker Studio  
**Tipo:** LAB práctico + Preguntas teóricas + Arquitectura  
**Estado:** ✅ Completado

**Puntos desarrollados:**
- ✅ LAB: "Creating a Data Transformation Pipeline with Cloud Dataprep"
- ✅ 10 preguntas sobre Data Prep de GCP (respondidas)
- ✅ Arquitectura GCP completa (Ingesta → Procesamiento → DW → BI → ML)

📁 **Carpeta:** [`ejercicio-3/`](./ejercicio-3/)

**Documentación:**
- [`README.md`](./ejercicio-3/README.md) - Respuestas detalladas + Arquitectura
- [`RESPUESTAS_BREVES.md`](./ejercicio-3/RESPUESTAS_BREVES.md) - Resumen conciso
- [`images/`](./ejercicio-3/images/) - Capturas de pantalla del LAB

**Arquitectura propuesta:**
```
AWS S3 + Cloud SQL → GCS → Dataprep → BigQuery → Looker Studio + Vertex AI
```

**Costo estimado:** ~$81/mes

---

## 📊 Comparativa de Ejercicios

| Aspecto | Ejercicio 1 | Ejercicio 2 | Ejercicio 3 |
|---------|-------------|-------------|-------------|
| **Stack** | On-Premise | On-Premise | Cloud (GCP) |
| **Orquestación** | Airflow (simple) | Airflow (Padre-Hijo) | Cloud Composer |
| **Procesamiento** | PySpark | PySpark | Dataprep (no-code) |
| **DW** | Hive | Hive | BigQuery |
| **Registros** | 143,000 | 4,844 | Variable |
| **Complejidad** | Media | Alta | Baja (UI visual) |
| **Curva aprendizaje** | Alta (código) | Alta (código) | Baja (sin código) |
| **Escalabilidad** | Limitada (hardware) | Limitada (hardware) | Ilimitada (cloud) |

---

## 🎯 Skills Desarrollados

### Técnicos
- ✅ Apache Airflow (DAGs simples y complejos con patrón Padre-Hijo)
- ✅ PySpark (transformaciones, JOINs, unionByName, saveAsTable)
- ✅ Apache Hive (CREATE TABLE, particionamiento, consultas SQL complejas)
- ✅ HDFS (almacenamiento distribuido)
- ✅ Bash Scripting (automatización de ingest)
- ✅ Google Cloud Platform (Dataprep, BigQuery, Vertex AI)
- ✅ Git (control de versiones)
- ✅ Docker (contenedorización)

### Analíticos
- ✅ Análisis exploratorio de datos (EDA)
- ✅ Limpieza y transformación de datos
- ✅ Normalización de columnas
- ✅ Manejo de valores nulos y outliers
- ✅ JOINs complejos entre múltiples fuentes
- ✅ Agregaciones y GROUP BY
- ✅ Visualización de resultados

### Estratégicos
- ✅ Diseño de arquitecturas de datos (on-premise, cloud, híbridas)
- ✅ Análisis de costos (CAPEX vs OPEX)
- ✅ Elaboración de conclusiones de negocio basadas en datos
- ✅ Recomendaciones estratégicas con justificación cuantitativa
- ✅ Documentación técnica profesional
- ✅ Propuestas de arquitecturas alternativas

---

## 📚 Documentación Común

### Formato de Documentación
- ✅ README principal con arquitectura completa
- ✅ Guías paso a paso con comandos ejecutables
- ✅ Conclusiones y recomendaciones basadas en datos reales
- ✅ Propuestas de arquitecturas alternativas
- ✅ Troubleshooting con soluciones probadas
- ✅ Diagramas ASCII de arquitectura
- ✅ Referencias y contacto

### Estilo de Código
- ✅ Scripts comentados y autoexplicativos
- ✅ Logging detallado con emojis (📊, ✅, ❌)
- ✅ Validaciones y manejo de errores
- ✅ Variables de entorno documentadas
- ✅ Funciones reutilizables

---

## 🎓 Certificaciones y Badges

### Google Skills Boost
- ✅ Creating a Data Transformation Pipeline with Cloud Dataprep
- 📸 [Ver captura](./ejercicio-3/images/lab-completed.png)

---

## 🔧 Requisitos Previos (General)

### Software
- Docker (contenedor Hadoop)
- Apache Spark 3.2.0
- Apache Airflow 2.x
- Apache Hive 3.x
- Python 3.8+
- Java 11
- Git

### Conocimientos
- SQL (avanzado)
- Python (intermedio)
- Bash scripting (básico)
- Arquitectura de datos (conceptos)

---

## 🚀 Quick Start (Por Ejercicio)

### Ejercicio 1 - Aviación
```bash
cd ejercicio-1
# Ver README.md para instrucciones completas
cat SOLUCION_COMPLETA_EJERCICIO_1.md
```

### Ejercicio 2 - Car Rental
```bash
cd ejercicio-2
# Ver README.md para instrucciones completas
cat GUIA_EJECUCION.md
```

### Ejercicio 3 - Cloud Dataprep
```bash
cd ejercicio-3
# Ver respuestas y arquitectura
cat README.md
cat RESPUESTAS_BREVES.md
```

---

## 📈 Resultados Destacados

### Ejercicio 1 - Aviación
- **143,000 vuelos** procesados
- **67,941 vuelos internacionales** excluidos
- **Aerolíneas Argentinas**: 70% del mercado doméstico
- **Rating promedio**: 4.97/5.0
- **Pipeline completo**: ~10 minutos

### Ejercicio 2 - Car Rental
- **4,844 alquileres** procesados
- **Tesla Model 3**: #1 con 288 alquileres
- **771 alquileres ecológicos** (15.9%)
- **Rating promedio**: 4.98/5.0
- **Consultas SQL**: ~3.8 segundos promedio

### Ejercicio 3 - Cloud Dataprep
- **LAB completado** en 1h 15min
- **10 preguntas** respondidas
- **Arquitectura GCP** completa diseñada
- **Costo estimado**: $81/mes

---

## 📧 Contacto

**Autor:** Data Engineering Team - EDVai  
**Fecha:** Noviembre 2025  
**Repositorio:** [GitHub](https://github.com/)

---

## ⚖️ Licencia

Este proyecto es parte del programa de Data Engineering de EDVai.  
Material educativo - Todos los derechos reservados.

