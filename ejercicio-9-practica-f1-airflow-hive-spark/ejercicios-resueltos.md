# Ejercicios Resueltos - Práctica F1: Airflow + Hive + Spark

Este documento contiene la resolución completa de todos los ejercicios del pipeline de procesamiento de datos de Formula 1.

## 📋 Resumen de Ejercicios

| Ejercicio | Descripción | Estado | Tiempo |
|-----------|-------------|--------|--------|
| 1 | Crear base de datos y tablas externas en Hive | ✅ Completado | ~5 min |
| 2 | Verificar esquemas de tablas | ✅ Completado | ~1 min |
| 3 | Script de descarga e ingesta | ✅ Completado | ~20 seg |
| 4 | Procesamiento con Spark | ✅ Completado | ~2-3 min |
| 5 | Orquestación con Airflow | ✅ Completado | ~5-10 min |

---

## 📥 Ejercicio 3: Script de Descarga e Ingesta

### Objetivo
Crear script automatizado para descargar archivos CSV de Formula 1 desde S3 e ingerirlos en HDFS.

### Script Creado: `f1_download_and_ingest.sh`

**Funcionalidades implementadas:**
- ✅ Verificación de servicios HDFS
- ✅ Descarga de 4 archivos CSV desde URLs públicas de S3
- ✅ Validación de conectividad
- ✅ Subida automática a HDFS
- ✅ Limpieza de archivos temporales

### Ejecución del Script

```bash
# Hacer ejecutable
chmod +x f1_download_and_ingest.sh

# Ejecutar script
./f1_download_and_ingest.sh
```

### Resultados de la Ejecución

```
=== INICIANDO DESCARGA E INGESTA A HDFS ===
Fecha: Mon Nov  3 01:27:25 -03 2025

1. Verificando servicios HDFS...
✅ Servicios HDFS activos

2. Verificando directorio HDFS: /user/hadoop/f1/raw
✅ Directorio HDFS creado/verificado

3. Probando conectividad con URLs...
✅ Conectividad OK

4. Descargando archivos...
✅ Archivos descargados correctamente
   - results.csv: 1.7M
   - drivers.csv: 93K
   - constructors.csv: 18K
   - races.csv: 161K

5. Subiendo archivos a HDFS...
✅ Archivos subidos correctamente a HDFS

6. Verificando carga en HDFS...
Found 4 items
-rw-r--r--   1 hadoop supergroup     17.1 K 2025-11-03 01:27 /user/hadoop/f1/raw/constructors.csv
-rw-r--r--   1 hadoop supergroup     92.2 K 2025-11-03 01:27 /user/hadoop/f1/raw/drivers.csv
-rw-r--r--   1 hadoop supergroup    160.5 K 2025-11-03 01:27 /user/hadoop/f1/raw/races.csv
-rw-r--r--   1 hadoop supergroup      1.6 M 2025-11-03 01:27 /user/hadoop/f1/raw/results.csv

7. Limpiando archivos locales...
=== PROCESO COMPLETADO EXITOSAMENTE ===
✅ Archivos disponibles en HDFS: /user/hadoop/f1/raw
📅 Fecha finalización: Mon Nov  3 01:27:45 -03 2025
```

### Resultado
✅ **4 archivos CSV descargados y subidos a HDFS**
✅ **Total de datos**: ~1.9 MB
✅ **Tiempo de ejecución**: ~20 segundos
✅ **Ubicación HDFS**: `/user/hadoop/f1/raw/`

---

## ⚡ Ejercicio 4: Procesamiento con Spark

### Objetivo
Procesar datos con Spark para generar resultados y guardarlos en ubicaciones de tablas externas de Hive.

### Script Creado: `process_f1_data.py`

**Funcionalidades implementadas:**
- ✅ Lectura de archivos CSV desde HDFS
- ✅ JOIN entre tablas para relacionar datos
- ✅ Punto 4a: Encuentra corredores con mayor cantidad de puntos en la historia
- ✅ Punto 4b: Encuentra constructores con más puntos en Spanish Grand Prix 1991
- ✅ Generación de archivos CSV para tablas externas de Hive
- ✅ Estadísticas y validaciones de datos

### Ejecución del Script

```bash
# Hacer ejecutable
chmod +x process_f1_data.py

# Ejecutar con Spark
spark-submit process_f1_data.py
```

### Resultados de la Ejecución

#### Datos Leídos

```
1. 📂 Leyendo archivos CSV desde HDFS...
   ✅ results.csv: 26,759 registros
   ✅ drivers.csv: 861 registros
   ✅ constructors.csv: 212 registros
   ✅ races.csv: 1,125 registros
```

