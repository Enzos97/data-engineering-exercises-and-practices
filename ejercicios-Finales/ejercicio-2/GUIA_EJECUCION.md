# 🚀 Guía de Ejecución Paso a Paso - Car Rental Analytics

Esta guía te permite ejecutar y probar cada paso del proyecto de forma individual.

## 📝 Pre-requisitos

```bash
# 1. Verificar que estés en el contenedor Hadoop
docker exec -it edvai_hadoop bash
su hadoop

# 2. Verificar que los servicios estén corriendo
jps

# Debe mostrar:
# - NameNode
# - DataNode
# - ResourceManager
# - NodeManager
```

---

## 🔷 **PASO 1: Copiar Archivos al Contenedor**

### Desde tu máquina local (fuera del contenedor):

```bash
# Navegar al directorio del proyecto
cd ejercicios-Finales/ejercicio-2

# Copiar scripts
docker cp scripts/download_data.sh edvai_hadoop:/home/hadoop/scripts/
docker cp scripts/process_car_rental.py edvai_hadoop:/home/hadoop/scripts/

# Copiar archivos Hive
docker cp hive/car_rental_setup.sql edvai_hadoop:/home/hadoop/hive/
docker cp hive/queries.sql edvai_hadoop:/home/hadoop/hive/

# Copiar DAGs Airflow
docker cp airflow/car_rental_parent_dag.py edvai_hadoop:/home/hadoop/airflow/dags/
docker cp airflow/car_rental_child_dag.py edvai_hadoop:/home/hadoop/airflow/dags/
```

### Verificar archivos copiados:

```bash
# Entrar al contenedor
docker exec -it edvai_hadoop bash
su hadoop

# Verificar archivos
ls -la /home/hadoop/scripts/download_data.sh
ls -la /home/hadoop/scripts/process_car_rental.py
ls -la /home/hadoop/hive/car_rental_setup.sql
ls -la /home/hadoop/hive/queries.sql
ls -la /home/hadoop/airflow/dags/car_rental_parent_dag.py
ls -la /home/hadoop/airflow/dags/car_rental_child_dag.py
```

### Dar permisos de ejecución:

```bash
chmod +x /home/hadoop/scripts/download_data.sh
```

---

## 🔷 **PASO 2: Crear Tabla en Hive (Punto 1)**

```bash
# Ejecutar script SQL
hive -f /home/hadoop/hive/car_rental_setup.sql
```

### ✅ Verificar que funcionó:

```bash
# Listar bases de datos
hive -e "SHOW DATABASES;" | grep car_rental

# Listar tablas
hive -e "USE car_rental_db; SHOW TABLES;"

# Ver estructura de la tabla
hive -e "USE car_rental_db; DESCRIBE car_rental_analytics;"
```

### 📊 Salida esperada:

```
car_rental_db

car_rental_analytics

fueltype                string
rating                  int
rentertripstaken        int
reviewcount             int
city                    string
state_name              string
owner_id                int
rate_daily              int
make                    string
model                   string
year                    int
```

---

## 🔷 **PASO 3: Descargar Archivos (Punto 2)**

```bash
# Ejecutar script de descarga
bash /home/hadoop/scripts/download_data.sh
```

### ✅ Verificar que funcionó:

```bash
# Verificar archivos en HDFS
hdfs dfs -ls -h /car_rental/raw/
```

### 📊 Salida esperada:

```
-rw-r--r--   1 hadoop supergroup      XXX /car_rental/raw/CarRentalData.csv
-rw-r--r--   1 hadoop supergroup      XXX /car_rental/raw/georef_usa_states.csv
```

### Ver preview de datos:

```bash
# Ver primeras líneas de CarRentalData
hdfs dfs -cat /car_rental/raw/CarRentalData.csv | head -3

# Ver primeras líneas de georef
hdfs dfs -cat /car_rental/raw/georef_usa_states.csv | head -3
```

---

## 🔷 **PASO 4: Procesar Datos con Spark (Punto 3)**

```bash
# Ejecutar procesamiento Spark
spark-submit /home/hadoop/scripts/process_car_rental.py
```

### ✅ Verificar que funcionó:

```bash
# Verificar total de registros en Hive
hive -e "USE car_rental_db; SELECT COUNT(*) as total FROM car_rental_analytics;"
```

### 📊 Salida esperada:

