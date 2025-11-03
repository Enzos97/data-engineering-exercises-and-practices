#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from datetime import timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.dummy import DummyOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'hadoop',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='f1_processing',
    default_args=default_args,
    description='Orquesta la descarga, ingestión y procesamiento de datos de Formula 1',
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
    tags=['spark', 'hive', 'etl', 'f1'],
) as dag:

    inicio = DummyOperator(task_id='inicio')

    ingest = BashOperator(
        task_id='ingesta_datos_f1',
        bash_command='bash -c \'bash /home/hadoop/scripts/f1_download_and_ingest.sh\'',
    )

    process = BashOperator(
        task_id='procesa_spark_f1',
        bash_command='bash -c \'spark-submit /home/hadoop/scripts/process_f1_data.py\'',
    )

    verify_drivers = BashOperator(
        task_id='verifica_driver_results',
        bash_command='bash -c \'beeline -u jdbc:hive2://localhost:10000 -e "USE f1; SELECT COUNT(*) AS total_drivers FROM driver_results;"\'',
    )

    verify_constructors = BashOperator(
        task_id='verifica_constructor_results',
        bash_command='bash -c \'beeline -u jdbc:hive2://localhost:10000 -e "USE f1; SELECT COUNT(*) AS total_constructors FROM constructor_results;"\'',
    )

    fin = DummyOperator(task_id='fin_proceso')

    inicio >> ingest >> process >> verify_drivers >> verify_constructors >> fin

