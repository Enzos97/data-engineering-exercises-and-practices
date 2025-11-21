# Airflow DAG - Titanic Processing

Este directorio contiene el DAG de Apache Airflow que procesa los datos del Titanic desde HDFS y los carga en Hive.

## 📄 Archivo Principal

### `titanic_dag.py`

DAG que implementa el pipeline ETL completo para procesar datos del Titanic.

## 🎯 Funcionalidad

### Flujo del DAG

```
┌────────────────────────────────────────┐
│   transform_and_load_hive              │
│                                        │
│   1. Descarga desde HDFS               │
│   2. Transformaciones con Pandas       │
│   3. Carga en Hive                     │
└────────────────────────────────────────┘
```

### Transformaciones Aplicadas

1. **Remover columnas**:
   - `SibSp` (# de hermanos/cónyuges)
   - `Parch` (# de padres/hijos)

2. **Rellenar edad**:
   - Calcular promedio de edad por género
   - Rellenar valores nulos con el promedio correspondiente
   - Hombres: ~30.73 años
   - Mujeres: ~27.92 años

3. **Limpiar Cabin**:
   - Valores nulos → 0

4. **Limpiar Name**:
   - Eliminar comas para evitar conflictos con CSV

5. **Corregir tipos**:
   - `Age`: Convertir a numérico
   - `Fare`: Convertir a numérico

## 🚀 Configuración

### Argumentos del DAG

```python
default_args = {
    'owner': 'Edvai',
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
}
```

### Schedule

- **schedule_interval**: `@daily` (ejecución diaria)
- **catchup**: `False` (no ejecutar fechas pasadas)

### Tags

- pandas
- hive
- etl
- titanic

## 📦 Dependencias

### Python Packages

```bash
pip install pandas
```

### Sistema

- HDFS configurado y accesible
- Hive instalado con metastore
- Tabla `titanic_db.titanic_processed` creada

## 🔧 Instalación

### 1. Copiar el DAG

```bash
# Opción A: Copiar desde host
docker cp titanic_dag.py edvai_hadoop:/home/hadoop/airflow/dags/

# Opción B: Crear dentro del contenedor
docker exec -it edvai_hadoop bash
cd /home/hadoop/airflow/dags
nano titanic_dag.py
# Copiar contenido
```

### 2. Verificar sintaxis

```bash
python3 /home/hadoop/airflow/dags/titanic_dag.py
```

Si no hay errores, no debe mostrar salida.

### 3. Verificar que Airflow detecta el DAG

```bash
airflow dags list | grep titanic
```

**Salida esperada**:
```
titanic_processing_dag
```

## ▶️ Ejecución

### Desde la UI de Airflow

1. Acceder a http://localhost:8080
2. Buscar `titanic_processing_dag`
3. Activar el toggle (switch)
4. Click en "Trigger DAG" (▶)
5. Monitorear en la vista Graph o Grid

### Desde Línea de Comandos

```bash
# Trigger manual
airflow dags trigger titanic_processing_dag

# Ver estado
airflow dags list-runs -d titanic_processing_dag

# Ver logs
airflow tasks logs titanic_processing_dag transform_and_load_hive $(date +%Y-%m-%d)
```

## 📊 Monitoreo

### Ver Logs en Tiempo Real

```bash
tail -f /home/hadoop/airflow/logs/titanic_processing_dag/transform_and_load_hive/*/task.log
```

### Verificar Ejecución Exitosa

**Logs esperados**:
```
--- Iniciando descarga desde HDFS ---
✅ Archivo descargado de HDFS a /tmp/titanic_raw.csv
--- Cargando datos con Pandas ---
📊 Total de registros cargados: 891
--- Aplicando transformaciones ---
  • Removiendo columnas SibSp y Parch
  • Calculando promedios de edad por género
    - Promedio edad hombres: 30.73
    - Promedio edad mujeres: 27.92
  • Reemplazando valores nulos de Cabin con 0
  • Limpiando comas en el campo Name
✅ Transformaciones completadas. Registros finales: 891
--- Guardando archivo procesado ---
✅ Archivo guardado en /tmp/titanic_final.csv
--- Subiendo archivo procesado a HDFS ---
✅ Archivo subido a HDFS: /tmp/titanic_final.csv
--- Cargando datos en Hive ---
✅ Datos cargados en tabla titanic_db.titanic_processed

=== PROCESO COMPLETADO EXITOSAMENTE ===
```

### Verificar Datos en Hive

```bash
hive -e "SELECT COUNT(*) FROM titanic_db.titanic_processed;"
```

**Resultado esperado**: `891`

## 🐛 Troubleshooting

### Error: "ModuleNotFoundError: No module named 'pandas'"

**Solución**:
```bash
pip install pandas
```

### Error: "FileNotFoundError: /nifi/titanic.csv"

**Causa**: El archivo no está en HDFS.

**Solución**:
```bash
# Verificar
hdfs dfs -ls /nifi

# Si no está, ejecutar el flujo NiFi primero
```

### Error: "Table titanic_db.titanic_processed not found"

**Causa**: La tabla no fue creada en Hive.

**Solución**:
```bash
hive -f /home/hadoop/hive/titanic-setup.sql
```

### Error: "HDFS command not found"

**Causa**: Variables de entorno no configuradas.

**Solución**:
```bash
export HADOOP_HOME=/home/hadoop/hadoop
export PATH=$HADOOP_HOME/bin:$PATH
```

### DAG no aparece en la UI

**Solución**:
```bash
# Verificar errores de sintaxis
python3 /home/hadoop/airflow/dags/titanic_dag.py

# Reiniciar scheduler
pkill -f "airflow scheduler"
airflow scheduler &
```

## 📝 Personalización

### Cambiar Schedule

```python
schedule_interval='@weekly',  # Semanalmente
# o
schedule_interval='0 2 * * *',  # Diariamente a las 2 AM
# o
schedule_interval=None,  # Solo manual
```

### Agregar Notificaciones

```python
default_args = {
    ...
    'email': ['data-team@example.com'],
    'email_on_failure': True,
    'email_on_retry': True,
}
```

### Agregar Validaciones

```python
def validar_datos():
    # Validar que haya registros
    count = len(df)
    if count < 100:
        raise ValueError(f"Muy pocos registros: {count}")
    
    # Validar columnas requeridas
    required_cols = ['PassengerId', 'Survived', 'Age']
    missing = [c for c in required_cols if c not in df.columns]
    if missing:
        raise ValueError(f"Columnas faltantes: {missing}")

# Llamar antes de guardar
validar_datos()
```

## 📚 Referencias

- [Airflow PythonOperator](https://airflow.apache.org/docs/apache-airflow/stable/howto/operator/python.html)
- [Pandas Documentation](https://pandas.pydata.org/docs/)
- [Hive LOAD DATA](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML#LanguageManualDML-Loadingfilesintotables)

---

**Última actualización**: 2025-11-20

