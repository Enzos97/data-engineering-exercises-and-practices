# 🚀 Guía de Instalación y Ejecución - Ejercicio 10

Esta guía proporciona instrucciones paso a paso para configurar y ejecutar el pipeline completo de Northwind Analytics.

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Preparación del Ambiente](#preparación-del-ambiente)
3. [Instalación de Scripts](#instalación-de-scripts)
4. [Ejecución Manual](#ejecución-manual)
5. [Ejecución con Airflow](#ejecución-con-airflow)
6. [Verificación de Resultados](#verificación-de-resultados)
7. [Troubleshooting](#troubleshooting)

---

## 📌 Requisitos Previos

### Servicios Necesarios

- ✅ **Docker** instalado y corriendo
- ✅ **Contenedor Hadoop** (`edvai_hadoop`) activo
- ✅ **PostgreSQL** con base de datos Northwind cargada
- ✅ **Apache Hive** configurado y funcionando
- ✅ **Apache Spark** disponible
- ✅ **Apache Airflow** instalado (opcional, para ejercicio 7)
- ✅ **Apache Sqoop** instalado

### Verificar Servicios

```bash
# Verificar contenedores Docker
docker ps

# Debe mostrar:
# - edvai_hadoop (corriendo)
# - edvai_postgres (corriendo)
```

---

## 🔧 Preparación del Ambiente

### Paso 1: Conectarse al Contenedor Hadoop

```bash
# Desde el host (Windows/Linux/Mac)
docker exec -it edvai_hadoop bash

# Cambiar a usuario hadoop
su hadoop

# Verificar directorio home
cd /home/hadoop
pwd
# Debe mostrar: /home/hadoop
```

### Paso 2: Crear Archivo de Password

```bash
# Crear archivo con password de PostgreSQL
echo "edvai" > /home/hadoop/password.txt

# Establecer permisos seguros (solo lectura para owner)
chmod 600 /home/hadoop/password.txt

# Verificar permisos
ls -la /home/hadoop/password.txt
# Debe mostrar: -rw------- 1 hadoop hadoop 5 ... password.txt
```

### Paso 3: Crear Directorios

```bash
# Crear directorio para scripts si no existe
mkdir -p /home/hadoop/scripts

# Crear directorio para DAGs de Airflow
mkdir -p /home/hadoop/airflow/dags

# Crear directorio para scripts SQL de Hive
mkdir -p /home/hadoop/hive
```

### Paso 4: Verificar Conectividad a PostgreSQL

```bash
# Probar conexión
psql -h 172.17.0.1 -p 5432 -U postgres -d northwind -c "SELECT COUNT(*) FROM customers;"

# Debe mostrar el conteo de clientes (91 registros)
```

---

## 📦 Instalación de Scripts

### Opción A: Copiar desde Repositorio Local

Si tienes los archivos en tu máquina local:

```bash
# Desde el host (fuera del contenedor)
cd /path/to/ejercicio-10-practica-northwind-airflow-sqoop-spark/

# Copiar scripts de Sqoop
docker cp scripts/sqoop_import_clientes.sh edvai_hadoop:/home/hadoop/scripts/
docker cp scripts/sqoop_import_envios.sh edvai_hadoop:/home/hadoop/scripts/
docker cp scripts/sqoop_import_order_details.sh edvai_hadoop:/home/hadoop/scripts/

# Copiar scripts de Spark
docker cp scripts/spark_products_sold.py edvai_hadoop:/home/hadoop/scripts/
docker cp scripts/spark_products_sent.py edvai_hadoop:/home/hadoop/scripts/

# Copiar DAG de Airflow
docker cp airflow/northwind_processing.py edvai_hadoop:/home/hadoop/airflow/dags/

# Copiar script SQL de Hive
docker cp hive/northwind-setup.sql edvai_hadoop:/home/hadoop/hive/
```

### Opción B: Crear Scripts Manualmente

Si prefieres crear los scripts manualmente dentro del contenedor:

```bash
# Dentro del contenedor Hadoop
cd /home/hadoop/scripts

# Crear cada script con nano o vi
nano sqoop_import_clientes.sh
# (Copiar contenido del archivo correspondiente)
# Ctrl+O para guardar, Ctrl+X para salir

# Repetir para todos los scripts...
```

### Paso 5: Dar Permisos de Ejecución

```bash
# Dar permisos a todos los scripts
chmod +x /home/hadoop/scripts/*.sh
chmod +x /home/hadoop/scripts/*.py

# Verificar permisos
ls -la /home/hadoop/scripts/
# Todos deben tener -rwxr-xr-x
```

---

## ▶️ Ejecución Manual

### Ejercicio 1: Crear Base de Datos en Hive

```bash
# Abrir Hive CLI
hive

# Ejecutar comandos SQL
CREATE DATABASE IF NOT EXISTS northwind_analytics;
SHOW DATABASES;
USE northwind_analytics;

# Salir de Hive
quit;
```

### Ejercicio 2: Importar Clientes con Sqoop

```bash
cd /home/hadoop/scripts
./sqoop_import_clientes.sh
```

**Tiempo estimado**: ~25 segundos  
**Verificación**:
```bash
hdfs dfs -ls -h /sqoop/ingest/customers
```

### Ejercicio 3: Importar Envíos con Sqoop

```bash
./sqoop_import_envios.sh
```

**Tiempo estimado**: ~24 segundos  
**Verificación**:
```bash
hdfs dfs -ls -h /sqoop/ingest/envios
```

### Ejercicio 4: Importar Order Details con Sqoop

```bash
./sqoop_import_order_details.sh
```

**Tiempo estimado**: ~24 segundos  
**Verificación**:
```bash
hdfs dfs -ls -h /sqoop/ingest/order_details
```

### Ejercicio 5: Procesar Products Sold con Spark

```bash
spark-submit /home/hadoop/scripts/spark_products_sold.py
```

**Tiempo estimado**: ~30 segundos  
**Verificación**:
```bash
beeline -u jdbc:hive2://localhost:10000 -e "USE northwind_analytics; SELECT COUNT(*) FROM products_sold;"
```

### Ejercicio 6: Procesar Products Sent con Spark

```bash
spark-submit /home/hadoop/scripts/spark_products_sent.py
```

**Tiempo estimado**: ~35 segundos  
**Verificación**:
```bash
beeline -u jdbc:hive2://localhost:10000 -e "USE northwind_analytics; SELECT COUNT(*) FROM products_sent;"
```

---

## 🤖 Ejecución con Airflow

### Paso 1: Verificar que el DAG está Disponible

```bash
# Listar DAGs
airflow dags list | grep northwind

# Debe mostrar: northwind_processing
```

### Paso 2: Verificar Estructura del DAG

```bash
airflow dags show northwind_processing
```

### Paso 3: Ejecutar el DAG

**Opción A: Desde la UI de Airflow**

1. Abrir navegador: http://localhost:8080
2. Usuario/Password: (configurados en tu instalación de Airflow)
3. Buscar DAG `northwind_processing`
4. Activar el toggle (switch)
5. Click en "Trigger DAG" (▶)
6. Monitorear en vista "Graph" o "Grid"

**Opción B: Desde Línea de Comandos**

```bash
# Ejecutar el DAG
airflow dags trigger northwind_processing

# Ver estado
airflow dags list-runs -d northwind_processing

# Ver logs de una tarea específica
airflow tasks logs northwind_processing ingest.sqoop_import_clientes <FECHA>
```

### Paso 4: Monitorear Ejecución

```bash
# Ver estado en tiempo real
watch "airflow dags list-runs -d northwind_processing"

# O consultar logs
tail -f /home/hadoop/airflow/logs/northwind_processing/*/*/task.log
```

---

## ✅ Verificación de Resultados

### Verificar Datos en HDFS

```bash
# Ver todos los datos ingestados
hdfs dfs -ls -h -R /sqoop/ingest/

# Debe mostrar:
# /sqoop/ingest/customers/  (~3.6 KB)
# /sqoop/ingest/envios/     (~11.7 KB)
# /sqoop/ingest/order_details/ (~12.0 KB)
```

### Verificar Tablas en Hive

```bash
beeline -u jdbc:hive2://localhost:10000
```

```sql
-- Conectado a Beeline
USE northwind_analytics;

-- Mostrar tablas
SHOW TABLES;
-- Debe mostrar: products_sold, products_sent

-- Contar registros
SELECT COUNT(*) FROM products_sold;   -- Debe mostrar: 33
SELECT COUNT(*) FROM products_sent;   -- Debe mostrar: 803

-- Ver top 5 clientes
SELECT * FROM products_sold ORDER BY productos_vendidos DESC LIMIT 5;

-- Ver top 5 ventas
SELECT * FROM products_sent ORDER BY total_price DESC LIMIT 5;

-- Salir
!quit
```

### Estadísticas Esperadas

| Tabla | Registros | Descripción |
|-------|-----------|-------------|
| `products_sold` | 33 | Clientes con ventas > 24.21 (promedio) |
| `products_sent` | 803 | Pedidos con descuento aplicado |

**Top Cliente**: Save-a-lot Markets (116 productos vendidos)  
**Precio promedio**: $627.52  
**Venta máxima**: $15,019.50

---

## 🐛 Troubleshooting

### Problema 1: "Connection refused" en Sqoop

**Causa**: PostgreSQL no accesible desde el contenedor.

**Solución**:
```bash
# Verificar IP del gateway Docker
docker network inspect bridge | grep Gateway

# Actualizar DB_HOST en los scripts de Sqoop si es diferente de 172.17.0.1
```

### Problema 2: "Permission denied" en password.txt

**Causa**: Permisos incorrectos en el archivo de password.

**Solución**:
```bash
chmod 600 /home/hadoop/password.txt
chown hadoop:hadoop /home/hadoop/password.txt
```

### Problema 3: "HDFS directory already exists"

**Causa**: Directorios de ingesta previos no limpiados.

**Solución**:
```bash
# Limpiar todos los directorios
hdfs dfs -rm -r /sqoop/ingest/*

# O ejecutar los scripts que incluyen limpieza automática
```

### Problema 4: "Table not found" en Hive

**Causa**: Las tablas son creadas por Spark. El pipeline debe ejecutarse primero.

**Solución**:
```bash
# Ejecutar primero los scripts de Spark
spark-submit /home/hadoop/scripts/spark_products_sold.py
spark-submit /home/hadoop/scripts/spark_products_sent.py

# Luego verificar
beeline -u jdbc:hive2://localhost:10000 -e "USE northwind_analytics; SHOW TABLES;"
```

### Problema 5: DAG no aparece en Airflow

**Causa**: Error de sintaxis o permisos en el archivo del DAG.

**Solución**:
```bash
# Verificar sintaxis Python
python3 /home/hadoop/airflow/dags/northwind_processing.py

# Si hay errores, corregirlos

# Reiniciar scheduler de Airflow
airflow scheduler &
```

### Problema 6: Spark Job falla

**Causa**: Datos de entrada no disponibles o HDFS NameNode en safe mode.

**Solución**:
```bash
# Verificar que los datos existen
hdfs dfs -ls /sqoop/ingest/customers
hdfs dfs -ls /sqoop/ingest/envios
hdfs dfs -ls /sqoop/ingest/order_details

# Verificar safe mode de HDFS
hdfs dfsadmin -safemode get

# Si está en safe mode, salir
hdfs dfsadmin -safemode leave
```

---

## 📊 Resumen de Comandos

### Pipeline Completo Manual

```bash
# 1. Crear base de datos
hive -e "CREATE DATABASE IF NOT EXISTS northwind_analytics;"

# 2. Etapa de Ingest (paralelo)
cd /home/hadoop/scripts
./sqoop_import_clientes.sh &
./sqoop_import_envios.sh &
./sqoop_import_order_details.sh &
wait

# 3. Etapa de Process (paralelo)
spark-submit spark_products_sold.py &
spark-submit spark_products_sent.py &
wait

# 4. Verificar
beeline -u jdbc:hive2://localhost:10000 -e "
USE northwind_analytics;
SELECT COUNT(*) FROM products_sold;
SELECT COUNT(*) FROM products_sent;
"
```

### Pipeline con Airflow

```bash
# Ejecutar DAG
airflow dags trigger northwind_processing

# Monitorear
airflow dags list-runs -d northwind_processing
```

---

## 🎓 Próximos Pasos

1. ✅ Tomar capturas de pantalla de cada ejercicio
2. ✅ Documentar los resultados en `ejercicios-resueltos.md`
3. ✅ Analizar los datos en Hive con consultas adicionales
4. ✅ Experimentar con diferentes filtros y agregaciones en Spark
5. ✅ Modificar el DAG para agregar más tareas
6. ✅ Optimizar el rendimiento ajustando configuraciones de Spark

---

## 📚 Referencias

- [README Principal](./README.md)
- [Ejercicios Resueltos](./ejercicios-resueltos.md)
- [Documentación de Airflow](./airflow/README.md)
- [Documentación de Hive](./hive/README.md)
- [Documentación de Scripts](./scripts/README.md)

---

**Última actualización**: 2025-11-12  
**Versión**: 1.0  
**Autor**: Hadoop Team

