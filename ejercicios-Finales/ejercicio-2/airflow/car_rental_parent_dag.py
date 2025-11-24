#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
=====================================================
DAG: car_rental_parent_dag.py
Descripción: DAG PADRE - Descarga archivos y llama al DAG hijo
Autor: Data Engineering Team
Fecha: 2025-11-22
PUNTO 4a: DAG Padre que ingiere archivos y llama al DAG hijo
=====================================================
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.operators.dummy import DummyOperator

# Argumentos por defecto
default_args = {
    'owner': 'DataEngineering',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email': ['data-team@carental.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Definir el DAG
with DAG(
    dag_id='car_rental_parent_dag',
    default_args=default_args,
    description='DAG PADRE: Descarga datos de Car Rental y dispara procesamiento',
    schedule_interval=None,  # Ejecutar manualmente
    start_date=datetime(2023, 1, 1),
    catchup=False,
    is_paused_upon_creation=False,  # ✅ Se activa automáticamente
    tags=['car-rental', 'parent', 'ingest'],
) as dag:

    # ============================================
    # TAREA 1: INICIO
    # ============================================
    inicio = DummyOperator(
        task_id='inicio',
        doc_md="""
        ## Inicio del Pipeline
        
        Este es el DAG PADRE que:
        1. Descarga los archivos desde S3
        2. Los sube a HDFS
        3. Dispara el DAG HIJO para procesamiento
        """,
    )

    # ============================================
    # TAREA 2: CREAR TABLA EN HIVE
    # ============================================
    crear_tabla_hive = BashOperator(
        task_id='crear_tabla_hive',
        bash_command='''
        export HIVE_HOME=/home/hadoop/hive
        export HADOOP_HOME=/home/hadoop/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
        export PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH
        
        echo "=== Creando base de datos y tabla en Hive ==="
        hive -e "
        CREATE DATABASE IF NOT EXISTS car_rental_db;
        
        USE car_rental_db;
        
        CREATE TABLE IF NOT EXISTS car_rental_analytics (
            fuelType STRING,
            rating INT,
            renterTripsTaken INT,
            reviewCount INT,
            city STRING,
            state_name STRING,
            owner_id INT,
            rate_daily INT,
            make STRING,
            model STRING,
            year INT
        )
        ROW FORMAT DELIMITED
        FIELDS TERMINATED BY ','
        STORED AS TEXTFILE;
        "
        echo "=== Tabla creada o ya existe ==="
        ''',
        doc_md="""
        ## Crear Base de Datos y Tabla en Hive
        
        Crea:
        - Base de datos: car_rental_db
        - Tabla: car_rental_analytics
        
        Con el schema definido en el punto 1.
        
        **Nota:** Usa IF NOT EXISTS, por lo que no falla si ya existe.
        """,
    )

    # ============================================
    # TAREA 3: DESCARGAR ARCHIVOS E INGESTAR A HDFS
    # ============================================
    download_and_ingest = BashOperator(
        task_id='download_and_ingest',
        bash_command='bash -c \'bash /home/hadoop/scripts/download_data.sh\'',
        doc_md="""
        ## Descarga de Archivos y Carga a HDFS
        
        Este script:
        1. Descarga CarRentalData.csv desde S3
        2. Descarga georef-united-states-of-america-state.csv
        3. Los sube a HDFS en /car_rental/raw/
        
        **Nota:** El segundo archivo se descarga con -O para renombrarlo
        ya que contiene caracteres especiales en el nombre.
        
        El script download_data.sh ya incluye las variables de entorno.
        """,
    )

    # ============================================
    # TAREA 4: VERIFICAR ARCHIVOS EN HDFS
    # ============================================
    verificar_hdfs = BashOperator(
        task_id='verificar_archivos_hdfs',
        bash_command='''
        export HADOOP_HOME=/home/hadoop/hadoop
        export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
        export PATH=$HADOOP_HOME/bin:$PATH
        
        echo "=== Verificando archivos en HDFS ==="
        hdfs dfs -ls -h /car_rental/raw/
        ''',
        doc_md="""
        ## Verificación de Archivos en HDFS
        
        Verifica que los archivos se hayan subido correctamente:
        - CarRentalData.csv
        - georef_usa_states.csv
        """,
    )

    # ============================================
    # TAREA 5: TRIGGER DAG HIJO
    # ============================================
    trigger_hijo = TriggerDagRunOperator(
        task_id='trigger_procesamiento',
        trigger_dag_id='car_rental_child_dag',  # ID del DAG hijo
        wait_for_completion=False,  # No esperar (más robusto)
        doc_md="""
        ## Disparar DAG Hijo
        
        Dispara el DAG HIJO (car_rental_child_dag) que:
        1. Lee los archivos desde HDFS
        2. Aplica transformaciones
        3. Hace JOIN
        4. Carga datos en Hive
        
        El DAG hijo se ejecuta independientemente.
        """,
    )

    # La verificación de Hive se hace en el DAG hijo

    # ============================================
    # TAREA 7: FIN
    # ============================================
    fin = DummyOperator(
        task_id='fin',
        doc_md="""
        ## Fin del Pipeline
        
        Pipeline completado exitosamente:
        ✅ Archivos descargados
        ✅ Datos en HDFS
        ✅ Procesamiento completado
        ✅ Datos en Hive
        
        **Siguiente paso:** Ejecutar consultas SQL (Punto 5)
        """,
    )

    # ============================================
    # DEFINIR FLUJO DE TAREAS
    # ============================================
    inicio >> crear_tabla_hive >> download_and_ingest >> verificar_hdfs >> trigger_hijo >> fin
