#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DAG: titanic_processing_dag
Descripción: Pipeline ETL para procesar datos del Titanic desde HDFS y cargarlos en Hive
             - Descarga archivo desde HDFS
             - Aplica transformaciones con Pandas
             - Carga datos procesados en Hive
Autor: Edvai
Fecha: 2025-11-20
"""

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime
import pandas as pd
import subprocess
import os

# Argumentos por defecto del DAG
default_args = {
    'owner': 'Edvai',
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
}

def procesar_titanic():
    """
    Función principal que procesa el archivo Titanic:
    1. Descarga desde HDFS
    2. Aplica transformaciones
    3. Carga en Hive
    """
    # --- CONFIGURACIÓN DE RUTAS ---
    HDFS_CMD = "/home/hadoop/hadoop/bin/hdfs"
    HIVE_CMD = "/home/hadoop/hive/bin/hive"
    
    local_path = "/tmp/titanic_raw.csv"
    processed_path = "/tmp/titanic_final.csv"
    
    # --- PASO 1: DESCARGA DESDE HDFS ---
    print(f"--- Iniciando descarga desde HDFS ---")
    subprocess.run([HDFS_CMD, "dfs", "-get", "-f", "/nifi/titanic.csv", local_path], check=True)
    print(f"✅ Archivo descargado de HDFS a {local_path}")
    
    # --- PASO 2: CARGA CON PANDAS ---
    print("--- Cargando datos con Pandas ---")
    df = pd.read_csv(local_path)
    print(f"📊 Total de registros cargados: {len(df)}")
    
    # --- PASO 3: TRANSFORMACIONES ---
    print("--- Aplicando transformaciones ---")
    
    # a) Remover columnas SibSp y Parch
    print("  • Removiendo columnas SibSp y Parch")
    df = df.drop(columns=['SibSp', 'Parch'], errors='ignore')
    
    # b) Calcular promedio de edad por género y rellenar nulos
    print("  • Calculando promedios de edad por género")
    mean_age_men = df[df['Sex'] == 'male']['Age'].mean()
    mean_age_women = df[df['Sex'] == 'female']['Age'].mean()
    
    print(f"    - Promedio edad hombres: {mean_age_men:.2f}")
    print(f"    - Promedio edad mujeres: {mean_age_women:.2f}")
    
    # Rellenar valores nulos de edad con los promedios calculados
    df.loc[(df['Sex'] == 'male') & (df['Age'].isnull()), 'Age'] = mean_age_men
    df.loc[(df['Sex'] == 'female') & (df['Age'].isnull()), 'Age'] = mean_age_women
    
    # c) Si Cabina es nulo, dejarlo en 0
    print("  • Reemplazando valores nulos de Cabin con 0")
    df['Cabin'] = df['Cabin'].fillna(0)
    
    # CORRECCIÓN: Limpiar comas del campo Name para evitar errores en Hive
    print("  • Limpiando comas en el campo Name")
    df['Name'] = df['Name'].str.replace(',', '')
    
    # CORRECCIÓN: Forzar tipos de datos correctos
    df['Age'] = pd.to_numeric(df['Age'], errors='coerce')
    df['Fare'] = pd.to_numeric(df['Fare'], errors='coerce')
    
    print(f"✅ Transformaciones completadas. Registros finales: {len(df)}")
    
    # --- PASO 4: GUARDADO LOCAL ---
    print("--- Guardando archivo procesado ---")
    # Guardar sin header y sin index para Hive
    df.to_csv(processed_path, index=False, header=False)
    print(f"✅ Archivo guardado en {processed_path}")
    
    # --- PASO 5: SUBIDA A HDFS ---
    print(f"--- Subiendo archivo procesado a HDFS ---")
    hdfs_dest = "/tmp/titanic_final.csv"
    subprocess.run([HDFS_CMD, "dfs", "-put", "-f", processed_path, hdfs_dest], check=True)
    print(f"✅ Archivo subido a HDFS: {hdfs_dest}")
    
    # --- PASO 6: CARGA EN HIVE ---
    print(f"--- Cargando datos en Hive ---")
    load_query = f"LOAD DATA INPATH '{hdfs_dest}' OVERWRITE INTO TABLE titanic_db.titanic_processed;"
    subprocess.run([HIVE_CMD, "-e", load_query], check=True)
    print(f"✅ Datos cargados en tabla titanic_db.titanic_processed")
    
    print("\n=== PROCESO COMPLETADO EXITOSAMENTE ===")

# Definición del DAG
with DAG('titanic_processing_dag',
         default_args=default_args,
         description='Pipeline ETL para procesar datos del Titanic y cargarlos en Hive',
         schedule_interval='@daily',
         catchup=False,
         tags=['pandas', 'hive', 'etl', 'titanic']) as dag:

    # Tarea única que ejecuta todo el procesamiento
    transform_task = PythonOperator(
        task_id='transform_and_load_hive',
        python_callable=procesar_titanic
    )

    transform_task

