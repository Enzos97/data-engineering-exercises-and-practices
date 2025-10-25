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
    dag_id='airport_trips_processing',
    default_args=default_args,
    description='Orquesta la descarga, ingestión y procesamiento de datos NYC Taxi',
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
    tags=['spark', 'hive', 'etl'],
) as dag:

    inicio = DummyOperator(task_id='inicio')

    ingest = BashOperator(
        task_id='ingesta_datos',
        bash_command='bash -c \'bash /home/hadoop/scripts/download_and_ingest.sh\'',
    )

    process = BashOperator(
        task_id='procesa_spark',
        bash_command='bash -c \'spark-submit /home/hadoop/scripts/process_airport_trips.py\'',
    )

    verify = BashOperator(
        task_id='verifica_tabla_hive',
        bash_command='bash -c \'beeline -u jdbc:hive2://localhost:10000 -e "USE tripdata; SELECT COUNT(*) AS total FROM airport_trips;"\'',
    )

    fin = DummyOperator(task_id='fin_proceso')

    inicio >> ingest >> process >> verify >> fin
