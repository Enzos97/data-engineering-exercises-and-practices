#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
=====================================================
Script: process_aviacion_spark.py
Descripción: Procesa datos de aviación usando PySpark (sin Pandas)
Autor: Data Engineering Team
Fecha: 2025-11-22
EJERCICIO FINAL 1 - Versión PySpark
=====================================================
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col, lower, regexp_replace, trim, to_date, 
    when, lit, coalesce, isnan, isnull
)
from pyspark.sql.types import IntegerType, FloatType
import sys
import re

def normalizar_nombre_columna(nombre):
    """
    Normaliza nombres de columnas: minúsculas, sin tildes, sin paréntesis, sin espacios extra
    """
    nombre = nombre.lower()
    # Quitar tildes
    nombre = nombre.replace('ó', 'o').replace('í', 'i')
    nombre = nombre.replace('á', 'a').replace('é', 'e')
    nombre = nombre.replace('ú', 'u').replace('ñ', 'n')
    # Quitar paréntesis y su contenido
    nombre = re.sub(r'\s*\([^)]*\)', '', nombre)
    # Quitar espacios extra
    nombre = nombre.strip()
    return nombre

def main():
    print("\n" + "="*60)
    print("✈️ PROCESAMIENTO DE DATOS DE AVIACIÓN CON PYSPARK")
    print("="*60 + "\n")
    
    try:
        # ============================================
        # 1. CREAR SESIÓN DE SPARK
        # ============================================
        print("📊 1. Creando sesión de Spark con Hive...")
        spark = SparkSession.builder \
            .appName("AviacionProcessing") \
            .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
            .config("hive.metastore.uris", "thrift://localhost:9083") \
            .enableHiveSupport() \
            .getOrCreate()
        
        print("✅ Sesión de Spark creada exitosamente\n")
        
        # ============================================
        # 2. LEER ARCHIVOS DESDE HDFS
        # ============================================
        print("📂 2. Leyendo archivos desde HDFS...")
        
        # Leer archivo 2021
        df_2021 = spark.read \
            .option("header", "true") \
            .option("inferSchema", "true") \
            .option("delimiter", ";") \
            .csv("hdfs://172.17.0.2:9000/ingest/2021-informe-ministerio.csv")
        
        print(f"✅ Datos 2021 cargados: {df_2021.count()} registros")
        
        # Leer archivo 2022
        df_2022 = spark.read \
            .option("header", "true") \
            .option("inferSchema", "true") \
            .option("delimiter", ";") \
            .csv("hdfs://172.17.0.2:9000/ingest/202206-informe-ministerio.csv")
        
        print(f"✅ Datos 2022 cargados: {df_2022.count()} registros")
        
        # Leer detalles de aeropuertos
        df_aeropuertos = spark.read \
            .option("header", "true") \
            .option("inferSchema", "true") \
            .option("delimiter", ";") \
            .csv("hdfs://172.17.0.2:9000/ingest/aeropuertos_detalle.csv")
        
        print(f"✅ Datos aeropuertos cargados: {df_aeropuertos.count()} registros\n")
        
        # ============================================
        # 3. NORMALIZAR NOMBRES DE COLUMNAS
        # ============================================
        print("🔄 3. Normalizando nombres de columnas...")
        
        # Normalizar columnas de vuelos 2021
        for col_name in df_2021.columns:
            nuevo_nombre = normalizar_nombre_columna(col_name)
            df_2021 = df_2021.withColumnRenamed(col_name, nuevo_nombre)
        
        # Normalizar columnas de vuelos 2022
        for col_name in df_2022.columns:
            nuevo_nombre = normalizar_nombre_columna(col_name)
            df_2022 = df_2022.withColumnRenamed(col_name, nuevo_nombre)
        
        # Normalizar columnas de aeropuertos
        for col_name in df_aeropuertos.columns:
            nuevo_nombre = normalizar_nombre_columna(col_name)
            df_aeropuertos = df_aeropuertos.withColumnRenamed(col_name, nuevo_nombre)
        
        print("✅ Nombres de columnas normalizados")
        print(f"   Columnas de vuelos 2021: {df_2021.columns[:5]}...")  # Mostrar primeras 5
        print()
        
        # ============================================
        # 4. UNIR DATOS DE VUELOS 2021 + 2022
        # ============================================
        print("🔄 4. Uniendo datos de vuelos 2021 y 2022...")
        
        df_vuelos = df_2021.unionByName(df_2022, allowMissingColumns=True)
        
        print(f"✅ Datos unidos: {df_vuelos.count()} registros totales\n")
        
        # ============================================
        # 5. TRANSFORMACIONES EN VUELOS
        # ============================================
        print("🔄 5. Aplicando transformaciones a vuelos...")
        
        # 5.1. Eliminar columnas innecesarias
        columnas_a_eliminar = ['inhab', 'fir', 'calidad del dato']
        for col_name in columnas_a_eliminar:
            if col_name in df_vuelos.columns:
                df_vuelos = df_vuelos.drop(col_name)
        
        print("   ✅ Columnas innecesarias eliminadas")
        
        # 5.2. Filtrar: Excluir vuelos internacionales
        # Buscar la columna que contenga 'clasificacion'
        col_clasificacion = None
        for c in df_vuelos.columns:
            if 'clasificacion' in c:
                col_clasificacion = c
                break
        
        if col_clasificacion:
            registros_antes = df_vuelos.count()
            df_vuelos = df_vuelos.filter(
                ~(lower(col(col_clasificacion)) == 'internacional')
            )
            registros_despues = df_vuelos.count()
            print(f"   ✅ Vuelos internacionales excluidos: {registros_antes - registros_despues} eliminados")
        
        # 5.3. Rellenar pasajeros null con 0
        if 'pasajeros' in df_vuelos.columns:
            df_vuelos = df_vuelos.withColumn(
                'pasajeros',
                when(col('pasajeros').isNull(), 0).otherwise(col('pasajeros'))
            )
            print("   ✅ Pasajeros null reemplazados por 0")
        
        # 5.4. Convertir fecha a formato YYYY-MM-DD
        if 'fecha' in df_vuelos.columns:
            df_vuelos = df_vuelos.withColumn(
                'fecha',
                to_date(col('fecha'), 'dd/MM/yyyy')
            )
            print("   ✅ Fechas convertidas a formato Date\n")
        
        # ============================================
        # 6. SELECCIONAR Y RENOMBRAR COLUMNAS FINALES (VUELOS)
        # ============================================
        print("🔄 6. Preparando esquema final para tabla aeropuerto_tabla...")
        
        # Mapeo de columnas finales
        df_vuelos_final = df_vuelos.select(
            col('fecha'),
            col('hora utc').alias('horaUTC'),
            col('clase de vuelo').alias('clase_de_vuelo'),
            col('clasificacion vuelo').alias('clasificacion_de_vuelo'),
            col('tipo de movimiento').alias('tipo_de_movimiento'),
            col('aeropuerto'),
            col('origen / destino').alias('origen_destino'),
            col('aerolinea nombre').alias('aerolinea_nombre'),
            col('aeronave'),
            col('pasajeros').cast(IntegerType())
        )
        
        print(f"✅ Esquema final preparado: {df_vuelos_final.count()} registros\n")
        
        # ============================================
        # 7. TRANSFORMACIONES EN AEROPUERTOS
        # ============================================
        print("🔄 7. Aplicando transformaciones a aeropuertos...")
        
        # 7.1. Eliminar columnas innecesarias
        cols_aero_eliminar = ['coordenadas', 'fir', 'inhab']
        for col_name in cols_aero_eliminar:
            if col_name in df_aeropuertos.columns:
                df_aeropuertos = df_aeropuertos.drop(col_name)
        
        print("   ✅ Columnas innecesarias eliminadas")
        
        # 7.2. Rellenar distancia_ref null con 0
        if 'distancia_ref' in df_aeropuertos.columns:
            df_aeropuertos = df_aeropuertos.withColumn(
                'distancia_ref',
                when(col('distancia_ref').isNull(), 0.0)
                .otherwise(col('distancia_ref').cast(FloatType()))
            )
            print("   ✅ distancia_ref null reemplazados por 0\n")
        
        # ============================================
        # 8. PREPARAR ESQUEMA FINAL (AEROPUERTOS)
        # ============================================
        print("🔄 8. Preparando esquema final para aeropuerto_detalles_tabla...")
        
        # Debug: Mostrar columnas disponibles
        print(f"   Columnas disponibles en aeropuertos: {df_aeropuertos.columns}")
        
        # Mapear columnas reales a las esperadas
        # Nota: 'local' es el código del aeropuerto en este dataset
        df_aeropuertos_final = df_aeropuertos.select(
            col('local').alias('aeropuerto'),  # local = código del aeropuerto
            col('oaci').alias('oac'),          # oaci → oac (para compatibilidad)
            col('iata'),
            col('tipo'),
            col('denominacion'),
            col('latitud').alias('coordenadas_latitud'),
            col('longitud').alias('coordenadas_longitud'),
            col('elev').cast(FloatType()),
            col('uom_elev'),
            col('ref'),
            col('distancia_ref').cast(FloatType()),
            col('direccion_ref'),
            col('condicion'),
            col('control'),
            col('region'),
            col('uso'),
            col('trafico'),
            col('sna'),
            col('concesionado'),
            col('provincia')
        )
        
        print(f"✅ Esquema final preparado: {df_aeropuertos_final.count()} registros\n")
        
        # ============================================
        # 9. GUARDAR EN HIVE
        # ============================================
        print("💾 9. Guardando datos en Hive...")
        
        # Usar la base de datos
        spark.sql("USE aviacion")
        print("✅ Usando base de datos: aviacion")
        
        # Guardar tabla de vuelos
        df_vuelos_final.write \
            .mode("overwrite") \
            .format("hive") \
            .saveAsTable("aeropuerto_tabla")
        
        print("✅ Tabla aeropuerto_tabla guardada")
        
        # Guardar tabla de aeropuertos
        df_aeropuertos_final.write \
            .mode("overwrite") \
            .format("hive") \
            .saveAsTable("aeropuerto_detalles_tabla")
        
        print("✅ Tabla aeropuerto_detalles_tabla guardada\n")
        
        # ============================================
        # 10. VERIFICACIÓN
        # ============================================
        print("✅ 10. Verificando datos en Hive...")
        
        count_vuelos = spark.sql("SELECT COUNT(*) FROM aviacion.aeropuerto_tabla").collect()[0][0]
        count_aeropuertos = spark.sql("SELECT COUNT(*) FROM aviacion.aeropuerto_detalles_tabla").collect()[0][0]
        
        print(f"   📊 Total registros en aeropuerto_tabla: {count_vuelos}")
        print(f"   📊 Total registros en aeropuerto_detalles_tabla: {count_aeropuertos}\n")
        
        # Muestra de datos
        print("🔍 Muestra de datos en aeropuerto_tabla (primeras 5 filas):")
        spark.sql("SELECT * FROM aviacion.aeropuerto_tabla LIMIT 5").show(truncate=False)
        
        # ============================================
        # 11. RESUMEN FINAL
        # ============================================
        print("\n" + "="*60)
        print("✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE")
        print("="*60)
        print(f"\n📊 Resumen:")
        print(f"   - Registros de vuelos procesados: {count_vuelos}")
        print(f"   - Registros de aeropuertos procesados: {count_aeropuertos}")
        print(f"   - Base de datos: aviacion")
        print(f"   - Tablas creadas:")
        print(f"     • aeropuerto_tabla")
        print(f"     • aeropuerto_detalles_tabla")
        print("\n🎯 Siguiente paso: Ejecutar consultas SQL (Puntos 5-10)\n")
        
        spark.stop()
        
    except Exception as e:
        print(f"\n❌ ERROR durante el procesamiento: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()

