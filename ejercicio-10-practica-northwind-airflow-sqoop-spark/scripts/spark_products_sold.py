#!/usr/bin/env python3
"""
Script: spark_products_sold.py
Descripción: Procesa datos de clientes y crea tabla products_sold en Hive
             con compañías que tienen productos vendidos mayor al promedio
Autor: Hadoop
Fecha: 2025-11-12
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, max, min
from pyspark.sql.types import StructType, StructField, StringType, LongType

def main():
    print("=== INICIANDO PROCESAMIENTO SPARK PARA PRODUCTS_SOLD ===")

    # Inicializar Spark Session con soporte para Hive
    spark = (
        SparkSession.builder
        .appName("NorthwindProductsSold")
        .config("spark.sql.adaptive.enabled", "true")
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
        .enableHiveSupport()
        .getOrCreate()
    )

    spark.sparkContext.setLogLevel("WARN")

    try:
        # Ruta de los datos en HDFS
        customers_path = "hdfs://172.17.0.2:9000/sqoop/ingest/customers"
        
        # Base de datos destino
        database_name = "northwind_analytics"
        table_name = "products_sold"
        
        print("1. 📂 Leyendo datos de clientes desde HDFS...")
        
        # Leer archivos Parquet
        df_customers = spark.read.parquet(customers_path)
        
        print(f"   ✅ Datos cargados: {df_customers.count():,} registros")
        print("   📊 Esquema de datos:")
        df_customers.printSchema()
        
        # Mostrar sample de datos
        print("   🔍 Muestra de datos originales:")
        df_customers.show(10, truncate=False)

        # ============================================
        # CALCULAR PROMEDIO Y FILTRAR
        # ============================================
        print("\n2. 📈 Calculando promedio de productos vendidos...")
        
        # Calcular el promedio
        avg_products = df_customers.select(avg("productos_vendidos")).collect()[0][0]
        print(f"   ✅ Promedio de productos vendidos: {avg_products:.2f}")
        
        # Filtrar compañías con productos vendidos mayor al promedio
        print("3. 🔍 Filtrando compañías con productos vendidos > promedio...")
        df_filtered = df_customers.filter(col("productos_vendidos") > avg_products)
        
        print(f"   ✅ Compañías filtradas: {df_filtered.count():,} de {df_customers.count():,}")
        
        # Ordenar por productos vendidos (descendente)
        df_final = df_filtered.orderBy(col("productos_vendidos").desc())
        
        print("   📋 Resultados filtrados (ordenados por productos vendidos):")
        df_final.show(truncate=False)

        # ============================================
        # GUARDAR EN HIVE
        # ============================================
        print("\n4. 💾 Creando/Actualizando tabla en Hive...")
        
        # Asegurarse que la base de datos existe
        spark.sql(f"CREATE DATABASE IF NOT EXISTS {database_name}")
        spark.sql(f"USE {database_name}")
        
        print(f"   ✅ Usando base de datos: {database_name}")
        
        # Guardar en tabla Hive
        df_final.write \
            .mode("overwrite") \
            .saveAsTable(f"{database_name}.{table_name}")
        
        print(f"   ✅ Tabla '{table_name}' creada/actualizada en Hive")
        
        # ============================================
        # VERIFICACIÓN
        # ============================================
        print("\n5. ✅ Verificando datos en Hive...")
        
        # Contar registros en la tabla
        count_result = spark.sql(f"SELECT COUNT(*) as total FROM {database_name}.{table_name}").collect()[0]["total"]
        print(f"   📊 Total de registros en tabla Hive: {count_result:,}")
        
        # Mostrar datos de la tabla
        print("   🔍 Datos en tabla Hive:")
        spark.sql(f"SELECT * FROM {database_name}.{table_name} ORDER BY productos_vendidos DESC").show(truncate=False)
        
        # Mostrar estadísticas
        print("   📈 Estadísticas finales:")
        df_final.agg(
            avg("productos_vendidos").alias("promedio"),
            max("productos_vendidos").alias("maximo"),
            min("productos_vendidos").alias("minimo")
        ).show()
        
        print("\n✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE")
        print(f"📊 Compañías procesadas: {df_final.count():,}")
        print(f"💾 Tabla Hive: {database_name}.{table_name}")

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