```
Total MapReduce CPU Time Spent: 0 msec
OK
10000  (o el número de registros procesados)
Time taken: X seconds
```

### Ver muestra de datos:

```bash
# Ver primeras 5 filas
hive -e "USE car_rental_db; SELECT * FROM car_rental_analytics LIMIT 5;"
```

---

## 🔷 **PASO 5: Verificar Transformaciones**

### 5.1 Verificar que Texas fue excluido:

```bash
hive -e "USE car_rental_db; 
SELECT COUNT(*) as registros_texas 
FROM car_rental_analytics 
WHERE state_name = 'Texas';"
```

**Resultado esperado:** `0`

---

### 5.2 Verificar que no hay rating nulos:

```bash
hive -e "USE car_rental_db; 
SELECT COUNT(*) as rating_nulos 
FROM car_rental_analytics 
WHERE rating IS NULL;"
```

**Resultado esperado:** `0`

---

### 5.3 Verificar que fuelType está en minúsculas:

```bash
hive -e "USE car_rental_db; 
SELECT DISTINCT fuelType 
FROM car_rental_analytics 
ORDER BY fuelType;"
```

**Resultado esperado:**
```
diesel
electric
gasoline
hybrid
other
```

---

### 5.4 Ver estadísticas generales:

```bash
hive -e "USE car_rental_db; 
SELECT 
    'Total registros' as metrica, 
    CAST(COUNT(*) as STRING) as valor 
FROM car_rental_analytics
UNION ALL
SELECT 
    'Estados únicos', 
    CAST(COUNT(DISTINCT state_name) as STRING) 
FROM car_rental_analytics
UNION ALL
SELECT 
    'Ciudades únicas', 
    CAST(COUNT(DISTINCT city) as STRING) 
FROM car_rental_analytics
UNION ALL
SELECT 
    'Marcas únicas', 
    CAST(COUNT(DISTINCT make) as STRING) 
FROM car_rental_analytics;"
```

---

## 🔷 **PASO 6: Ejecutar Consultas de Negocio (Punto 5)**

### 5a. Alquileres ecológicos con rating >= 4

```bash
hive -e "USE car_rental_db; 
SELECT COUNT(*) as total_alquileres_ecologicos 
FROM car_rental_analytics 
WHERE (fuelType = 'hybrid' OR fuelType = 'electric') 
  AND rating >= 4;"
```

---

### 5b. 5 estados con menor cantidad de alquileres

```bash
hive -e "USE car_rental_db; 
SELECT 
    state_name,
    COUNT(*) as total_alquileres
FROM car_rental_analytics
WHERE state_name IS NOT NULL
GROUP BY state_name
ORDER BY total_alquileres ASC
LIMIT 5;"
```

---

### 5c. 10 modelos más rentados (con marca)

```bash
hive -e "USE car_rental_db; 
SELECT 
    make as marca,
    model as modelo,
    COUNT(*) as total_alquileres
FROM car_rental_analytics
WHERE make IS NOT NULL AND model IS NOT NULL
GROUP BY make, model
ORDER BY total_alquileres DESC
LIMIT 10;"
```

---

### 5d. Alquileres por año (2010-2015)

```bash
hive -e "USE car_rental_db; 
SELECT 
    year as año_fabricacion,
    COUNT(*) as total_alquileres
FROM car_rental_analytics
WHERE year BETWEEN 2010 AND 2015
GROUP BY year
ORDER BY year;"
```

---

### 5e. 5 ciudades con más alquileres ecológicos

```bash
hive -e "USE car_rental_db; 
SELECT 
    city as ciudad,
    state_name as estado,
    COUNT(*) as total_alquileres_ecologicos
FROM car_rental_analytics
WHERE (fuelType = 'hybrid' OR fuelType = 'electric')
  AND city IS NOT NULL
GROUP BY city, state_name
ORDER BY total_alquileres_ecologicos DESC
LIMIT 5;"
```

---

### 5f. Promedio de reviews por tipo de combustible

```bash
hive -e "USE car_rental_db; 
SELECT 
    fuelType as tipo_combustible,
    ROUND(AVG(reviewCount), 2) as promedio_reviews,
    COUNT(*) as total_vehiculos
FROM car_rental_analytics
WHERE fuelType IS NOT NULL
GROUP BY fuelType
ORDER BY promedio_reviews DESC;"
```

---

## 🔷 **PASO 7: Ejecutar DAGs de Airflow (Punto 4)**

