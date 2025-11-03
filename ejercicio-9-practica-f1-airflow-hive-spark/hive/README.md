# Configuración de Hive - Ejercicio 9: Formula 1

Esta guía explica cómo configurar las tablas externas en Hive para trabajar con datos de Formula 1.

## 📋 Objetivo

Crear tablas externas en Hive que permitan consultar datos de resultados de corredores y constructores de Formula 1.

## 🗄️ Base de Datos: `f1`

### Tablas Creadas

#### 1. `driver_results`
Almacena información de resultados de corredores con los siguientes campos:

- **driver_forename** (STRING): Nombre del corredor
- **driver_surname** (STRING): Apellido del corredor
- **driver_nationality** (STRING): Nacionalidad del corredor
- **points** (DOUBLE): Puntos obtenidos

**Ubicación HDFS**: `/user/hive/warehouse/f1.db/driver_results`

#### 2. `constructor_results`
Almacena información de resultados de constructores con los siguientes campos:

- **constructorRef** (STRING): Referencia del constructor
- **cons_name** (STRING): Nombre del constructor
- **cons_nationality** (STRING): Nacionalidad del constructor
- **url** (STRING): URL con información del constructor
- **points** (DOUBLE): Puntos obtenidos

**Ubicación HDFS**: `/user/hive/warehouse/f1.db/constructor_results`

## 🚀 Pasos para Ejecutar

### 1. Preparar los datos en HDFS

Antes de ejecutar el script SQL, asegúrate de que los archivos CSV estén en las ubicaciones correctas de HDFS:

```bash
# Crear directorios en HDFS
hdfs dfs -mkdir -p /user/hive/warehouse/f1.db/driver_results
hdfs dfs -mkdir -p /user/hive/warehouse/f1.db/constructor_results

# Subir los archivos CSV procesados (después de ejecutar el script de ingesta)
# Los archivos deben estar previamente procesados y tener las columnas correctas
```

### 2. Ejecutar el script SQL

```bash
# Iniciar Hive
hive

# O ejecutar el script directamente
hive -f hive/f1-setup.sql
```

### 3. Verificar las tablas

Una vez ejecutado el script, puedes verificar las tablas con:

```sql
USE f1;

-- Ver todas las tablas
SHOW TABLES;

-- Ver esquema de driver_results
DESCRIBE driver_results;

-- Ver esquema de constructor_results
DESCRIBE constructor_results;

-- Consultar datos (después de cargar los datos)
SELECT * FROM driver_results LIMIT 10;
SELECT * FROM constructor_results LIMIT 10;
```

## 📝 Notas Importantes

1. **Tablas Externas**: Las tablas creadas son externas, lo que significa que los datos se almacenan en HDFS y no se eliminan cuando se elimina la tabla.

2. **Formato de Archivos**: Los archivos deben estar en formato CSV con delimitador de coma (`,`).

3. **Headers**: El script incluye la propiedad `skip.header.line.count='1'` para omitir la primera línea (encabezados).

4. **Procesamiento de Datos**: Los datos en las tablas deben ser previamente procesados desde los archivos CSV originales (results.csv, drivers.csv, constructors.csv, races.csv) mediante scripts de procesamiento que unan las tablas necesarias.

5. **Ubicaciones HDFS**: Asegúrate de que las rutas en HDFS existan antes de crear las tablas externas.

## 🔍 Verificación de Esquemas (Punto 2 del Ejercicio)

Para mostrar el esquema de las tablas, ejecuta:

```sql
-- Esquema de driver_results
DESCRIBE driver_results;

-- Esquema de constructor_results
DESCRIBE constructor_results;

-- Información detallada con ubicación
DESCRIBE FORMATTED driver_results;
DESCRIBE FORMATTED constructor_results;
```

## 📊 Estructura de Datos Esperada

Los archivos CSV en HDFS deben tener la siguiente estructura:

**driver_results.csv**:
```
driver_forename,driver_surname,driver_nationality,points
Lewis,Hamilton,British,4085.5
Michael,Schumacher,German,3890.0
...
```

**constructor_results.csv**:
```
constructorRef,cons_name,cons_nationality,url,points
mercedes,Mercedes,German,http://en.wikipedia.org/wiki/Mercedes-Benz_in_Formula_One,8045.5
ferrari,Ferrari,Italian,http://en.wikipedia.org/wiki/Scuderia_Ferrari,7890.0
...
```

