# Hive - Titanic Database

Este directorio contiene scripts SQL para crear y consultar la base de datos de Titanic en Hive.

## 📄 Archivos

### `titanic-setup.sql`

Script SQL completo para:
1. Crear base de datos `titanic_db`
2. Crear tabla externa `titanic_raw` (datos originales desde HDFS)
3. Crear tabla `titanic_processed` (datos transformados)
4. Consultas analíticas de negocio

## 🎯 Estructura de Datos

### Base de Datos

```sql
CREATE DATABASE IF NOT EXISTS titanic_db;
```

### Tabla: `titanic_raw`

**Propósito**: Almacenar datos crudos ingestados desde NiFi/HDFS.

**Ubicación HDFS**: `/nifi/`

**Esquema**:

| Columna | Tipo | Descripción |
|---------|------|-------------|
| PassengerId | INT | ID único del pasajero |
| Survived | INT | 0 = No sobrevivió, 1 = Sobrevivió |
| Pclass | INT | Clase del ticket (1, 2, 3) |
| Name | STRING | Nombre completo |
| Sex | STRING | Género (male/female) |
| Age | FLOAT | Edad en años |
| SibSp | INT | # hermanos/cónyuges |
| Parch | INT | # padres/hijos |
| Ticket | STRING | Número de ticket |
| Fare | FLOAT | Tarifa pagada |
| Cabin | STRING | Número de cabina |
| Embarked | STRING | Puerto (C/Q/S) |

**Características**:
- Tabla EXTERNA (no elimina datos al hacer DROP)
- ROW FORMAT DELIMITED
- FIELDS TERMINATED BY ','
- Salta línea de encabezado (skip.header.line.count=1)

### Tabla: `titanic_processed`

**Propósito**: Almacenar datos transformados por Airflow.

**Esquema**:

| Columna | Tipo | Descripción |
|---------|------|-------------|
| PassengerId | INT | ID único del pasajero |
| Survived | INT | 0 = No sobrevivió, 1 = Sobrevivió |
| Pclass | INT | Clase del ticket (1, 2, 3) |
| Name | STRING | Nombre (sin comas) |
| Sex | STRING | Género (male/female) |
| Age | FLOAT | Edad (rellenada con promedio) |
| Ticket | STRING | Número de ticket |
| Fare | FLOAT | Tarifa pagada |
| Cabin | STRING | Número de cabina (0 si null) |
| Embarked | STRING | Puerto (C/Q/S) |

**Diferencias con `titanic_raw`**:
- ❌ Removidas columnas: `SibSp`, `Parch`
- ✅ Edad: Rellenada con promedio por género
- ✅ Cabin: Valores nulos → 0
- ✅ Name: Sin comas

**Características**:
- Tabla MANAGED (se eliminan datos al hacer DROP)
- ROW FORMAT DELIMITED
- FIELDS TERMINATED BY ','

## 🚀 Instalación y Ejecución

### 1. Copiar script al contenedor

```bash
# Opción A: Copiar desde host
docker cp titanic-setup.sql edvai_hadoop:/home/hadoop/hive/

# Opción B: Crear dentro del contenedor
docker exec -it edvai_hadoop bash
cd /home/hadoop/hive
nano titanic-setup.sql
```

### 2. Ejecutar script completo

```bash
docker exec -it edvai_hadoop bash
hive -f /home/hadoop/hive/titanic-setup.sql
```

### 3. Verificar creación

```bash
# Listar bases de datos
hive -e "SHOW DATABASES;"

# Listar tablas
hive -e "USE titanic_db; SHOW TABLES;"

# Ver esquemas
hive -e "USE titanic_db; DESCRIBE FORMATTED titanic_raw;"
hive -e "USE titanic_db; DESCRIBE FORMATTED titanic_processed;"
```

## 📊 Consultas Analíticas

### 1. Sobrevivientes por Género

```sql
SELECT 
    Sex,
    SUM(Survived) as Sobrevivientes,
    COUNT(*) as Total,
    ROUND(SUM(Survived) * 100.0 / COUNT(*), 2) as Porcentaje_Supervivencia
FROM titanic_processed
GROUP BY Sex
ORDER BY Sobrevivientes DESC;
```

**Resultado esperado**:
```
Sex      Sobrevivientes  Total  Porcentaje_Supervivencia
female   233             314    74.20
male     109             577    18.89
```

### 2. Sobrevivientes por Clase

```sql
SELECT 
    Pclass,
    SUM(Survived) as Sobrevivientes,
    COUNT(*) as Total,
    ROUND(SUM(Survived) * 100.0 / COUNT(*), 2) as Porcentaje_Supervivencia
FROM titanic_processed
GROUP BY Pclass
ORDER BY Pclass;
```

**Resultado esperado**:
```
Pclass  Sobrevivientes  Total  Porcentaje_Supervivencia
1       136             216    62.96
2       87              184    47.28
3       119             491    24.24
```

### 3. Persona Mayor que Sobrevivió

```sql
SELECT 
    Name,
    Age,
    Sex,
    Pclass
FROM titanic_processed
WHERE Survived = 1 AND Age IS NOT NULL
ORDER BY Age DESC
LIMIT 1;
```

