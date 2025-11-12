# Imágenes - Capturas de Pantalla

Este directorio contiene las capturas de pantalla de los ejercicios completados.

## 📸 Capturas Requeridas

### Ejercicio 1: Base de Datos Hive

**Archivo**: `ejercicio1-create-database.png`

**Contenido**:
- Comando `CREATE DATABASE northwind_analytics`
- Comando `SHOW DATABASES`
- Verificación de la base de datos creada

**Comando para capturar**:
```bash
hive -e "
CREATE DATABASE IF NOT EXISTS northwind_analytics;
SHOW DATABASES;
USE northwind_analytics;
"
```

---

### Ejercicio 2: Import Clientes con Sqoop

**Archivo**: `ejercicio2-sqoop-clientes.png`

**Contenido**:
- Salida completa del script `sqoop_import_clientes.sh`
- Job de MapReduce completado exitosamente
- Verificación en HDFS con tamaño del archivo

**Comando para capturar**:
```bash
bash /home/hadoop/scripts/sqoop_import_clientes.sh
hdfs dfs -ls -h /sqoop/ingest/customers
```

---

### Ejercicio 3: Import Envíos con Sqoop

**Archivo**: `ejercicio3-sqoop-envios.png`

**Contenido**:
- Salida completa del script `sqoop_import_envios.sh`
- Job de MapReduce completado exitosamente
- Verificación en HDFS con tamaño del archivo

**Comando para capturar**:
```bash
bash /home/hadoop/scripts/sqoop_import_envios.sh
hdfs dfs -ls -h /sqoop/ingest/envios
```

---

### Ejercicio 4: Import Order Details con Sqoop

**Archivo**: `ejercicio4-sqoop-order-details.png`

**Contenido**:
- Salida completa del script `sqoop_import_order_details.sh`
- Job de MapReduce completado exitosamente
- Verificación en HDFS con tamaño del archivo

**Comando para capturar**:
```bash
bash /home/hadoop/scripts/sqoop_import_order_details.sh
hdfs dfs -ls -h /sqoop/ingest/order_details
```

---

### Ejercicio 5: Spark Products Sold

**Archivo**: `ejercicio5-spark-products-sold.png`

**Contenido**:
- Salida del script mostrando:
  - Datos cargados
  - Promedio calculado
  - Compañías filtradas
  - Tabla creada en Hive
  - Verificación de registros

**Comando para capturar**:
```bash
spark-submit /home/hadoop/scripts/spark_products_sold.py
```

**Archivo adicional**: `ejercicio5-verify-products-sold.png`

**Contenido**:
- Consulta en Hive/Beeline:
```sql
USE northwind_analytics;
SELECT COUNT(*) FROM products_sold;
SELECT * FROM products_sold ORDER BY productos_vendidos DESC LIMIT 10;
```

---

### Ejercicio 6: Spark Products Sent

**Archivo**: `ejercicio6-spark-products-sent.png`

**Contenido**:
- Salida del script mostrando:
  - Datos cargados (envíos y detalles)
  - Registros con descuento
  - JOIN completado
  - Tabla creada en Hive
  - Estadísticas de precios

**Comando para capturar**:
```bash
spark-submit /home/hadoop/scripts/spark_products_sent.py
```

**Archivo adicional**: `ejercicio6-verify-products-sent.png`

**Contenido**:
- Consulta en Hive/Beeline:
```sql
USE northwind_analytics;
SELECT COUNT(*) FROM products_sent;
SELECT * FROM products_sent ORDER BY total_price DESC LIMIT 10;
```

---

### Ejercicio 7: Airflow DAG

**Archivo principal**: `ejercicio7-airflow-dag-graph.png`

**Contenido**:
- Vista Graph del DAG en la UI de Airflow
- Debe mostrar:
  - Nodo inicio
  - TaskGroup ingest (con 3 tareas)
  - TaskGroup process (con 2 tareas)
  - TaskGroup verify (con 2 tareas)
  - Nodo fin
