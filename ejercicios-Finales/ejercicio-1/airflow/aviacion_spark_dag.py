#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
=====================================================
DAG: aviacion_spark_dag.py
Descripción: Pipeline de procesamiento de datos de aviación usando PySpark
Autor: Data Engineering Team
Fecha: 2025-11-22
EJERCICIO FINAL 1 - Versión PySpark
=====================================================
"""

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from datetime import datetime, timedelta

# Argumentos por defecto
default_args = {
    'owner': 'Edvai',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Definir el DAG
with DAG(
    dag_id='aviacion_processing_spark_dag',
    default_args=default_args,
    description='Pipeline ETL de Aviación con PySpark (sin Pandas)',
    schedule_interval='@daily',
    start_date=datetime(2023, 1, 1),
    catchup=False,
    is_paused_upon_creation=False,
    tags=['aviacion', 'pyspark', 'etl'],
) as dag:

    # ============================================
    # TAREA 1: INICIO
    # ============================================
    inicio = DummyOperator(
        task_id='inicio_proceso',
    )

    # ============================================
    # TAREA 2: CREAR BASE DE DATOS Y TABLAS EN HIVE
    # ============================================
    crear_tablas_hive = BashOperator(
        task_id='crear_tablas_hive',
        bash_command='''
        export HIVE_HOME=/home/hadoop/hive
        export HADOOP_HOME=/home/hadoop/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
        export PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH
        
        echo "=== Creando base de datos y tablas en Hive ==="
        hive -e "
        CREATE DATABASE IF NOT EXISTS aviacion;
        
        USE aviacion;
        
        -- Tabla 1: Vuelos
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
        TBLPROPERTIES (\"skip.header.line.count\"=\"1\");
        
        -- Tabla 2: Detalles Aeropuertos
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
        TBLPROPERTIES (\"skip.header.line.count\"=\"1\");
        
        SHOW TABLES;
        "
        echo "=== Tablas creadas o ya existen ==="
        ''',
    )

    # ============================================
    # TAREA 3: PROCESAR DATOS CON PYSPARK
    # ============================================
    procesar_datos = BashOperator(
        task_id='procesar_datos_spark',
        bash_command='''
        export SPARK_HOME=/home/hadoop/spark
        export HADOOP_HOME=/home/hadoop/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
        export PATH=$SPARK_HOME/bin:$HADOOP_HOME/bin:$PATH
        
        echo "=== Iniciando procesamiento con PySpark ==="
        spark-submit /home/hadoop/scripts/process_aviacion_spark.py
        ''',
    )

    # ============================================
    # TAREA 4: VERIFICAR DATOS EN HIVE
    # ============================================
    verificar_datos = BashOperator(
        task_id='verificar_datos_hive',
        bash_command='''
        export HIVE_HOME=/home/hadoop/hive
        export HADOOP_HOME=/home/hadoop/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
        export PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH
        
        echo "=== Verificando datos en Hive ==="
        hive -e "
        USE aviacion;
        
        SELECT COUNT(*) as total_vuelos 
        FROM aeropuerto_tabla;
        
        SELECT COUNT(*) as total_aeropuertos 
        FROM aeropuerto_detalles_tabla;
        "
        ''',
    )

    # ============================================
    # TAREA 5: FIN
    # ============================================
    fin = DummyOperator(
        task_id='fin_proceso',
    )

    # ============================================
    # FLUJO DEL DAG
    # ============================================
    inicio >> crear_tablas_hive >> procesar_datos >> verificar_datos >> fin