#### Punto 4a: Corredores con Mayor Cantidad de Puntos

```
3. 🏎️ Procesando punto 4a: Corredores con mayor cantidad de puntos...
   ✅ Total de corredores únicos: 861
   📋 Top 10 corredores por puntos:
+---------------+--------------+------------------+------+
|driver_forename|driver_surname|driver_nationality|points|
+---------------+--------------+------------------+------+
|Lewis          |Hamilton      |British           |4820.5|
|Sebastian      |Vettel        |German            |3098.0|
|Max            |Verstappen    |Dutch             |2912.5|
|Fernando       |Alonso        |Spanish           |2329.0|
|Kimi           |Räikkönen     |Finnish           |1873.0|
|Valtteri       |Bottas        |Finnish           |1788.0|
|Nico           |Rosberg       |German            |1594.5|
|Sergio         |Pérez         |Mexican           |1585.0|
|Michael        |Schumacher    |German            |1566.0|
|Charles        |Leclerc       |Monegasque        |1363.0|
+---------------+--------------+------------------+------+
```

**Datos guardados en:** `hdfs://172.17.0.2:9000/user/hive/warehouse/f1.db/driver_results/`

#### Punto 4b: Constructores en Spanish Grand Prix 1991

```
5. 🏁 Procesando punto 4b: Constructores con más puntos en Spanish Grand Prix 1991...
   ✅ Carreras encontradas: 1
   ✅ Total de constructores: 17
   📋 Resultados de constructores en Spanish GP 1991:
+--------------+------------+----------------+-----------------------------------------------------------------+------+
|constructorRef|cons_name   |cons_nationality|url                                                              |points|
+--------------+------------+----------------+-----------------------------------------------------------------+------+
|williams      |Williams    |British         |http://en.wikipedia.org/wiki/Williams_Grand_Prix_Engineering     |14.0  |
|ferrari       |Ferrari     |Italian         |http://en.wikipedia.org/wiki/Scuderia_Ferrari                    |9.0   |
|mclaren       |McLaren     |British         |http://en.wikipedia.org/wiki/McLaren                             |2.0   |
|benetton      |Benetton    |Italian         |http://en.wikipedia.org/wiki/Benetton_Formula                   |1.0   |
|fondmetal     |Fondmetal   |Italian         |http://en.wikipedia.org/wiki/Fondmetal                           |0.0   |
|tyrrell       |Tyrrell     |British         |http://en.wikipedia.org/wiki/Tyrrell_Racing                      |0.0   |
|leyton        |Leyton House|British         |http://en.wikipedia.org/wiki/Leyton_House                        |0.0   |
|brabham       |Brabham     |British         |http://en.wikipedia.org/wiki/Brabham                             |0.0   |
|...           |...         |...             |...                                                               |...   |
+--------------+------------+----------------+-----------------------------------------------------------------+------+
```

**Datos guardados en:** `hdfs://172.17.0.2:9000/user/hive/warehouse/f1.db/constructor_results/`

#### Estadísticas Finales

```
7. ✅ Verificación de datos guardados:
   📊 Resumen de driver_results:
+-------+---------------+--------------+------------------+-----------------+
|summary|driver_forename|driver_surname|driver_nationality|           points|
+-------+---------------+--------------+------------------+-----------------+
|  count|            861|           861|               861|              861|
|   mean|           null|          null|              null|61.77357723577236|
| stddev|           null|          null|              null|294.2850380118803|
|    min|          Adolf|         Abate|          American|              0.0|
|    max|          Óscar|     Étancelin|        Venezuelan|           4820.5|
+-------+---------------+--------------+------------------+-----------------+

   📊 Resumen de constructor_results:
+-------+--------------+---------+----------------+--------------------+------------------+
|summary|constructorRef|cons_name|cons_nationality|                 url|            points|
+-------+--------------+---------+----------------+--------------------+------------------+
|  count|            17|       17|              17|                  17|                17|
|   mean|          null|     null|            null|                null|1.5294117647058822|
| stddev|          null|     null|            null|                null|3.8909774970247444|
|    min|           ags|      AGS|         British|http://en.wikiped...|               0.0|
|    max|      williams| Williams|         Italian|http://en.wikiped...|              14.0|
+-------+--------------+---------+----------------+--------------------+------------------+

✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE
📊 Corredores procesados: 861
📊 Constructores procesados: 17
🛑 Sesión de Spark cerrada
```

### Resultado

