# Airflow DAGs - Car Rental Analytics

Este directorio contiene los DAGs de Airflow para orquestar el pipeline.

## 📄 DAGs

### `car_rental_parent_dag.py` (DAG Padre - Punto 4a)
DAG principal que ingiere los archivos y dispara el DAG hijo.

**ID**: `car_rental_parent_dag`

**Tareas:**
1. `inicio` - DummyOperator
2. `crear_tabla_hive` - Ejecuta car_rental_setup.sql
3. `download_and_ingest` - Ejecuta download_data.sh
4. `verificar_archivos_hdfs` - Lista archivos en HDFS
5. `trigger_procesamiento` - Dispara el DAG hijo
6. `verificar_carga_hive` - Verifica total de registros
7. `fin` - DummyOperator

**Schedule**: `@daily`

---

### `car_rental_child_dag.py` (DAG Hijo - Punto 4b)
DAG secundario que procesa los datos y los carga en Hive.

**ID**: `car_rental_child_dag`

**Tareas:**
1. `inicio_procesamiento` - DummyOperator
2. `spark_process_data` - Ejecuta process_car_rental.py
3. `verificar_datos_procesados` - Verifica conteo y distribución
4. `verificar_exclusion_texas` - Valida que Texas fue excluido
5. `verificar_rating_nulos` - Valida que no hay rating nulos
6. `generar_estadisticas` - Estadísticas generales
7. `fin_procesamiento` - DummyOperator

**Schedule**: `None` (solo se ejecuta cuando lo dispara el padre)

---

## 🚀 Ejecución

### Opción A: Desde UI de Airflow

1. Acceder a `http://localhost:8080`
2. Buscar `car_rental_parent_dag`
3. Activar toggle (ON)
4. Click en botón ▶ "Trigger DAG"
5. Monitorear en vista "Graph" o "Grid"

---

### Opción B: Desde CLI

```bash
# Listar DAGs
airflow dags list | grep car_rental

# Ejecutar DAG padre (esto ejecutará también el hijo)
airflow dags trigger car_rental_parent_dag

# Ver estado
airflow dags list-runs -d car_rental_parent_dag

# Ver logs del DAG padre
airflow tasks logs car_rental_parent_dag download_and_ingest $(date +%Y-%m-%d)

# Ver logs del DAG hijo
airflow tasks logs car_rental_child_dag spark_process_data $(date +%Y-%m-%d)
```

---

## 📊 Flujo del Pipeline

```
┌─────────────────┐
│   DAG PADRE     │
│                 │
│  Crear Tabla    │
│       ↓         │
│  Descargar Data │
│       ↓         │
│  Verificar HDFS │
│       ↓         │
│ ┌─────────────┐ │
│ │  DAG HIJO   │ │
│ │             │ │
│ │  Spark ETL  │ │
│ │      ↓      │ │
│ │  Validar    │ │
│ │      ↓      │ │
│ │ Estadísticas│ │
│ └─────────────┘ │
│       ↓         │
│  Verificar Hive │
└─────────────────┘
```

---

## 🔧 Configuración

### Instalación de DAGs

```bash
# Copiar DAGs al directorio de Airflow
docker cp car_rental_parent_dag.py edvai_hadoop:/home/hadoop/airflow/dags/
docker cp car_rental_child_dag.py edvai_hadoop:/home/hadoop/airflow/dags/

# Verificar que Airflow los detectó
airflow dags list | grep car_rental
```

---

### Dependencias

Asegurarse de que existen:
- `/home/hadoop/scripts/download_data.sh`
- `/home/hadoop/scripts/process_car_rental.py`
- `/home/hadoop/hive/car_rental_setup.sql`

---

## ✅ Verificación

```bash
# Verificar sintaxis de DAGs
python3 /home/hadoop/airflow/dags/car_rental_parent_dag.py
python3 /home/hadoop/airflow/dags/car_rental_child_dag.py

# Si no hay errores, no muestra salida
```

---

## 🐛 Troubleshooting

### DAG no aparece en la UI

```bash
# Reiniciar scheduler
pkill -f "airflow scheduler"
airflow scheduler &

# Esperar 30 segundos y verificar
airflow dags list | grep car_rental
```

---

### Error al ejecutar DAG

```bash
# Ver logs completos
tail -f /home/hadoop/airflow/logs/car_rental_parent_dag/download_and_ingest/*/task.log
```

---

## 📧 Notificaciones

Para habilitar notificaciones por email en caso de fallo:

```python
default_args = {
    'email': ['tu-email@example.com'],
    'email_on_failure': True,
    'email_on_retry': True,
}
```

---

## 📝 Notas

- El DAG padre espera a que el hijo termine (`wait_for_completion=True`)
- El hijo solo se ejecuta cuando el padre lo dispara
- Ambos DAGs tienen retry configurado (1 intento con 5 min de delay)
- Los logs se guardan en `/home/hadoop/airflow/logs/`

