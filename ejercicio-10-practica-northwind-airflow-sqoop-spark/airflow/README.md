# Airflow DAG - Northwind Processing

Este directorio contiene el DAG de Apache Airflow que orquesta el pipeline completo de ETL para Northwind Analytics.

## 📄 Archivo Principal

### `northwind_processing.py`

DAG que implementa el pipeline completo de procesamiento de datos Northwind, organizando las tareas en tres grupos principales usando TaskGroups.

## 🎯 Estructura del DAG

### **Configuración General**

```python
DAG ID: northwind_processing
Schedule: None (ejecución manual)
Owner: hadoop
Retries: 1
Retry Delay: 5 minutos
Tags: ['sqoop', 'spark', 'hive', 'etl', 'northwind']
```

### **TaskGroup 1: Ingest**

Ingesta de datos desde PostgreSQL a HDFS usando Sqoop.

| Task ID | Script | Descripción |
|---------|--------|-------------|
| `sqoop_import_clientes` | `sqoop_import_clientes.sh` | Importa clientes con productos vendidos |
| `sqoop_import_envios` | `sqoop_import_envios.sh` | Importa órdenes con información de envío |
| `sqoop_import_order_details` | `sqoop_import_order_details.sh` | Importa detalles de órdenes |

**Ejecución**: Las 3 tareas se ejecutan en **paralelo**.

### **TaskGroup 2: Process**

Procesamiento de datos con Spark e inserción en Hive.

| Task ID | Script | Descripción |
|---------|--------|-------------|
| `spark_products_sold` | `spark_products_sold.py` | Procesa clientes con ventas > promedio |
| `spark_products_sent` | `spark_products_sent.py` | Procesa pedidos con descuento |

**Ejecución**: Las 2 tareas se ejecutan en **paralelo**.

### **TaskGroup 3: Verify**

Verificación de datos cargados en Hive.

| Task ID | Comando | Descripción |
|---------|---------|-------------|
| `verify_products_sold` | Beeline SQL | Verifica tabla products_sold |
| `verify_products_sent` | Beeline SQL | Verifica tabla products_sent |

**Ejecución**: Las 2 tareas se ejecutan en **paralelo**.

## 🔄 Flujo de Ejecución

```
inicio → ingest_group → process_group → verify_group → fin
```

### Dependencias Detalladas

```
┌─────────────┐
│   inicio    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────┐
│          TaskGroup: ingest                   │
│  ┌───────────────────────────────────────┐  │
│  │ ▪ sqoop_import_clientes               │  │
│  │ ▪ sqoop_import_envios                 │  │
│  │ ▪ sqoop_import_order_details          │  │
│  └───────────────────────────────────────┘  │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│          TaskGroup: process                  │
│  ┌───────────────────────────────────────┐  │
│  │ ▪ spark_products_sold                 │  │
│  │ ▪ spark_products_sent                 │  │
│  └───────────────────────────────────────┘  │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│          TaskGroup: verify                   │
│  ┌───────────────────────────────────────┐  │
│  │ ▪ verify_products_sold                │  │
│  │ ▪ verify_products_sent                │  │
│  └───────────────────────────────────────┘  │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
              ┌─────────┐
              │   fin   │
              └─────────┘
```

## 🚀 Instalación y Configuración

### 1. Copiar el DAG a Airflow

```bash
# Opción 1: Copiar desde host a contenedor
docker cp airflow/northwind_processing.py edvai_hadoop:/home/hadoop/airflow/dags/

# Opción 2: Dentro del contenedor
cp /path/to/northwind_processing.py /home/hadoop/airflow/dags/
```

### 2. Verificar que Airflow detecta el DAG

```bash
# Listar todos los DAGs
airflow dags list

# Verificar DAG específico
airflow dags show northwind_processing
```

### 3. Verificar scripts requeridos

Asegurarse de que los siguientes scripts existen en `/home/hadoop/scripts/`:

```bash
ls -l /home/hadoop/scripts/sqoop_import_*.sh
ls -l /home/hadoop/scripts/spark_products_*.py
```

## 🎮 Uso del DAG

### Ejecución Manual

#### Desde la UI de Airflow:

1. Acceder a http://localhost:8080
2. Buscar el DAG `northwind_processing`
3. Activar el toggle (switch) para habilitarlo
4. Click en el botón "Trigger DAG" (▶)
5. Monitorear la ejecución en la vista Graph o Grid

#### Desde la línea de comandos:

```bash
# Trigger del DAG
airflow dags trigger northwind_processing

# Ver estado de la ejecución
airflow dags state northwind_processing $(date +%Y-%m-%d)

# Ver logs de una tarea específica
airflow tasks logs northwind_processing sqoop_import_clientes $(date +%Y-%m-%d)
```

### Pausar/Despausar DAG

```bash
# Pausar
airflow dags pause northwind_processing

# Despausar
airflow dags unpause northwind_processing
```

### Backfill (Ejecutar para fechas pasadas)

```bash
airflow dags backfill northwind_processing \
    --start-date 2025-11-01 \
    --end-date 2025-11-12
```

## 📊 Monitoreo y Logs

### Ver logs de una tarea

```bash
# Formato: airflow tasks logs <dag_id> <task_id> <execution_date>
airflow tasks logs northwind_processing ingest.sqoop_import_clientes 2025-11-12

airflow tasks logs northwind_processing process.spark_products_sold 2025-11-12
```

### Ver estado de todas las tareas

```bash
airflow dags list-runs -d northwind_processing --output table
```

### Verificar dependencias

```bash
airflow dags show northwind_processing
```

## 🔧 Troubleshooting

### Problema: DAG no aparece en la UI

**Solución**:
```bash
# Verificar errores en el archivo Python
python3 /home/hadoop/airflow/dags/northwind_processing.py

# Reiniciar scheduler
airflow scheduler
```

### Problema: Tareas fallan con "bash: command not found"

**Solución**:
```bash
# Verificar que los scripts tienen permisos de ejecución
chmod +x /home/hadoop/scripts/*.sh
chmod +x /home/hadoop/scripts/*.py

# Verificar rutas completas en el DAG
```

### Problema: Error de conexión a Hive

**Solución**:
```bash
# Verificar que HiveServer2 está corriendo
netstat -tuln | grep 10000

# Iniciar HiveServer2 si está detenido
hiveserver2 &
```

## 📝 Personalización

### Modificar schedule_interval

Para ejecutar el DAG automáticamente:

```python
schedule_interval='0 2 * * *',  # Diariamente a las 2 AM
# o
schedule_interval='@daily',     # Diariamente a medianoche
# o
schedule_interval=timedelta(hours=6),  # Cada 6 horas
```

### Agregar notificaciones por email

```python
default_args = {
    ...
    'email': ['data-team@example.com'],
    'email_on_failure': True,
    'email_on_retry': True,
}
```

### Agregar más tareas

```python
with TaskGroup(group_id='ingest') as ingest_group:
    # Tareas existentes...
    
    # Nueva tarea
    nueva_tarea = BashOperator(
        task_id='nueva_tarea',
        bash_command='bash /home/hadoop/scripts/nueva_tarea.sh',
    )
```

## 📚 Referencias

- [Airflow Documentation](https://airflow.apache.org/docs/)
- [TaskGroups Guide](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html#taskgroups)
- [BashOperator](https://airflow.apache.org/docs/apache-airflow/stable/howto/operator/bash.html)

---

**Última actualización**: 2025-11-12

