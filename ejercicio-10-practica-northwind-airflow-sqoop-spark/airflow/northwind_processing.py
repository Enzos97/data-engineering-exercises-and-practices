#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DAG: northwind_processing
Descripción: Orquesta el pipeline completo de ETL para Northwind Analytics
             - Etapa Ingest: Importa datos desde PostgreSQL con Sqoop
             - Etapa Process: Procesa datos con Spark e inserta en Hive
Autor: Hadoop
Fecha: 2025-11-12
"""

from datetime import timedelta, datetime
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow.utils.task_group import TaskGroup
from airflow.utils.dates import days_ago

# ============================================
# CONFIGURACIÓN DEL DAG
# ============================================

default_args = {
    'owner': 'hadoop',
    'depends_on_past': False,
    'email': ['hadoop@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# ============================================
# DEFINICIÓN DEL DAG
# ============================================

with DAG(
    dag_id='northwind_processing',
    default_args=default_args,
    description='Pipeline ETL completo: Sqoop → HDFS → Spark → Hive para Northwind Analytics',
    schedule_interval=None,  # Ejecución manual
    start_date=days_ago(1),
    catchup=False,
    tags=['sqoop', 'spark', 'hive', 'etl', 'northwind'],
) as dag:

    # ============================================
    # INICIO DEL PIPELINE
    # ============================================
    
    inicio = DummyOperator(
        task_id='inicio'
    )

    # ============================================
    # GRUPO: ETAPA DE INGEST
    # ============================================
    
    with TaskGroup(group_id='ingest', tooltip='Ingestión de datos desde PostgreSQL a HDFS') as ingest_group:
        
        # Tarea 1: Importar clientes con productos vendidos
        sqoop_clientes = BashOperator(
            task_id='sqoop_import_clientes',
            bash_command='bash -c \'bash /home/hadoop/scripts/sqoop_import_clientes.sh\'',
        )
        
        # Tarea 2: Importar órdenes con información de envíos
        sqoop_envios = BashOperator(
            task_id='sqoop_import_orders',
            bash_command='bash -c \'bash /home/hadoop/scripts/sqoop_import_orders.sh\'',
        )
        
        # Tarea 3: Importar detalles de órdenes
        sqoop_order_details = BashOperator(
            task_id='sqoop_import_order_details',
            bash_command='bash -c \'bash /home/hadoop/scripts/sqoop_import_order_details.sh\'',
        )
        
        # Estas tareas pueden ejecutarse en paralelo
        [sqoop_clientes, sqoop_envios, sqoop_order_details]

    # ============================================
    # GRUPO: ETAPA DE PROCESAMIENTO
    # ============================================
    
    with TaskGroup(group_id='process', tooltip='Procesamiento de datos con Spark') as process_group:
        
        # Tarea 1: Procesar products_sold
        # Compañías con productos vendidos mayor al promedio
        spark_products_sold = BashOperator(
            task_id='spark_products_sold',
            bash_command='bash -c \'spark-submit /home/hadoop/scripts/spark_products_sold.py\'',
        )
        
        # Tarea 2: Procesar products_sent
        # Pedidos con descuento incluyendo precio total
        spark_products_sent = BashOperator(
            task_id='spark_products_sent',
            bash_command='bash -c \'spark-submit /home/hadoop/scripts/spark_products_sent.py\'',
        )
        
        # Estas tareas pueden ejecutarse en paralelo
        [spark_products_sold, spark_products_sent]

    # ============================================
    # GRUPO: VERIFICACIÓN DE RESULTADOS
    # ============================================
    
    with TaskGroup(group_id='verify', tooltip='Verificación de datos en Hive') as verify_group:
        
        # Verificar tabla products_sold
        verify_products_sold = BashOperator(
            task_id='verify_products_sold',
            bash_command='bash -c \'beeline -u jdbc:hive2://localhost:10000 -e "USE northwind_analytics; SELECT COUNT(*) AS total_registros FROM products_sold;"\'',
        )
        
        # Verificar tabla products_sent
        verify_products_sent = BashOperator(
            task_id='verify_products_sent',
            bash_command='bash -c \'beeline -u jdbc:hive2://localhost:10000 -e "USE northwind_analytics; SELECT COUNT(*) AS total_registros FROM products_sent;"\'',
        )
        
        # Estas tareas pueden ejecutarse en paralelo
        [verify_products_sold, verify_products_sent]

    # ============================================
    # FIN DEL PIPELINE
    # ============================================
    
    fin = DummyOperator(
        task_id='fin_proceso'
    )

    # ============================================
    # DEFINICIÓN DE DEPENDENCIAS
    # ============================================
    
    # Flujo: inicio → ingest → process → verify → fin
    inicio >> ingest_group >> process_group >> verify_group >> fin

