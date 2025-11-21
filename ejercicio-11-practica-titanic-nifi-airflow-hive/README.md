# Ejercicio 11 - Práctica Titanic: NiFi + Airflow + Hive

Este ejercicio integra **Apache NiFi** para flujo de ingesta de datos, **Apache Airflow** para procesamiento y transformación con Pandas, y **Apache Hive** para almacenamiento y análisis SQL de datos del Titanic.

## 🎯 Objetivos

- Crear script bash para descarga automatizada de datos
- Implementar flujo de ingesta completo con Apache NiFi
- Procesar y transformar datos con Pandas en Airflow
- Almacenar datos estructurados en Hive
- Realizar análisis de negocio con SQL

## 📋 Ejercicios Incluidos

### 1️⃣ **Script Bash - Descarga de Titanic.csv**
- Crear script de descarga desde S3
- Ejecutar en contenedor NiFi
- Verificar archivo descargado

### 2️⃣ **Preparación de Directorios**
- Crear directorios necesarios en NiFi
- Configurar archivos de Hadoop (core-site.xml, hdfs-site.xml)
- Preparar directorio en HDFS

### 3️⃣ **Flujo NiFi - GetFile (Origen)**
- Configurar procesador GetFile
- Leer desde `/home/nifi/ingest`
- Pasar archivo al siguiente procesador

### 4️⃣ **Flujo NiFi - PutFile (Bucket)**
- Mover archivo a `/home/nifi/bucket`
- Configurar resolución de conflictos

### 5️⃣ **Flujo NiFi - GetFile (Bucket)**
- Leer desde bucket intermedio
- Preparar para ingesta a HDFS

### 6️⃣ **Flujo NiFi - PutHDFS**
- Configurar conexión a HDFS
- Ingestar archivo a `/nifi`
- Verificar en HDFS

### 7️⃣ **Pipeline Airflow con Transformaciones**
- Crear tabla en Hive
- Desarrollar DAG de Airflow
- Aplicar transformaciones con Pandas:
  - Remover columnas SibSp y Parch
  - Rellenar edad con promedios por género
  - Reemplazar Cabin nulo con 0
- Cargar datos procesados en Hive

### 8️⃣ **Análisis de Negocio con Hive**
- Sobrevivientes por género
- Sobrevivientes por clase
- Persona de mayor edad que sobrevivió
- Persona más joven que sobrevivió

## 📁 Estructura del Proyecto

```
ejercicio-11-practica-titanic-nifi-airflow-hive/
├── README.md                    # Documentación principal
├── scripts/
│   ├── ingest.sh               # Script de descarga de titanic.csv
│   └── README.md               # Documentación de scripts
├── nifi/
│   ├── core-site.xml           # Configuración HDFS para NiFi
│   ├── hdfs-site.xml           # Configuración HDFS para NiFi
│   └── README.md               # Guía de configuración NiFi
├── airflow/
│   ├── titanic_dag.py          # DAG de procesamiento
│   └── README.md               # Documentación de Airflow
├── hive/
│   ├── titanic-setup.sql       # Scripts SQL de Hive
│   └── README.md               # Documentación de Hive
├── images/                     # Capturas de pantalla
│   └── README.md               # Índice de imágenes
└── ejercicios-resueltos.md     # Soluciones completas paso a paso
```

## 🚀 Tecnologías Utilizadas

- **Apache NiFi** - Orquestación de flujos de datos
- **Apache Airflow** - Procesamiento y transformación
- **Python Pandas** - Manipulación de datos
- **Apache Hive** - Data warehouse y consultas SQL
- **HDFS** - Sistema de archivos distribuido
- **Bash Scripting** - Automatización de descargas
- **CSV** - Formato de datos

## 📊 Dataset Utilizado

- **Fuente**: Titanic Dataset
- **URL**: https://data-engineer-edvai-public.s3.amazonaws.com/titanic.csv
- **Registros**: 891 pasajeros
- **Descripción**: Datos de pasajeros del Titanic incluyendo supervivencia, clase, edad, género, etc.
- **Diccionario**: https://choens.github.io/titanic/workshops/regression/data-dictionary/

### Campos del Dataset