✅ **Punto 4a - Corredores con mayor cantidad de puntos:**
- **Total de corredores únicos**: 861
- **Top corredor**: Lewis Hamilton (British) con 4,820.5 puntos
- **Segundo lugar**: Sebastian Vettel (German) con 3,098.0 puntos
- **Tercer lugar**: Max Verstappen (Dutch) con 2,912.5 puntos
- **Puntos promedio**: 61.77 puntos por corredor
- **Datos guardados en**: `/user/hive/warehouse/f1.db/driver_results/`

✅ **Punto 4b - Constructores en Spanish Grand Prix 1991:**
- **Carrera encontrada**: 1 (Spanish Grand Prix 1991)
- **Total de constructores**: 17
- **Top constructor**: Williams (British) con 14.0 puntos
- **Segundo lugar**: Ferrari (Italian) con 9.0 puntos
- **Tercer lugar**: McLaren (British) con 2.0 puntos
- **Puntos promedio**: 1.53 puntos por constructor
- **Datos guardados en**: `/user/hive/warehouse/f1.db/constructor_results/`

✅ **Total de registros procesados:**
- **results.csv**: 26,759 registros
- **drivers.csv**: 861 registros
- **constructors.csv**: 212 registros
- **races.csv**: 1,125 registros

---

## 📊 Resumen de Resultados

### Ejercicio 3 - Descarga e Ingesta
- ✅ **4 archivos CSV** descargados desde S3
- ✅ **1.9 MB** de datos totales
- ✅ **Ubicación HDFS**: `/user/hadoop/f1/raw/`
- ✅ **Tiempo de ejecución**: ~20 segundos

### Ejercicio 4 - Procesamiento Spark
- ✅ **861 corredores** procesados con puntos totales
- ✅ **17 constructores** procesados para Spanish GP 1991
- ✅ **Archivos CSV generados** en ubicaciones de tablas externas
- ✅ **Tiempo de ejecución**: ~2-3 minutos

### Top Resultados

**🏎️ Top 5 Corredores por Puntos:**
1. Lewis Hamilton (British) - 4,820.5 puntos
2. Sebastian Vettel (German) - 3,098.0 puntos
3. Max Verstappen (Dutch) - 2,912.5 puntos
4. Fernando Alonso (Spanish) - 2,329.0 puntos
5. Kimi Räikkönen (Finnish) - 1,873.0 puntos

**🏁 Top 5 Constructores en Spanish GP 1991:**
1. Williams (British) - 14.0 puntos
2. Ferrari (Italian) - 9.0 puntos
3. McLaren (British) - 2.0 puntos
4. Benetton (Italian) - 1.0 punto
5. Resto de constructores - 0.0 puntos

---

## ✅ Verificación de Datos en Hive

Después de ejecutar los scripts, los datos están disponibles en las tablas externas:

```sql
USE f1;

-- Verificar driver_results
SELECT COUNT(*) AS total_drivers FROM driver_results;
-- Resultado: 861

-- Verificar constructor_results
SELECT COUNT(*) AS total_constructors FROM constructor_results;
-- Resultado: 17

-- Top 10 corredores
SELECT * FROM driver_results ORDER BY points DESC LIMIT 10;

-- Constructores en Spanish GP 1991
SELECT * FROM constructor_results ORDER BY points DESC;
```

---

## 📝 Notas Técnicas

### Archivos Procesados
- **results.csv**: 1.6 MB - 26,759 registros
- **drivers.csv**: 92.2 KB - 861 registros
- **constructors.csv**: 17.1 KB - 212 registros
- **races.csv**: 160.5 KB - 1,125 registros

### Transformaciones Realizadas
1. **JOIN results + drivers** → Agrupación por corredor → Suma de puntos
2. **JOIN results + constructors + races** → Filtro Spanish GP 1991 → Agrupación por constructor → Suma de puntos

### Ubicaciones HDFS
- **Datos raw**: `/user/hadoop/f1/raw/`
- **driver_results**: `/user/hive/warehouse/f1.db/driver_results/`
- **constructor_results**: `/user/hive/warehouse/f1.db/constructor_results/`

---

## 🎯 Conclusiones

✅ **Ejercicio 3 completado exitosamente**: Todos los archivos CSV descargados e ingestados en HDFS

✅ **Ejercicio 4 completado exitosamente**: 
- Procesamiento de datos con Spark realizado correctamente
- Top corredores identificados por puntos totales
- Constructores de Spanish GP 1991 procesados
- Archivos CSV generados en ubicaciones correctas para tablas externas

✅ **Pipeline listo para consulta**: Los datos están disponibles en las tablas externas de Hive y pueden ser consultados directamente.

