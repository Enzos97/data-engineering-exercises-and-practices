#!/usr/bin/env python3
"""
Script: spark_products_sent.py
Descripción: Procesa datos de órdenes y detalles para crear tabla products_sent en Hive
             con pedidos que tuvieron descuento
Autor: Hadoop
Fecha: 2025-11-12
"""

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, round
from pyspark.sql.types import DecimalType

def main():
    print("=== INICIANDO PROCESAMIENTO SPARK PARA PRODUCTS_SENT ===")

    # Inicializar Spark Session con soporte para Hive
    spark = (
        SparkSession.builder
        .appName("NorthwindProductsSent")
        .config("spark.sql.adaptive.enabled", "true")
        .config("spark.sql.adaptive.coalescePartitions.enabled", "true")
        .enableHiveSupport()
        .getOrCreate()
    )

    spark.sparkContext.setLogLevel("WARN")

    try:
        # Rutas de los datos en HDFS
        envios_path = "hdfs://172.17.0.2:9000/sqoop/ingest/envios"
        order_details_path = "hdfs://172.17.0.2:9000/sqoop/ingest/order_details"
        
        # Base de datos destino
        database_name = "northwind_analytics"
        table_name = "products_sent"
        
        print("1. 📂 Leyendo datos desde HDFS...")
        
        # Leer archivos Parquet
        df_envios = spark.read.parquet(envios_path)
        df_order_details = spark.read.parquet(order_details_path)
        
        print(f"   ✅ Envíos cargados: {df_envios.count():,} registros")
        print(f"   ✅ Detalles de órdenes cargados: {df_order_details.count():,} registros")
        
        print("   📊 Esquema de envíos:")
        df_envios.printSchema()
        print("   📊 Esquema de detalles:")
        df_order_details.printSchema()
        
        # Mostrar samples
        print("   🔍 Muestra de envíos:")
        df_envios.show(5, truncate=False)
        print("   🔍 Muestra de detalles:")
        df_order_details.show(5, truncate=False)

        # ============================================
        # PROCESAMIENTO DE DATOS
        # ============================================
        print("\n2. 🔄 Procesando y uniendo datos...")
        
        # Filtrar detalles que tuvieron descuento
        df_descuento = df_order_details.filter(col("discount") > 0)
        print(f"   ✅ Detalles con descuento: {df_descuento.count():,}")
        
        # Calcular unit_price con descuento y total_price
        df_detalles_procesados = df_descuento.withColumn(
            "unit_price_discount", 
            col("unit_price") * (1 - col("discount"))
        ).withColumn(
            "total_price",
            col("unit_price_discount") * col("quantity")
        )
        
        # Unir con información de envíos
        df_final = df_detalles_procesados.join(
            df_envios,
            "order_id",
            "inner"
        )
        
        print(f"   ✅ Registros después del JOIN: {df_final.count():,}")
        
        # Seleccionar y ordenar columnas finales
        df_resultado = df_final.select(
            col("order_id"),
            col("shipped_date"),
            col("company_name"),
            col("phone"),
            round(col("unit_price_discount"), 2).alias("unit_price_discount"),
            col("quantity"),
            round(col("total_price"), 2).alias("total_price")
        ).orderBy(col("order_id"))
        
        print("   📋 Resultados finales (primeros 10):")
        df_resultado.show(10, truncate=False)

        # ============================================
        # GUARDAR EN HIVE
        # ============================================
        print("\n3. 💾 Creando/Actualizando tabla en Hive...")
        
        # Asegurarse que la base de datos existe
        spark.sql(f"CREATE DATABASE IF NOT EXISTS {database_name}")
        spark.sql(f"USE {database_name}")
        
        print(f"   ✅ Usando base de datos: {database_name}")
        
        # Guardar en tabla Hive
        df_resultado.write \
            .mode("overwrite") \
            .saveAsTable(f"{database_name}.{table_name}")
        
        print(f"   ✅ Tabla '{table_name}' creada/actualizada en Hive")
        
        # ============================================
        # VERIFICACIÓN
        # ============================================
        print("\n4. ✅ Verificando datos en Hive...")
        
        # Contar registros en la tabla
        count_result = spark.sql(f"SELECT COUNT(*) as total FROM {database_name}.{table_name}").collect()[0]["total"]
        print(f"   📊 Total de registros en tabla Hive: {count_result:,}")
        
        # Mostrar datos de la tabla
        print("   🔍 Datos en tabla Hive (primeros 10):")
        spark.sql(f"SELECT * FROM {database_name}.{table_name} ORDER BY order_id LIMIT 10").show(truncate=False)
        
        # Estadísticas de precios
        print("   📈 Estadísticas de precios:")
        spark.sql(f"""
            SELECT 
                COUNT(*) as total_pedidos,
                ROUND(AVG(total_price), 2) as precio_promedio,
                ROUND(MAX(total_price), 2) as precio_maximo,
                ROUND(MIN(total_price), 2) as precio_minimo
            FROM {database_name}.{table_name}
        """).show(truncate=False)
        
        print("\n✅ PROCESAMIENTO COMPLETADO EXITOSAMENTE")
        print(f"📊 Pedidos con descuento procesados: {df_resultado.count():,}")
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