- Todas las tareas en estado SUCCESS (verde)

**Cómo capturar**:
1. Acceder a http://localhost:8080
2. Click en el DAG `northwind_processing`
3. Click en pestaña "Graph"
4. Capturar la pantalla

---

**Archivo**: `ejercicio7-airflow-dag-grid.png`

**Contenido**:
- Vista Grid del DAG mostrando la ejecución completa
- Todas las tareas completadas exitosamente

**Cómo capturar**:
1. Acceder a http://localhost:8080
2. Click en el DAG `northwind_processing`
3. Click en pestaña "Grid"
4. Capturar la pantalla

---

**Archivo**: `ejercicio7-airflow-task-groups.png`

**Contenido**:
- Vista expandida de los TaskGroups mostrando:
  - ingest (verde, completado)
  - process (verde, completado)
  - verify (verde, completado)

---

**Archivo**: `ejercicio7-hive-resultados.png`

**Contenido**:
- Consultas finales en Hive mostrando los datos cargados:

```sql
USE northwind_analytics;

-- Mostrar tablas
SHOW TABLES;

-- Contar registros
SELECT 'products_sold' as tabla, COUNT(*) as total FROM products_sold
UNION ALL
SELECT 'products_sent' as tabla, COUNT(*) as total FROM products_sent;

-- Top clientes
SELECT * FROM products_sold ORDER BY productos_vendidos DESC LIMIT 5;

-- Top ventas
SELECT * FROM products_sent ORDER BY total_price DESC LIMIT 5;
```

---

## 📊 Resumen de Capturas

| # | Ejercicio | Archivo(s) | Estado |
|---|-----------|------------|--------|
| 1 | Base de Datos Hive | `ejercicio1-create-database.png` | ⬜ Pendiente |
| 2 | Sqoop Clientes | `ejercicio2-sqoop-clientes.png` | ⬜ Pendiente |
| 3 | Sqoop Envíos | `ejercicio3-sqoop-envios.png` | ⬜ Pendiente |
| 4 | Sqoop Order Details | `ejercicio4-sqoop-order-details.png` | ⬜ Pendiente |
| 5 | Spark Products Sold | `ejercicio5-spark-products-sold.png`<br>`ejercicio5-verify-products-sold.png` | ⬜ Pendiente |
| 6 | Spark Products Sent | `ejercicio6-spark-products-sent.png`<br>`ejercicio6-verify-products-sent.png` | ⬜ Pendiente |
| 7 | Airflow DAG | `ejercicio7-airflow-dag-graph.png`<br>`ejercicio7-airflow-dag-grid.png`<br>`ejercicio7-airflow-task-groups.png`<br>`ejercicio7-hive-resultados.png` | ⬜ Pendiente |

## 📝 Instrucciones para Captura

### Linux/Mac
```bash
# Usar herramientas como:
- gnome-screenshot
- scrot
- flameshot
```

### Windows
```
# Usar:
- Windows + Shift + S (Snipping Tool)
- Print Screen
- Snip & Sketch
```

### Desde terminal (text output)
```bash
# Redirigir output a archivo
script -c "comando" output.txt

# O usando tee
comando | tee output.txt
```

## 🖼️ Formato Recomendado

- **Formato**: PNG (mejor calidad para texto)
- **Resolución**: Mínimo 1920x1080
- **Tamaño**: Comprimir si supera 2 MB
- **Contenido**: Asegurarse que el texto sea legible

## ✅ Checklist de Calidad

Para cada captura, verificar:

- [ ] El comando ejecutado es visible
- [ ] La salida completa es legible
- [ ] Los mensajes de éxito (✅) son visibles
- [ ] Las estadísticas/conteos son claros
- [ ] La fecha/hora de ejecución es visible
- [ ] No hay información sensible (passwords, IPs internas)

---

**Última actualización**: 2025-11-12

