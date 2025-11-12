# Ejercicio 10 - Práctica Northwind: Airflow + Sqoop + Hive + Spark

Este ejercicio integra **Apache Airflow** para orquestación de workflows, **Apache Sqoop** para ingestión de datos desde PostgreSQL, **Apache Hive** para almacenamiento de datos estructurados y **Apache Spark** para procesamiento distribuido, utilizando datos reales de la base de datos Northwind.

## 🎯 Objetivos

- Crear base de datos en Hive para almacenamiento de datos de Northwind
- Desarrollar scripts de automatización para ingesta de datos desde PostgreSQL con Sqoop
- Procesar datos con Spark para generar análisis específicos
- Orquestar todo el pipeline con Apache Airflow usando TaskGroups
- Implementar un flujo completo de ETL automatizado

## 📋 Ejercicios Incluidos

### 1️⃣ **Crear Base de Datos en Hive**
- Crear base de datos `northwind_analytics` en Hive
- Configurar ubicación de almacenamiento en HDFS
- Verificar la creación correcta

### 2️⃣ **Script Sqoop: Importar Clientes**
- Crear script bash para importar datos de clientes con productos vendidos
- Realizar JOIN entre tablas `customers`, `orders` y `order_details`
- Campos: `customer_id`, `company_name`, `productos_vendidos`
- Formato: Parquet con compresión Snappy
- Destino: `/sqoop/ingest/customers`
- Password almacenada en archivo seguro

### 3️⃣ **Script Sqoop: Importar Envíos**
- Crear script bash para importar datos de órdenes con información de empresa
- Realizar JOIN entre tablas `orders` y `customers`
- Campos: `order_id`, `shipped_date`, `company_name`, `phone`
- Formato: Parquet con compresión Snappy
- Destino: `/sqoop/ingest/envios`
- Password almacenada en archivo seguro

### 4️⃣ **Script Sqoop: Importar Detalles de Órdenes**
- Crear script bash para importar detalles de órdenes
- Tabla: `order_details`
- Campos: `order_id`, `unit_price`, `quantity`, `discount`
- Formato: Parquet con compresión Snappy
- Destino: `/sqoop/ingest/order_details`
- Password almacenada en archivo seguro

### 5️⃣ **Script Spark: Procesar Products Sold**
- Desarrollar script Python para procesamiento de datos de clientes
- Filtrar compañías con productos vendidos mayor al promedio
- Insertar resultados en tabla Hive `products_sold`
- Base de datos: `northwind_analytics`

### 6️⃣ **Script Spark: Procesar Products Sent**
- Desarrollar script Python para procesamiento de órdenes con descuento
- Realizar JOIN entre datos de envíos y detalles
- Calcular `unit_price_discount` y `total_price`
- Insertar resultados en tabla Hive `products_sent`
- Base de datos: `northwind_analytics`

### 7️⃣ **Orquestación con Airflow**
- Crear DAG para automatización del pipeline completo
- Implementar TaskGroups para organizar etapas:
  - **Grupo Ingest**: Importación de datos con Sqoop
  - **Grupo Process**: Procesamiento de datos con Spark
  - **Grupo Verify**: Verificación de resultados en Hive
- Configurar dependencias y flujo de ejecución
- Monitorear ejecución del workflow

## 📁 Estructura del Proyecto

```
ejercicio-10-practica-northwind-airflow-sqoop-spark/
├── README.md                           # Documentación principal
├── scripts/
│   ├── sqoop_import_clientes.sh       # Script Sqoop para clientes
│   ├── sqoop_import_envios.sh         # Script Sqoop para envíos
│   ├── sqoop_import_order_details.sh  # Script Sqoop para detalles
│   ├── spark_products_sold.py         # Procesamiento Spark de clientes
│   ├── spark_products_sent.py         # Procesamiento Spark de envíos
│   └── README.md                      # Documentación de scripts
├── airflow/
│   ├── northwind_processing.py        # DAG de Airflow
│   └── README.md                      # Documentación de Airflow
├── hive/
│   ├── northwind-setup.sql            # Scripts SQL de Hive
│   └── README.md                      # Documentación de Hive
├── images/                            # Capturas de pantalla
│   └── README.md                      # Índice de imágenes
└── ejercicios-resueltos.md            # Soluciones completas
```

## 🚀 Tecnologías Utilizadas

- **Apache Airflow** - Orquestación de workflows
- **Apache Sqoop** - Ingestión de datos desde PostgreSQL
- **Apache Hive** - Data warehouse y consultas SQL
- **Apache Spark** - Procesamiento distribuido de datos
- **PySpark** - API de Python para Spark
- **HDFS** - Sistema de archivos distribuido
- **PostgreSQL** - Base de datos relacional fuente
- **Parquet** - Formato de almacenamiento columnar
- **Bash Scripting** - Automatización de procesos