### Opción A: Desde UI de Airflow

1. Abrir navegador: `http://localhost:8080`
2. Buscar: `car_rental_parent_dag`
3. Activar toggle (ON)
4. Click en botón ▶ "Trigger DAG"
5. Monitorear en vista "Graph" o "Grid"

---

### Opción B: Desde CLI

```bash
# Listar DAGs
airflow dags list | grep car_rental

# Ejecutar DAG padre (esto ejecutará también el hijo)
airflow dags trigger car_rental_parent_dag

# Ver estado
airflow dags list-runs -d car_rental_parent_dag

# Ver logs del DAG padre
airflow tasks logs car_rental_parent_dag download_and_ingest $(date +%Y-%m-%d)

# Ver logs del DAG hijo
airflow tasks logs car_rental_child_dag spark_process_data $(date +%Y-%m-%d)
```

---

## 🔷 **PASO 8: Guardar Resultados (Para el Informe)**

### Capturar resultados de consultas:

```bash
# Crear directorio para resultados
mkdir -p /home/hadoop/car_rental_results

# Guardar cada consulta en un archivo
hive -e "USE car_rental_db; 
SELECT COUNT(*) as total_alquileres_ecologicos 
FROM car_rental_analytics 
WHERE (fuelType = 'hybrid' OR fuelType = 'electric') AND rating >= 4;" \
> /home/hadoop/car_rental_results/5a_ecologicos.txt

hive -e "USE car_rental_db; 
SELECT state_name, COUNT(*) as total 
FROM car_rental_analytics 
WHERE state_name IS NOT NULL 
GROUP BY state_name 
ORDER BY total ASC 
LIMIT 5;" \
> /home/hadoop/car_rental_results/5b_estados_menor.txt

# ... (repetir para todas las consultas)
```

### Copiar resultados al host:

```bash
# Desde tu máquina local
docker cp edvai_hadoop:/home/hadoop/car_rental_results ./resultados/
```

---

## ✅ Checklist Final

Marca cada item cuando lo completes:

- [ ] ✅ Archivos copiados al contenedor
- [ ] ✅ Base de datos `car_rental_db` creada
- [ ] ✅ Tabla `car_rental_analytics` creada
- [ ] ✅ 2 archivos descargados y en HDFS
- [ ] ✅ Procesamiento Spark completado
- [ ] ✅ Datos cargados en Hive
- [ ] ✅ Texas excluido (verificado)
- [ ] ✅ Rating nulos eliminados (verificado)
- [ ] ✅ fuelType en minúsculas (verificado)
- [ ] ✅ Consulta 5a ejecutada
- [ ] ✅ Consulta 5b ejecutada
- [ ] ✅ Consulta 5c ejecutada
- [ ] ✅ Consulta 5d ejecutada
- [ ] ✅ Consulta 5e ejecutada
- [ ] ✅ Consulta 5f ejecutada
- [ ] ✅ DAG Padre ejecutado
- [ ] ✅ DAG Hijo ejecutado
- [ ] ✅ Capturas de pantalla tomadas

---

## 🐛 Errores Comunes y Soluciones

### Error: `bash: hive: command not found`

```bash
export HIVE_HOME=/home/hadoop/hive
export PATH=$HIVE_HOME/bin:$PATH
```

---

### Error: `hdfs: command not found`

```bash
export HADOOP_HOME=/home/hadoop/hadoop
export PATH=$HADOOP_HOME/bin:$PATH
```

---

### Error: `spark-submit: command not found`

```bash
export SPARK_HOME=/home/hadoop/spark
export PATH=$SPARK_HOME/bin:$PATH
```

---

### Error: `File already exists in HDFS`

```bash
# Eliminar y volver a ejecutar
hdfs dfs -rm -r /car_rental/raw/
bash /home/hadoop/scripts/download_data.sh
```

---

### Error: `Table not found`

```bash
# Recrear tabla
hive -f /home/hadoop/hive/car_rental_setup.sql
```

---

## 📞 Soporte

Si encuentras algún error no listado aquí:

1. Verifica los logs de Spark: `/home/hadoop/spark/logs/`
2. Verifica los logs de Airflow: `/home/hadoop/airflow/logs/`
3. Verifica los logs de Hive: `/tmp/hadoop/hive.log`

---

**¡Listo! Ahora puedes ejecutar cada paso y verificar que todo funcione correctamente** ✅


