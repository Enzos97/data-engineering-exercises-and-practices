#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
=====================================================
DAG: car_rental_child_dag.py
Descripción: DAG HIJO - Procesa datos y los carga en Hive
Autor: Data Engineering Team
Fecha: 2025-11-22
PUNTO 4b: DAG Hijo que procesa la información y la carga en Hive
=====================================================
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
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
    dag_id='car_rental_child_dag',
    default_args=default_args,
    description='DAG HIJO: Procesa datos de Car Rental y los carga en Hive',
    schedule_interval=None,  # Solo se ejecuta cuando lo dispara el padre
    start_date=datetime(2023, 1, 1),
    catchup=False,
    is_paused_upon_creation=False,  # ✅ Se activa automáticamente
    tags=['car-rental', 'child', 'processing'],
) as dag:

    # ============================================
    # TAREA 1: INICIO
    # ============================================
    inicio = DummyOperator(
        task_id='inicio_procesamiento',
        doc_md="""
        ## Inicio del Procesamiento
        
        Este es el DAG HIJO que:
        1. Lee archivos desde HDFS
        2. Aplica transformaciones (Punto 3)
        3. Hace JOIN entre datasets
        4. Carga datos en Hive
        """,
    )

    # ============================================
    # TAREA 2: PROCESAMIENTO CON SPARK
    # ============================================
    process_data = BashOperator(
        task_id='spark_process_data',
        bash_command='''
        export SPARK_HOME=/home/hadoop/spark
        export HADOOP_HOME=/home/hadoop/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
        export PATH=$SPARK_HOME/bin:$HADOOP_HOME/bin:$PATH
        
        echo "=== Iniciando procesamiento con Spark ==="
        spark-submit /home/hadoop/scripts/process_car_rental.py
        ''',
        doc_md="""
        ## Procesamiento con Spark
        
        Transformaciones aplicadas (Punto 3):
        
        1. **Renombrar columnas**: 
           - Eliminar espacios y puntos
           - Usar underscore (_)
           - Nombres cortos y descriptivos
        
        2. **Redondear rating**:
           - Convertir float a int
           - Aplicar round()
        
        3. **JOIN de datasets**:
           - car_rental_data JOIN georef_usa_states
           - LEFT JOIN por state code
        
        4. **Eliminar rating nulo**:
           - Filtrar registros con rating IS NULL
        
        5. **fuelType a minúsculas**:
           - lower(fuelType)
        
        6. **Excluir Texas**:
           - Filtrar state != 'TX'
        
        7. **Insertar en Hive**:
           - Base de datos: car_rental_db
           - Tabla: car_rental_analytics
        """,
    )

    # ============================================
    # TAREA 3: VERIFICAR DATOS PROCESADOS
    # ============================================
    verificar_datos = BashOperator(
        task_id='verificar_datos_procesados',
        bash_command='''
        export HIVE_HOME=/home/hadoop/hive
        export HADOOP_HOME=/home/hadoop/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
        export PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH
        
        echo "=== Verificando datos procesados ==="
        hive -e "
        USE car_rental_db;
        
        SELECT COUNT(*) as total_registros 
        FROM car_rental_analytics;
        
        SELECT fuelType, COUNT(*) as cantidad 
        FROM car_rental_analytics 
        GROUP BY fuelType;
        "
        ''',
        doc_md="""
        ## Verificación de Datos Procesados
        
        Verifica:
        1. Total de registros cargados (~4,905)
        2. Distribución por tipo de combustible
        3. Que fuelType esté en minúsculas
        """,
    )

    # ============================================
    # TAREA 4: VERIFICAR EXCLUSIÓN DE TEXAS
    # ============================================
    verificar_texas = BashOperator(
        task_id='verificar_exclusion_texas',
        bash_command='''
        export HIVE_HOME=/home/hadoop/hive
        export HADOOP_HOME=/home/hadoop/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
        export PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH
        
        echo "=== Verificando exclusión de Texas ==="
        hive -e "
        USE car_rental_db;
        SELECT COUNT(*) as registros_texas 
        FROM car_rental_analytics 
        WHERE state_name = 'Texas';
        "
        ''',
        doc_md="""
        ## Verificar Exclusión de Texas
        
        Esta consulta debe retornar 0 registros.
        Si retorna > 0, hay un error en el filtrado.
        """,
    )

    # ============================================
    # TAREA 5: VERIFICAR RATING NULOS
    # ============================================
    verificar_rating = BashOperator(
        task_id='verificar_rating_nulos',
        bash_command='''
        export HIVE_HOME=/home/hadoop/hive
        export HADOOP_HOME=/home/hadoop/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
        export PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH
        
        echo "=== Verificando rating nulos ==="
        hive -e "
        USE car_rental_db;
        SELECT COUNT(*) as rating_nulos 
        FROM car_rental_analytics 
        WHERE rating IS NULL;
        "
        ''',
        doc_md="""
        ## Verificar Rating Nulos
        
        Esta consulta debe retornar 0 registros.
        Si retorna > 0, hay registros con rating nulo que no se filtraron.
        """,
    )

    # ============================================
    # TAREA 6: ESTADÍSTICAS GENERALES
    # ============================================
    estadisticas = BashOperator(
        task_id='generar_estadisticas',
        bash_command='''
        export HIVE_HOME=/home/hadoop/hive
        export HADOOP_HOME=/home/hadoop/hadoop
        export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
        export PATH=$HIVE_HOME/bin:$HADOOP_HOME/bin:$PATH
        
        echo "=== Generando estadísticas generales ==="
        hive -e "USE car_rental_db; SELECT COUNT(*) as total FROM car_rental_analytics;"
        hive -e "USE car_rental_db; SELECT COUNT(DISTINCT state_name) as estados FROM car_rental_analytics;"
        ''',
        doc_md="""
        ## Estadísticas Generales
        
        Genera estadísticas básicas del dataset procesado.
        """,
    )

    # ============================================
    # TAREA 7: FIN
    # ============================================
    fin = DummyOperator(
        task_id='fin_procesamiento',
        doc_md="""
        ## Fin del Procesamiento
        
        Procesamiento completado exitosamente:
        ✅ Transformaciones aplicadas
        ✅ JOIN realizado
        ✅ Datos cargados en Hive
        ✅ Validaciones completadas
        
        **Siguiente paso:** Ejecutar consultas de negocio (Punto 5)
        """,
    )

    # ============================================
    # DEFINIR FLUJO DE TAREAS
    # ============================================
    inicio >> process_data >> verificar_datos
    verificar_datos >> [verificar_texas, verificar_rating]
    [verificar_texas, verificar_rating] >> estadisticas >> fin
