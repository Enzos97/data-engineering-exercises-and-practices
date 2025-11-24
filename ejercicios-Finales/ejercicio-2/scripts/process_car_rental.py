#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
=====================================================
Script: process_car_rental.py
Descripción: Procesa datos de Car Rental y los carga en Hive
Autor: Data Engineering Team
Fecha: 2025-11-22
PUNTO 3: Transformaciones y carga en Hive
=====================================================
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, lower, trim, round as spark_round
import sys

def main():
    print("\n" + "="*60)
    print("🚗 CAR RENTAL DATA PROCESSING")
    print("="*60 + "\n")
    
    try:
        # ============================================
        # 1. CREAR SESIÓN DE SPARK
        # ============================================
        print("📊 1. Creando sesión de Spark con Hive...")
        spark = SparkSession.builder \
            .appName("CarRentalProcessing") \
            .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
            .config("hive.metastore.uris", "thrift://localhost:9083") \
            .enableHiveSupport() \
            .getOrCreate()
        
        print("✅ Sesión de Spark creada exitosamente\n")
        
        # ============================================
        # 2. LEER ARCHIVO CARRENTALDATA
        # ============================================
        print("📂 2. Leyendo CarRentalData.csv desde HDFS...")
        car_rental_path = "hdfs://172.17.0.2:9000/car_rental/raw/CarRentalData.csv"
        
        df_rental = spark.read \
            .option("header", "true") \
            .option("inferSchema", "true") \
            .csv(car_rental_path)
        
        print(f"✅ Datos cargados: {df_rental.count()} registros")
        print(f"📋 Total de columnas: {len(df_rental.columns)}")
        print("\n🔍 Muestra de datos originales (primeras 3 filas):")
        df_rental.show(3, truncate=True)
        
        # ============================================
        # 3. LEER ARCHIVO GEOREF USA STATES
        # ============================================
        print("\n📂 3. Leyendo georef_usa_states.csv desde HDFS...")
        georef_path = "hdfs://172.17.0.2:9000/car_rental/raw/georef_usa_states.csv"
        
        df_states = spark.read \
            .option("header", "true") \
            .option("inferSchema", "true") \
            .option("delimiter", ";") \
            .csv(georef_path)
        
        print(f"✅ Datos cargados: {df_states.count()} registros")
        print(f"📋 Total de columnas: {len(df_states.columns)}")
        print("\n🔍 Muestra de datos originales (primeras 3 filas):")
        df_states.show(3, truncate=True)
        
        # ============================================
        # 4. TRANSFORMACIÓN: RENOMBRAR COLUMNAS
        # ============================================
        print("\n🔄 4. Renombrando columnas (quitar espacios y puntos)...")
        
        # Renombrar columnas usando select() con alias() para columnas con puntos
        df_rental = df_rental.select(
            col("fuelType").alias("fuelType"),
            col("rating").alias("rating"),
            col("renterTripsTaken").alias("renterTripsTaken"),
            col("reviewCount").alias("reviewCount"),
            col("`location.city`").alias("city"),
            col("`location.country`").alias("country"),
            col("`location.latitude`").alias("lat"),
            col("`location.longitude`").alias("lng"),
            col("`location.state`").alias("state"),
            col("`owner.id`").alias("owner_id"),
            col("`rate.daily`").alias("rate_daily"),
            col("`vehicle.make`").alias("make"),
            col("`vehicle.model`").alias("model"),
            col("`vehicle.type`").alias("vehicle_type"),
            col("`vehicle.year`").alias("year")
        )
        
        print("✅ Columnas de CarRentalData renombradas")
        
        print("\n🔍 Columnas después del renombrado:")
        print(f"   {', '.join(df_rental.columns)}")
        
        # Verificar que "state" existe ahora
        if "state" in df_rental.columns:
            print("✅ Columna 'state' renombrada correctamente")
        else:
            print("❌ ERROR: Columna 'state' no encontrada después del renombrado")
            print(f"   Columnas disponibles: {df_rental.columns}")
        
        # Limpiar columnas en georef (seleccionar solo las necesarias)
        print("\n🔄 Seleccionando columnas relevantes de georef...")
        
        # Verificar cantidad de columnas
        print(f"Columnas disponibles en georef: {len(df_states.columns)} columnas")
        
        # Buscar columnas que contengan 'state' o 'code'
        state_related_cols = [c for c in df_states.columns if 'state' in c.lower() or 'code' in c.lower() or 'postal' in c.lower()]
        print(f"Columnas relacionadas con estado: {state_related_cols[:3]}...")
        
        # Usar la abreviatura postal de USPS (TX, CA, NY, etc.) para hacer el JOIN
        # No usar "Official Code State" que son números FIPS (1, 2, 4, etc.)
        df_states = df_states.select(
            col("`United States Postal Service state abbreviation`").alias("state_code"),
            col("`Official Name State`").alias("state_name")
        )
        
        print("✅ Columnas de georef seleccionadas y renombradas")
        
        # ============================================
        # 5. TRANSFORMACIÓN: REDONDEAR Y CASTEAR RATING
        # ============================================
        print("\n🔄 5. Redondeando y casteando 'rating' a INT...")
        
        df_rental = df_rental.withColumn(
            "rating",
            spark_round(col("rating")).cast("integer")
        )
        
        print("✅ Rating redondeado y casteado a INT")
        
        # ============================================
        # 6. TRANSFORMACIÓN: ELIMINAR RATING NULO
        # ============================================
        print("\n🔄 6. Eliminando registros con rating nulo...")
        
        registros_antes = df_rental.count()
        df_rental = df_rental.filter(col("rating").isNotNull())
        registros_despues = df_rental.count()
        registros_eliminados = registros_antes - registros_despues
        
        print(f"✅ Registros eliminados: {registros_eliminados}")
        print(f"   Registros restantes: {registros_despues}")
        
        # ============================================
        # 7. TRANSFORMACIÓN: MINÚSCULAS EN FUELTYPE
        # ============================================
        print("\n🔄 7. Convirtiendo 'fuelType' a minúsculas...")
        
        df_rental = df_rental.withColumn(
            "fuelType",
            lower(trim(col("fuelType")))
        )
        
        print("✅ fuelType convertido a minúsculas")
        print("\n🔍 Valores únicos de fuelType:")
        df_rental.select("fuelType").distinct().show(10, truncate=False)
        
        # ============================================
        # 8. TRANSFORMACIÓN: EXCLUIR TEXAS (ANTES DEL JOIN)
        # ============================================
        print("\n🔄 8. Excluyendo estado de Texas (antes del JOIN)...")
        
        registros_antes = df_rental.count()
        
        # Filtrar Texas por código de estado (antes del JOIN es más eficiente)
        df_rental_sin_texas = df_rental.filter(col("state") != "TX")
        
        registros_despues = df_rental_sin_texas.count()
        registros_eliminados = registros_antes - registros_despues
        
        print(f"✅ Registros de Texas eliminados: {registros_eliminados}")
        print(f"   Registros restantes: {registros_despues}")
        
        # ============================================
        # 9. TRANSFORMACIÓN: JOIN CON GEOREF
        # ============================================
        print("\n🔄 9. Realizando JOIN entre car_rental y georef...")
        
        # Mostrar muestra de códigos de estado antes del JOIN
        print("\n🔍 Códigos de estado en car_rental (sample):")
        df_rental_sin_texas.select("state").distinct().show(10)
        
        print("\n🔍 Códigos de estado en georef (sample):")
        df_states.select("state_code").show(10)
        
        # Join usando state y state_code
        df_joined = df_rental_sin_texas.join(
            df_states,
            df_rental_sin_texas["state"] == df_states["state_code"],
            "left"
        )
        
        print(f"✅ JOIN completado: {df_joined.count()} registros")
        
        # Verificar cuántos registros tienen state_name NULL después del JOIN
        null_state_names = df_joined.filter(col("state_name").isNull()).count()
        print(f"⚠️  Registros con state_name NULL después del JOIN: {null_state_names}")
        
        if null_state_names > 0:
            print(f"   Esto es normal si no todos los códigos de estado tienen match en georef")
            print(f"   Estos registros mantendrán state_name como NULL")
        
        # ============================================
        # 10. SELECCIONAR COLUMNAS FINALES
        # ============================================
        print("\n🔄 10. Seleccionando columnas finales para Hive...")
        
        # Asegurarse de que las columnas existen antes de seleccionar
        columnas_disponibles = df_joined.columns
        print(f"   Columnas disponibles después del JOIN: {len(columnas_disponibles)}")
        
        df_final = df_joined.select(
            col("fuelType"),
            col("rating"),
            col("renterTripsTaken"),
            col("reviewCount"),
            col("city"),
            col("state_name"),
            col("owner_id"),
            col("rate_daily"),
            col("make"),
            col("model"),
            col("year")
        )
        
        print("✅ Columnas finales seleccionadas")
        print(f"   Total de registros en df_final: {df_final.count()}")
        print("\n📋 Esquema final:")
        df_final.printSchema()
        
        print("\n🔍 Muestra de datos finales (primeras 5 filas):")
        df_final.show(5, truncate=True)
        
        # ============================================
        # 11. VERIFICAR CALIDAD DE DATOS
        # ============================================
        print("\n📊 11. Verificando calidad de datos...")
        
        print(f"   Total de registros: {df_final.count()}")
        print(f"   Registros con rating nulo: {df_final.filter(col('rating').isNull()).count()}")
        print(f"   Registros con state_name nulo: {df_final.filter(col('state_name').isNull()).count()}")
        
        print("\n📊 Estadísticas de rating:")
        df_final.select("rating").describe().show()
        
        print("\n📊 Top 5 estados por cantidad de registros:")
        df_final.groupBy("state_name").count().orderBy(col("count").desc()).show(5)
        
        # ============================================
        # 12. INSERTAR EN HIVE
        # ============================================
        print("\n💾 12. Insertando datos en Hive...")
        
        # Verificar que hay datos para insertar
        total_a_insertar = df_final.count()
        if total_a_insertar == 0:
            print("❌ ERROR: No hay datos para insertar en Hive!")
            print("   El DataFrame final está vacío.")
            spark.stop()
            sys.exit(1)
        
        print(f"   Preparando inserción de {total_a_insertar} registros...")
        
        # Usar la base de datos
        spark.sql("USE car_rental_db")
        print("✅ Usando base de datos: car_rental_db")
        
        # Insertar datos (modo overwrite para limpiar datos anteriores)
        print("   Escribiendo datos en Hive...")
        df_final.write \
            .mode("overwrite") \
            .format("hive") \
            .saveAsTable("car_rental_analytics")
        
        print(f"✅ Datos insertados en tabla: car_rental_analytics ({total_a_insertar} registros)")
        
        # ============================================
        # 13. VERIFICAR INSERCIÓN
        # ============================================
        print("\n✅ 13. Verificando inserción en Hive...")
        
        df_verificacion = spark.sql("SELECT COUNT(*) as total FROM car_rental_db.car_rental_analytics")
        total_registros = df_verificacion.collect()[0]["total"]
        
        print(f"✅ Total de registros en Hive: {total_registros}")
        
        # Mostrar muestra de datos en Hive
        print("\n🔍 Muestra de datos en Hive (primeras 5 filas):")
        spark.sql("SELECT * FROM car_rental_db.car_rental_analytics LIMIT 5").show(truncate=True)
        
        # ============================================
        # 14. RESUMEN FINAL
        # ============================================
        print("\n" + "="*60)
        print("✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE")
        print("="*60)
        print(f"\n📊 Resumen:")
        print(f"   - Registros procesados: {total_registros}")
        print(f"   - Base de datos: car_rental_db")
        print(f"   - Tabla: car_rental_analytics")
        print(f"   - Estado Texas excluido: ✅")
        print(f"   - Rating nulos eliminados: ✅")
        print(f"   - fuelType en minúsculas: ✅")
        print(f"   - JOIN con georef: ✅")
        print("\n🎯 Siguiente paso: Ejecutar consultas SQL en Hive\n")
        
        # Cerrar sesión
        spark.stop()
        
    except Exception as e:
        print(f"\n❌ ERROR durante el procesamiento: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()

