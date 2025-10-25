# Imágenes - Ejercicio 8

Esta carpeta contiene las capturas de pantalla que documentan la ejecución exitosa del pipeline de procesamiento de datos NYC Taxi.

## 📸 Capturas Incluidas

### 1️⃣ **ejercicio1-create-tripdata.jpg**
**Descripción**: Creación de la base de datos `tripdata` y tabla externa `airport_trips` en Hive.

**Contenido**:
- ✅ Creación de base de datos `tripdata`
- ✅ Definición de tabla externa `airport_trips`
- ✅ Configuración de esquema con columnas específicas
- ✅ Verificación de tablas creadas
- ✅ Metadatos de la tabla (tipo EXTERNAL, formato Parquet)

**Comandos mostrados**:
```sql
CREATE DATABASE IF NOT EXISTS tripdata;
USE tripdata;
CREATE EXTERNAL TABLE IF NOT EXISTS airport_trips (...);
SHOW TABLES;
```

### 2️⃣ **ejercicio2-describe-airporttrips.jpg**
**Descripción**: Verificación del esquema y metadatos de la tabla `airport_trips`.

**Contenido**:
- ✅ Esquema detallado de la tabla
- ✅ Información de la base de datos
- ✅ Propietario y fechas de creación
- ✅ Ubicación en HDFS
- ✅ Configuración de almacenamiento (Parquet)
- ✅ Parámetros de serialización

**Comando mostrado**:
```sql
DESCRIBE FORMATTED airport_trips;
```

### 3️⃣ **ejercicio5-airflow.jpg**
**Descripción**: Interfaz de Apache Airflow mostrando el DAG `airport_trips_processing` ejecutándose exitosamente.

**Contenido**:
- ✅ Vista de grafo del DAG
- ✅ Estado de todas las tareas (SUCCESS)
- ✅ Flujo secuencial: inicio → ingesta → procesamiento → verificación → fin
- ✅ Información del DAG (descripción, programación, etc.)
- ✅ Métricas de ejecución
- ✅ Logs de tareas individuales

**Tareas del DAG**:
1. `inicio` - Tarea dummy de inicio
2. `ingesta_datos` - Descarga e ingesta de archivos
3. `procesa_spark` - Procesamiento con Spark
4. `verifica_tabla_hive` - Verificación de resultados
5. `fin_proceso` - Tarea dummy de finalización

## 🎯 Propósito de las Imágenes

Estas capturas de pantalla documentan:

1. **Configuración inicial**: Establecimiento de la infraestructura de datos
2. **Verificación de esquemas**: Validación de la estructura de datos
3. **Orquestación exitosa**: Ejecución completa del pipeline automatizado

## 📊 Métricas Visualizadas

- **Tiempo de ejecución**: ~2-3 minutos total
- **Registros procesados**: ~2.7 millones
- **Archivos procesados**: 2 archivos Parquet
- **Resultado final**: 1 registro filtrado e insertado
- **Estado del DAG**: SUCCESS en todas las tareas

## 🔍 Detalles Técnicos

### Hive
- **Base de datos**: `tripdata`
- **Tabla**: `airport_trips` (EXTERNAL)
- **Formato**: Parquet
- **Ubicación**: `/user/hive/warehouse/tripdata.db/airport_trips`

### Airflow
- **DAG ID**: `airport_trips_processing`
- **Propietario**: `hadoop`
- **Programación**: Manual (sin schedule)
- **Tags**: `['spark', 'hive', 'etl']`

### Datos
- **Fuente**: NYC Taxi Data (Yellow Taxi)
- **Período**: Enero y Febrero 2021
- **Filtros**: Aeropuertos + pago en efectivo
- **Resultado**: 1 viaje filtrado
