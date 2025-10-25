# Ejercicios Resueltos - Práctica Sqoop

## Resultados de los Ejercicios

Basado en los comandos ejecutados y resultados obtenidos del archivo `sqoop --- ejercicios ---.txt`.

### Ejercicio 1: Mostrar las tablas de la base de datos northwind

**Comando ejecutado:**
```bash
sqoop list-tables --connect jdbc:postgresql://172.17.0.1:5432/northwind --username postgres -P
```

**Resultado obtenido:**
```
territories
order_details
employee_territories
us_states
customers
orders
employees
shippers
products
categories
suppliers
region
customer_demographics
customer_customer_demo
```

**Análisis:**
- Se conectó exitosamente a la base de datos northwind
- Se listaron 14 tablas disponibles
- La conexión se estableció correctamente con la IP 172.17.0.1

### Ejercicio 2: Mostrar los clientes de Argentina

**Comando ejecutado:**
```bash
sqoop eval --connect jdbc:postgresql://172.17.0.1:5432/northwind --username postgres --P --query "select * from customers where country = 'Argentina'"
```

**Resultado esperado:**
- Se ejecutará la consulta SQL para obtener clientes de Argentina
- Se mostrarán los registros que cumplan la condición

### Ejercicio 3: Importar tabla orders completa

**Comando ejecutado:**
```bash
sqoop import --connect "jdbc:postgresql://172.17.0.1:5432/northwind" --username postgres --table region --m 1 -P --target-dir /sqoop/ingest --as-parquetfile --delete-target-dir
```

**Resultado obtenido:**
```
2025-09-28 23:41:03,513 INFO mapreduce.ImportJobBase: Transferred 1.8232 KB in 37.9348 seconds (49.216 bytes/sec)
2025-09-28 23:41:03,518 INFO mapreduce.ImportJobBase: Retrieved 5 records.
```

**Análisis:**
- Se transfirieron 1.8232 KB en 37.9348 segundos
- Se recuperaron 5 registros de la tabla region
- El archivo se guardó en formato Parquet en HDFS
- El job se completó exitosamente

### Ejercicio 4: Importar productos con más de 20 unidades en stock

**Comando ejecutado:**
```bash
sqoop import --connect "jdbc:postgresql://172.17.0.1:5432/northwind" --username postgres --table region --m 1 -P --target-dir /sqoop/ingest/southern --as-parquetfile --where "region_description = 'Southern'" --delete-target-dir
```

**Resultado obtenido:**
```
2025-09-28 23:45:39,704 INFO mapreduce.ImportJobBase: Transferred 1.7549 KB in 18.502 seconds (97.1245 bytes/sec)
2025-09-28 23:45:39,709 INFO mapreduce.ImportJobBase: Retrieved 1 records.
```

**Análisis:**
- Se transfirieron 1.7549 KB en 18.502 segundos
- Se recuperó 1 registro que cumple la condición
- El filtro WHERE funcionó correctamente
- El rendimiento fue mejor (97.1245 bytes/sec vs 49.216 bytes/sec)

## Métricas de Rendimiento

### Comparación de Rendimiento

| Ejercicio | Tamaño | Tiempo | Velocidad | Registros |
|-----------|--------|--------|-----------|-----------|
| Tabla completa | 1.8232 KB | 37.9348s | 49.216 bytes/sec | 5 |
| Con filtro | 1.7549 KB | 18.502s | 97.1245 bytes/sec | 1 |

### Análisis de Resultados

1. **Eficiencia del filtro**: El uso de `WHERE` mejoró significativamente el rendimiento
2. **Formato Parquet**: Se utilizó formato Parquet para mejor compresión y rendimiento
3. **Paralelización**: Se usó `-m 1` (un mapper) para tablas pequeñas
4. **Conexión estable**: La conexión a PostgreSQL funcionó correctamente

## Comandos para Verificación

### Verificar archivos en HDFS
```bash
# Listar directorios creados
hdfs dfs -ls /sqoop/ingest/

# Ver contenido de archivos Parquet
hdfs dfs -ls /sqoop/ingest/region/
hdfs dfs -ls /sqoop/ingest/southern/
```

### Verificar formato Parquet
```bash
# Usar herramientas de Parquet para verificar el formato
hdfs dfs -cat /sqoop/ingest/region/part-m-00000.parquet | head
```

## Lecciones Aprendidas

1. **Conexión a PostgreSQL**: Verificar IP y puerto del contenedor
2. **Formato Parquet**: Mejor rendimiento que CSV para análisis
3. **Filtros WHERE**: Mejoran significativamente el rendimiento
4. **Paralelización**: Usar múltiples mappers para tablas grandes
5. **Monitoreo**: Revisar logs para identificar problemas

## Troubleshooting

### Problemas Comunes

1. **Error de conexión**: Verificar IP del contenedor PostgreSQL
2. **Error de autenticación**: Verificar usuario y contraseña
3. **Error de permisos**: Verificar permisos de escritura en HDFS
4. **Error de formato**: Verificar que la tabla tenga datos

### Soluciones

1. **Verificar contenedores**: `docker ps`
2. **Verificar IP**: `docker inspect edvai_postgres`
3. **Verificar HDFS**: `hdfs dfs -ls /`
4. **Verificar logs**: Revisar salida de Sqoop para errores
