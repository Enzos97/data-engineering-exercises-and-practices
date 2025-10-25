# Práctica Sqoop - Importación de Datos desde PostgreSQL

## Configuración Inicial

### Verificar Contenedores
Antes de comenzar, verificar que los contenedores estén ejecutándose:

```bash
# Verificar contenedor PostgreSQL
docker inspect edvai_postgres

# Verificar puerto (por defecto 5432)
# La IP del contenedor se puede obtener del comando anterior
```

### Credenciales
- **Usuario**: postgres
- **Contraseña**: edvai
- **Base de datos**: northwind

## Comandos Básicos

### 1. Listar Bases de Datos
```bash
sqoop list-databases \
  --connect jdbc:postgresql://172.17.0.3:5432/northwind \
  --username postgres -P
```

### 2. Listar Tablas
```bash
sqoop list-tables \
  --connect jdbc:postgresql://172.17.0.3:5432/northwind \
  --username postgres -P
```

### 3. Ejecutar Consultas
```bash
sqoop eval \
  --connect jdbc:postgresql://172.17.0.3:5432/northwind \
  --username postgres \
  --P \
  --query "select * from region limit 10"
```

## Ejercicios Resueltos

### Ejercicio 1: Mostrar las tablas de la base de datos northwind

**Comando ejecutado:**
```bash
sqoop list-tables --connect jdbc:postgresql://172.17.0.1:5432/northwind --username postgres -P
```

**Resultado:**
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

### Ejercicio 2: Mostrar los clientes de Argentina

**Comando ejecutado:**
```bash
sqoop eval --connect jdbc:postgresql://172.17.0.1:5432/northwind --username postgres --P --query "select * from customers where country = 'Argentina'"
```

### Ejercicio 3: Importar tabla orders completa

**Comando ejecutado:**
```bash
sqoop import \
  --connect "jdbc:postgresql://172.17.0.1:5432/northwind" \
  --username postgres \
  --table orders \
  --m 1 \
  --P \
  --target-dir /sqoop/ingest/orders \
  --as-parquetfile \
  --delete-target-dir
```

**Resultado:**
- Se importaron todos los registros de la tabla orders
- Archivo guardado en formato Parquet en HDFS: `/sqoop/ingest/orders`
- Se transfirieron los datos exitosamente

### Ejercicio 4: Importar productos con más de 20 unidades en stock

**Comando ejecutado:**
```bash
sqoop import \
  --connect "jdbc:postgresql://172.17.0.1:5432/northwind" \
  --username postgres \
  --table products \
  --m 1 \
  --P \
  --target-dir /sqoop/ingest/products_high_stock \
  --as-parquetfile \
  --where "units_in_stock > 20" \
  --delete-target-dir
```

## Parámetros Importantes

- `--connect`: URL de conexión JDBC
- `--username`: Usuario de la base de datos
- `--P`: Solicita contraseña de forma interactiva
- `--table`: Nombre de la tabla a importar
- `--m`: Número de mappers (paralelización)
- `--target-dir`: Directorio destino en HDFS
- `--as-parquetfile`: Formato de salida Parquet
- `--where`: Condición WHERE para filtrar datos
- `--delete-target-dir`: Elimina el directorio destino si existe

## Scripts Automatizados

### Ejecutar Script Completo
```bash
# Ejecutar todos los ejercicios de una vez
./scripts/sqoop-exercises.sh
```

### Scripts Disponibles
- `scripts/sqoop-exercises.sh` - Script completo con todos los ejercicios
- `scripts/README.md` - Documentación de los scripts

## Verificación de Resultados

Para verificar que los datos se importaron correctamente:

```bash
# Listar archivos en HDFS
hdfs dfs -ls /sqoop/ingest/

# Ver contenido de un archivo Parquet
hdfs dfs -cat /sqoop/ingest/orders/part-m-00000.parquet | head
```

## Notas Importantes

1. **Puerto de PostgreSQL**: Verificar que el puerto sea 5432, puede variar según configuración
2. **IP del Contenedor**: La IP puede cambiar entre ejecuciones de Docker
3. **Formato Parquet**: Mejor rendimiento y compresión que CSV
4. **Paralelización**: Usar `--m` para mejorar rendimiento en tablas grandes