## 📊 Dataset Utilizado

- **Fuente**: Base de datos Northwind (PostgreSQL)
- **Tablas**: 
  - `customers` - Información de clientes
  - `orders` - Órdenes de compra
  - `order_details` - Detalles de cada orden
- **Descripción**: Base de datos de ejemplo clásica para sistemas de gestión de pedidos

## 🔧 Requisitos Previos

- Contenedor de Hadoop ejecutándose
- Apache Hive configurado y funcionando
- Apache Spark disponible en el ambiente
- Apache Airflow instalado y configurado
- Apache Sqoop instalado
- PostgreSQL con base de datos Northwind cargada
- Archivo de password en `/home/hadoop/password.txt`
- Conocimientos básicos de SQL, Python y Bash

## 📖 Estructura del Pipeline

```
┌──────────────────────────────────────────────────────────────┐
│                         INICIO                                │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                    ETAPA: INGEST                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  • sqoop_import_clientes                               │  │
│  │  • sqoop_import_envios              (Paralelo)         │  │
│  │  • sqoop_import_order_details                          │  │
│  └────────────────────────────────────────────────────────┘  │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                    ETAPA: PROCESS                             │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  • spark_products_sold                                 │  │
│  │  • spark_products_sent              (Paralelo)         │  │
│  └────────────────────────────────────────────────────────┘  │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                    ETAPA: VERIFY                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  • verify_products_sold                                │  │
│  │  • verify_products_sent             (Paralelo)         │  │
│  └────────────────────────────────────────────────────────┘  │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                         FIN                                   │
└──────────────────────────────────────────────────────────────┘
```

## 🚀 Instrucciones de Ejecución

### 1. Preparación del Ambiente

```bash
# 1. Conectarse al contenedor Hadoop
docker exec -it edvai_hadoop bash
su hadoop

# 2. Crear archivo de password
echo "edvai" > /home/hadoop/password.txt
chmod 600 /home/hadoop/password.txt

# 3. Crear base de datos en Hive
hive -f /home/hadoop/hive/northwind-setup.sql
```

### 2. Copiar Scripts al Contenedor

```bash
# Copiar scripts al directorio de Hadoop
docker cp scripts/ edvai_hadoop:/home/hadoop/
docker cp airflow/northwind_processing.py edvai_hadoop:/home/hadoop/airflow/dags/

# Dar permisos de ejecución
chmod +x /home/hadoop/scripts/*.sh
chmod +x /home/hadoop/scripts/*.py
```

### 3. Ejecutar el DAG en Airflow

```bash
# Activar Airflow webserver (si no está activo)
# Acceder a http://localhost:8080

# O ejecutar desde línea de comandos:
airflow dags trigger northwind_processing
```

### 4. Verificar Resultados

```bash
# Conectarse a Hive
beeline -u jdbc:hive2://localhost:10000

# Consultar resultados
USE northwind_analytics;
SELECT COUNT(*) FROM products_sold;
SELECT COUNT(*) FROM products_sent;
```

## 🎯 Resultados Esperados

Al completar este ejercicio, habrás:

1. ✅ Configurado una base de datos Hive para análisis de Northwind
2. ✅ Automatizado la ingesta de datos desde PostgreSQL a HDFS con Sqoop
3. ✅ Procesado datos con Spark para generar insights de negocio
4. ✅ Orquestado todo el pipeline con Apache Airflow usando TaskGroups
5. ✅ Verificado la integridad de los datos procesados

## 📊 Resultados del Análisis

### Tabla: products_sold
- **Contenido**: Clientes con productos vendidos mayor al promedio
- **Registros esperados**: ~33 clientes (de 89 totales)
- **Promedio**: ~24.21 productos vendidos

### Tabla: products_sent
- **Contenido**: Pedidos enviados que tuvieron descuento
- **Registros esperados**: ~803 detalles de pedidos
- **Precio promedio**: ~$627.52

## 📝 Notas Importantes

- Los scripts de Sqoop usan archivos Parquet con compresión Snappy para optimizar almacenamiento
- Las tablas en Hive son manejadas automáticamente por Spark (modo overwrite)
- El DAG de Airflow debe ejecutarse en orden: ingest → process → verify
- Los TaskGroups permiten ejecutar tareas en paralelo dentro de cada etapa
- La password de PostgreSQL se almacena de forma segura en un archivo con permisos 600

## 🔗 Referencias

- [Apache Airflow TaskGroups](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html#taskgroups)
- [Apache Sqoop User Guide](https://sqoop.apache.org/docs/1.4.7/SqoopUserGuide.html)
- [Apache Spark SQL Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)
- [Apache Hive Language Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual)

## 📧 Contacto

Para consultas o problemas, contactar al equipo de Data Engineering.

---

**Autor**: Hadoop Team  
**Fecha**: 2025-11-12  
**Versión**: 1.0

