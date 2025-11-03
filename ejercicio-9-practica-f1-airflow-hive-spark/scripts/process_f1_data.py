#!/usr/bin/env python3
"""
Script: process_f1_data.py
Descripción: Procesa datos de Formula 1 con Spark y genera archivos para tablas Hive.
- Punto 4a: Corredores con mayor cantidad de puntos en la historia
- Punto 4b: Constructores con más puntos en Spanish Grand Prix 1991
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, sum as spark_sum, desc

def main():
    print("=== INICIANDO PROCESAMIENTO DE DATOS F1 CON SPARK ===")

    # Inicializar Spark Session con soporte para Hive
    spark = (
        SparkSession.builder
        .appName("F1DataProcessing")
        .config("spark.sql.adaptive.enabled", "true")
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
        .enableHiveSupport()
        .getOrCreate()
    )

    spark.sparkContext.setLogLevel("WARN")

    try:
        # Ruta en HDFS para los archivos CSV
        hdfs_raw_path = "hdfs://172.17.0.2:9000/user/hadoop/f1/raw/"
        
        # Rutas de destino para las tablas externas
        driver_results_path = "hdfs://172.17.0.2:9000/user/hive/warehouse/f1.db/driver_results/"
        constructor_results_path = "hdfs://172.17.0.2:9000/user/hive/warehouse/f1.db/constructor_results/"

        print("1. 📂 Leyendo archivos CSV desde HDFS...")
        
        # Leer archivos CSV con header
        df_results = spark.read.option("header", "true").option("inferSchema", "true").csv(hdfs_raw_path + "results.csv")
        df_drivers = spark.read.option("header", "true").option("inferSchema", "true").csv(hdfs_raw_path + "drivers.csv")
        df_constructors = spark.read.option("header", "true").option("inferSchema", "true").csv(hdfs_raw_path + "constructors.csv")
        df_races = spark.read.option("header", "true").option("inferSchema", "true").csv(hdfs_raw_path + "races.csv")

        print(f"   ✅ results.csv: {df_results.count():,} registros")
        print(f"   ✅ drivers.csv: {df_drivers.count():,} registros")
        print(f"   ✅ constructors.csv: {df_constructors.count():,} registros")
        print(f"   ✅ races.csv: {df_races.count():,} registros")

        # Mostrar esquemas
        print("\n2. 📊 Esquemas de datos:")
        print("   Esquema de results:")
        df_results.printSchema()
        print("   Esquema de drivers:")
        df_drivers.printSchema()
        print("   Esquema de constructors:")
        df_constructors.printSchema()
        print("   Esquema de races:")
        df_races.printSchema()

        # ============================================
        # PUNTO 4a: Corredores con mayor cantidad de puntos en la historia
        # ============================================
        print("\n3. 🏎️ Procesando punto 4a: Corredores con mayor cantidad de puntos...")
        
        # Hacer JOIN entre results y drivers para obtener información de corredores
        df_driver_points = df_results.join(
            df_drivers,
            df_results.driverId == df_drivers.driverId,
            "inner"
        ).groupBy(
            df_drivers.forename.alias("driver_forename"),
            df_drivers.surname.alias("driver_surname"),
            df_drivers.nationality.alias("driver_nationality")
        ).agg(
            spark_sum(df_results.points).alias("points")
        ).orderBy(desc("points"))

        print(f"   ✅ Total de corredores únicos: {df_driver_points.count():,}")
        print("   📋 Top 10 corredores por puntos:")
        df_driver_points.show(10, truncate=False)

        # Seleccionar columnas para la tabla driver_results
        df_driver_results = df_driver_points.select(
            col("driver_forename"),
            col("driver_surname"),
            col("driver_nationality"),
            col("points")
        )

        print("\n4. 💾 Guardando driver_results en HDFS...")
        df_driver_results.coalesce(1).write.mode("overwrite").option("header", "true").csv(driver_results_path)
        print(f"   ✅ Datos guardados en: {driver_results_path}")

        # ============================================
        # PUNTO 4b: Constructores con más puntos en Spanish Grand Prix 1991
        # ============================================
        print("\n5. 🏁 Procesando punto 4b: Constructores con más puntos en Spanish Grand Prix 1991...")
        
        # Filtrar races por Spanish Grand Prix y año 1991
        df_spanish_gp_1991 = df_races.filter(
            (col("name").like("%Spanish Grand Prix%")) & 
            (col("year") == 1991)
        )
        
        print(f"   ✅ Carreras encontradas: {df_spanish_gp_1991.count()}")

        # Hacer JOIN entre results, constructors y races
        df_constructor_points = df_results.join(
            df_constructors,
            df_results.constructorId == df_constructors.constructorId,
            "inner"
        ).join(
            df_spanish_gp_1991,
            df_results.raceId == df_spanish_gp_1991.raceId,
            "inner"
        ).groupBy(
            df_constructors.constructorRef.alias("constructorRef"),
            df_constructors.name.alias("cons_name"),
            df_constructors.nationality.alias("cons_nationality"),
            df_constructors.url.alias("url")
        ).agg(
            spark_sum(df_results.points).alias("points")
        ).orderBy(desc("points"))

        print(f"   ✅ Total de constructores: {df_constructor_points.count():,}")
        print("   📋 Resultados de constructores en Spanish GP 1991:")
        df_constructor_points.show(truncate=False)

        # Seleccionar columnas para la tabla constructor_results
        df_constructor_results = df_constructor_points.select(
            col("constructorRef"),
            col("cons_name"),
            col("cons_nationality"),
            col("url"),
            col("points")
        )

        print("\n6. 💾 Guardando constructor_results en HDFS...")
        df_constructor_results.coalesce(1).write.mode("overwrite").option("header", "true").csv(constructor_results_path)
        print(f"   ✅ Datos guardados en: {constructor_results_path}")

        # Verificación final
        print("\n7. ✅ Verificación de datos guardados:")
        print("   📊 Resumen de driver_results:")
        df_driver_results.describe().show()
        print("   📊 Resumen de constructor_results:")
        df_constructor_results.describe().show()

        print("\n✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE")
        print(f"📊 Corredores procesados: {df_driver_results.count():,}")
        print(f"📊 Constructores procesados: {df_constructor_results.count():,}")

    except Exception as e:
        print(f"❌ ERROR durante el procesamiento: {str(e)}")
        import traceback
        traceback.print_exc()
        raise e

    finally:
        spark.stop()
        print("🛑 Sesión de Spark cerrada")

if __name__ == "__main__":
    main()