**Resultado esperado**:
```
Name                                      Age   Sex   Pclass
Barkworth Mr. Algernon Henry Wilson       80.0  male  1
```

### 4. Persona Más Joven que Sobrevivió

```sql
SELECT 
    Name,
    Age,
    Sex,
    Pclass
FROM titanic_processed
WHERE Survived = 1 AND Age IS NOT NULL
ORDER BY Age ASC
LIMIT 1;
```

**Resultado esperado**:
```
Name                             Age   Sex     Pclass
Thomas Master. Assad Alexander   0.42  male    2
```

### 5. Estadísticas Generales

```sql
SELECT 
    COUNT(*) as Total_Pasajeros,
    SUM(Survived) as Total_Sobrevivientes,
    ROUND(SUM(Survived) * 100.0 / COUNT(*), 2) as Tasa_Supervivencia,
    ROUND(AVG(Age), 2) as Edad_Promedio,
    ROUND(AVG(Fare), 2) as Tarifa_Promedio
FROM titanic_processed;
```

**Resultado esperado**:
```
Total_Pasajeros  Total_Sobrevivientes  Tasa_Supervivencia  Edad_Promedio  Tarifa_Promedio
891              342                   38.38               29.70          32.20
```

## ✅ Verificación

### Verificar tabla `titanic_raw`

```bash
hive -e "USE titanic_db; SELECT COUNT(*) FROM titanic_raw;"
```

**Resultado esperado**: `891`

### Verificar tabla `titanic_processed`

```bash
hive -e "USE titanic_db; SELECT COUNT(*) FROM titanic_processed;"
```

**Resultado esperado**: `891`

### Verificar columnas

```bash
# titanic_raw debe tener 12 columnas
hive -e "USE titanic_db; DESCRIBE titanic_raw;"

# titanic_processed debe tener 10 columnas (sin SibSp y Parch)
hive -e "USE titanic_db; DESCRIBE titanic_processed;"
```

### Verificar datos

```bash
hive -e "USE titanic_db; SELECT * FROM titanic_processed LIMIT 5;"
```

## 🐛 Troubleshooting

### Error: "Table already exists"

**Solución**:
```sql
DROP TABLE IF EXISTS titanic_db.titanic_raw;
DROP TABLE IF EXISTS titanic_db.titanic_processed;
```

O ejecutar el script que ya incluye `IF NOT EXISTS`.

### Error: "File does not exist: /nifi/titanic.csv"

**Causa**: El archivo no fue ingestado por NiFi.

**Solución**:
1. Verificar en HDFS:
```bash
hdfs dfs -ls /nifi
```

2. Re-ejecutar flujo NiFi si es necesario.

### Error: "Permission denied"

**Causa**: Permisos incorrectos en HDFS.

**Solución**:
```bash
hdfs dfs -chmod 777 /nifi
hdfs dfs -chmod 644 /nifi/titanic.csv
```

### Tabla `titanic_processed` vacía

**Causa**: El DAG de Airflow no se ejecutó o falló.

**Solución**:
```bash
# Verificar logs de Airflow
airflow dags list-runs -d titanic_processing_dag

# Re-ejecutar DAG
airflow dags trigger titanic_processing_dag
```

### Resultados incorrectos en consultas

**Causa**: Datos no transformados correctamente.

**Solución**:
```sql
-- Verificar valores nulos
SELECT COUNT(*) FROM titanic_processed WHERE Age IS NULL;
-- Debe ser 0

-- Verificar columnas removidas
DESCRIBE titanic_processed;
-- No debe incluir SibSp ni Parch
```

## 🔄 Mantenimiento

### Limpiar y recrear tablas

```bash
hive -e "
DROP TABLE IF EXISTS titanic_db.titanic_processed;
DROP TABLE IF EXISTS titanic_db.titanic_raw;
DROP DATABASE IF EXISTS titanic_db;
"

# Luego re-ejecutar setup
hive -f /home/hadoop/hive/titanic-setup.sql
```

### Actualizar datos

```bash
# Si los datos cambian en HDFS, solo necesitas:
hive -e "USE titanic_db; 
         DROP TABLE titanic_raw;
         CREATE EXTERNAL TABLE titanic_raw ...;"

# Luego re-ejecutar el DAG de Airflow
airflow dags trigger titanic_processing_dag
```

## 📝 Consultas Adicionales Útiles

### Top 10 tarifas más altas

```sql
SELECT Name, Fare, Pclass
FROM titanic_processed
ORDER BY Fare DESC
LIMIT 10;
```

### Distribución por puerto de embarque

```sql
SELECT 
    Embarked,
    COUNT(*) as Total,
    SUM(Survived) as Sobrevivientes
FROM titanic_processed
WHERE Embarked IS NOT NULL
GROUP BY Embarked
ORDER BY Total DESC;
```

### Supervivencia por género y clase

```sql
SELECT 
    Sex,
    Pclass,
    SUM(Survived) as Sobrevivientes,
    COUNT(*) as Total
FROM titanic_processed
GROUP BY Sex, Pclass
ORDER BY Sex, Pclass;
```

## 📚 Referencias

- [Hive DDL Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL)
- [Hive DML Manual](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML)
- [Hive External Tables](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL#LanguageManualDDL-ExternalTables)

---

**Última actualización**: 2025-11-20

