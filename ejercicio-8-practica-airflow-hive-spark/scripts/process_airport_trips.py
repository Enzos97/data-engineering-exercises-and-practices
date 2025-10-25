#!/usr/bin/env python3
"""
Script: process_airport_trips.py
Descripción: Procesa datos de viajes NYC Taxi con Spark y carga en Hive.
Filtra los viajes a aeropuertos pagados en efectivo.
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col

def main():
    print("=== INICIANDO PROCESAMIENTO CON SPARK ===")

    # Inicializar Spark Session con soporte para Hive
    spark = (
        SparkSession.builder
        .appName("AirportTripsProcessing")
        .config("spark.sql.adaptive.enabled", "true")
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
        .config("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
        .enableHiveSupport()
        .getOrCreate()
    )

    spark.sparkContext.setLogLevel("WARN")

    try:
        # Ruta en HDFS (ajustada con protocolo hdfs://)
        hdfs_raw_path = "hdfs://172.17.0.2:9000/user/hadoop/tripdata/raw/"

        print("1. 📂 Leyendo archivos Parquet desde HDFS...")
        df_jan = spark.read.parquet(hdfs_raw_path + "yellow_tripdata_2021-01.parquet")
        df_feb = spark.read.parquet(hdfs_raw_path + "yellow_tripdata_2021-02.parquet")

        print(f"   ✅ Enero 2021: {df_jan.count():,} registros")
        print(f"   ✅ Febrero 2021: {df_feb.count():,} registros")

        # Unir ambos meses
        print("2. 🔄 Uniendo datos de enero y febrero...")
        df_combined = df_jan.union(df_feb)
        print(f"   ✅ Total combinado: {df_combined.count():,} registros")

        # Mostrar esquema
        print("3. 📊 Esquema de datos:")
        df_combined.printSchema()

        # Filtrar viajes según criterios
        print("4. 🔍 Filtrando viajes a aeropuertos pagados en efectivo...")
        df_filtered = df_combined.filter(
            (col("airport_fee") > 0) & (col("payment_type") == 2)
        )

        filtered_count = df_filtered.count()
        print(f"   ✅ Viajes filtrados: {filtered_count:,} registros")

        # Seleccionar columnas requeridas
        print("5. 🗂️ Seleccionando columnas para tabla Hive...")
        df_final = df_filtered.select(
            col("tpep_pickup_datetime"),
            col("airport_fee"),
            col("payment_type"),
            col("tolls_amount"),
            col("total_amount"),
        )

        print("6. 👀 Muestra de datos a insertar:")
        df_final.show(10, truncate=False)

        print("7. 📈 Estadísticas de los datos:")
        df_final.describe().show()

        print("8. 💾 Insertando datos en la tabla Hive 'tripdata.airport_trips'...")
        df_final.write.mode("append").insertInto("tripdata.airport_trips")

        print("✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE")
        print(f"📊 Total de viajes insertados: {df_final.count():,}")

    except Exception as e:
        print(f"❌ ERROR durante el procesamiento: {str(e)}")
        raise e

    finally:
        spark.stop()
        print("🛑 Sesión de Spark cerrada")

if __name__ == "__main__":
    main()
