# 📊 Data Engineering Exercises and Practices

Este repositorio contiene ejercicios prácticos de **ingeniería de datos** enfocados en la ingesta de datos usando **Hadoop**, **HDFS** y **Sqoop**. Incluye scripts automatizados para diferentes escenarios de ingesta.

---

## 🎯 Objetivos

- Practicar la ingesta de datos desde fuentes externas hacia HDFS
- Automatizar procesos de ETL usando scripts bash
- Conectar bases de datos relacionales (PostgreSQL) con Hadoop usando Sqoop
- Gestionar archivos temporales y limpieza de datos

---

## 📁 Estructura del Repositorio

```
data-engineering-exercises-and-practices/
├── ejercicio-3-practica-de-ingest-local/     # Ingesta desde fuentes externas
│   ├── scripts/
│   │   └── landing.sh                        # Script de ingesta local
│   ├── images/                               # Capturas de pantalla
│   └── README.md
├── ejercicio-4-practica-ingest-sqoop/        # Ingesta desde PostgreSQL
│   ├── scripts/
│   │   └── sqoop.sh                          # Script de comandos Sqoop
│   └── README.md
└── README.md                                 # Este archivo
```

---

## 🚀 Ejercicios Incluidos

### 1️⃣ **Ejercicio 3: Ingesta Local con Hadoop**

**Descripción:** Descarga un archivo CSV desde GitHub, lo mueve a HDFS y limpia archivos temporales.

**Características:**
- ✅ Descarga automática desde GitHub
- ✅ Gestión de directorios temporales
- ✅ Subida a HDFS
- ✅ Limpieza automática de archivos

**Archivo:** `ejercicio-3-practica-de-ingest-local/scripts/landing.sh`

### 2️⃣ **Ejercicio 4: Ingesta con Sqoop**

**Descripción:** Conecta PostgreSQL con Hadoop usando Sqoop para importar datos.

**Características:**
- ✅ Conexión JDBC con PostgreSQL
- ✅ Listado de tablas
- ✅ Consultas SQL directas
- ✅ Importación completa y filtrada
- ✅ Formato Parquet

**Archivo:** `ejercicio-4-practica-ingest-sqoop/scripts/sqoop.sh`

---

## 🔧 Requisitos Previos

### Entorno de Desarrollo
- **Docker** con contenedores de Hadoop y PostgreSQL
- **Bash** para ejecutar scripts
- Acceso a terminal del contenedor Hadoop

### Contenedores Necesarios
```bash
# Contenedor Hadoop
docker exec -it edvai_hadoop bash
su hadoop

# Verificar PostgreSQL
docker inspect edvai_postgres
```

---

## 📋 Cómo Ejecutar

### Ejercicio 3: Ingesta Local
```bash
# 1. Navegar al directorio
cd ejercicio-3-practica-de-ingest-local/scripts/

# 2. Dar permisos de ejecución
chmod +x landing.sh

# 3. Ejecutar el script
./landing.sh

# 4. Verificar en HDFS
hdfs dfs -ls /ingest
```

### Ejercicio 4: Ingesta con Sqoop
```bash
# 1. Navegar al directorio
cd ejercicio-4-practica-ingest-sqoop/scripts/

# 2. Dar permisos de ejecución
chmod +x sqoop.sh

# 3. Ejecutar el script
./sqoop.sh
```

---

## 📊 Datos Utilizados

### Ejercicio 3
- **Fuente:** [starwars.csv](https://github.com/fpineyro/homework-0/blob/master/starwars.csv)
- **Destino:** `/ingest/` en HDFS
- **Formato:** CSV

### Ejercicio 4
- **Fuente:** Base de datos Northwind (PostgreSQL)
- **Tabla:** `region`
- **Destino:** `/sqoop/ingest/` en HDFS
- **Formato:** Parquet

---

## 🛠️ Tecnologías Utilizadas

- **Hadoop** - Framework de procesamiento distribuido
- **HDFS** - Sistema de archivos distribuido
- **Sqoop** - Herramienta de transferencia de datos
- **PostgreSQL** - Base de datos relacional
- **Bash** - Scripting y automatización
- **Docker** - Contenedores

---

## 📝 Notas Importantes

- Los scripts incluyen manejo de errores y mensajes informativos
- Se realizan limpiezas automáticas de archivos temporales
- Los directorios se crean automáticamente si no existen
- Las conexiones JDBC requieren configuración de red entre contenedores

---

## 👨‍💻 Autor

**Enzo** - Prácticas de Data Engineering

---

## 📚 Recursos Adicionales

- [Documentación de Hadoop](https://hadoop.apache.org/docs/)
- [Guía de Sqoop](https://sqoop.apache.org/docs/)
- [Docker para Data Engineering](https://docs.docker.com/)