| Campo | Tipo | Descripción |
|-------|------|-------------|
| PassengerId | INT | ID único del pasajero |
| Survived | INT | 0 = No, 1 = Sí |
| Pclass | INT | Clase del ticket (1 = 1ra, 2 = 2da, 3 = 3ra) |
| Name | STRING | Nombre del pasajero |
| Sex | STRING | Género (male/female) |
| Age | FLOAT | Edad en años |
| SibSp | INT | # de hermanos/cónyuges a bordo |
| Parch | INT | # de padres/hijos a bordo |
| Ticket | STRING | Número de ticket |
| Fare | FLOAT | Tarifa del pasajero |
| Cabin | STRING | Número de cabina |
| Embarked | STRING | Puerto de embarque (C/Q/S) |

## 🔧 Requisitos Previos

- Contenedor NiFi ejecutándose
- Contenedor Hadoop ejecutándose
- Apache Hive configurado y funcionando
- Apache Airflow instalado y configurado
- Python con Pandas instalado
- Acceso a internet para descarga de datos

## 🚀 Pipeline Completo

```
┌─────────────────────────────────────────────────────────────┐
│         1. DESCARGA (Script Bash en NiFi)                    │
│              titanic.csv → /home/nifi/ingest                 │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         2-6. FLUJO NIFI (Movimiento de Archivos)            │
│  GetFile → PutFile → GetFile → PutHDFS → HDFS:/nifi        │
│  (ingest)  (bucket)  (bucket)                               │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         7. PROCESAMIENTO (Airflow + Pandas)                  │
│  • Descarga desde HDFS                                       │
│  • Remover columnas (SibSp, Parch)                          │
│  • Rellenar edad con promedios por género                   │
│  • Cabin nulo → 0                                           │
│  • Carga en Hive                                            │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│         8. ANÁLISIS (Hive SQL)                               │
│  • Sobrevivientes por género                                 │
│  • Sobrevivientes por clase                                  │
│  • Mayor y menor edad sobrevivientes                         │
└─────────────────────────────────────────────────────────────┘
```

## 📖 Guías de Uso

### Ejecución Rápida

1. **Descargar datos**:
```bash
docker exec -it nifi bash
/home/nifi/ingest/ingest.sh
```

2. **Configurar flujo NiFi**:
   - Acceder a https://localhost:8443/nifi
   - Crear procesadores según documentación
   - Ejecutar flujo

3. **Crear tabla Hive**:
```bash
docker exec -it edvai_hadoop bash
hive -f /home/hadoop/hive/titanic-setup.sql
```

4. **Ejecutar DAG Airflow**:
```bash
airflow dags trigger titanic_processing_dag
```

5. **Ejecutar consultas**:
```bash
hive -f /home/hadoop/hive/titanic-setup.sql
```

## 🎯 Resultados Esperados

### Datos Procesados
- **Total registros**: 891 pasajeros
- **Columnas originales**: 12
- **Columnas finales**: 10 (removidas SibSp y Parch)
- **Valores nulos tratados**: Edad y Cabin

### Análisis de Negocio

**Sobrevivientes por Género**:
- Mujeres: 233 (74.20% de supervivencia)
- Hombres: 109 (18.89% de supervivencia)

**Sobrevivientes por Clase**:
- 1ra clase: 136
- 2da clase: 87
- 3ra clase: 119

**Edades Extremas**:
- Mayor: Barkworth Mr. Algernon Henry Wilson (80 años)
- Menor: Thomas Master. Assad Alexander (0.42 años)

## 📝 Notas Importantes

### Configuración de NiFi

Los archivos `core-site.xml` y `hdfs-site.xml` deben estar en `/home/nifi/hadoop/`:

```xml
<!-- core-site.xml -->
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://172.17.0.2:9000</value>
</property>

<!-- hdfs-site.xml -->
<property>
    <name>dfs.replication</name>
    <value>1</value>
</property>
```

### Permisos HDFS

Asegurarse de dar permisos al directorio:
```bash
hdfs dfs -chmod 777 /nifi
```

### Transformaciones

- **Edad**: Se calcula promedio por género y se rellena
- **Cabin**: Valores nulos se convierten a 0
- **Name**: Se eliminan comas para evitar conflictos con CSV

## 🔗 Referencias

- [Apache NiFi Documentation](https://nifi.apache.org/docs.html)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Pandas Documentation](https://pandas.pydata.org/docs/)
- [Titanic Dataset Dictionary](https://choens.github.io/titanic/workshops/regression/data-dictionary/)

## 📧 Contacto

Para consultas o problemas, contactar al equipo de Data Engineering.

---

**Autor**: Edvai Team  
**Fecha**: 2025-11-20  
**Versión**: 1.0

