# 📘 Prácticas de Ingesta con Hadoop

Este repositorio contiene ejercicios de **ingesta de datos** usando Hadoop y HDFS.  
Incluye ejemplos con scripts (`.sh`).  

---

## 🔧 Requisitos iniciales

Antes de comenzar con los ejercicios, es necesario tener disponible un entorno de Hadoop (en este caso se utilizó un contenedor Docker).  

### Pasos previos

1. Ingresar al contenedor:
   ```bash
   docker exec -it <nombre_contenedor> bash

2. Cambiar de usuario a hadoop:
    su hadoop

1. Crear el script landing.sh:
    nano landing.sh

#!/bin/bash
# landing.sh
# Script de práctica Hadoop - Ingest
# Autor: Enzo
# Descripción: Descarga starwars.csv desde GitHub, lo sube a HDFS y elimina el archivo temporal.

# 1. Crear directorio temporal si no existe
mkdir -p /home/hadoop/landing

# 2. Descargar archivo desde GitHub (modo RAW)
wget -O /home/hadoop/landing/starwars.csv https://raw.githubusercontent.com/fpineyro/homework-0/master/starwars.csv

# 3. Crear directorio en HDFS (si no existe)
hdfs dfs -mkdir -p /ingest

# 4. Subir archivo desde local a HDFS
hdfs dfs -put /home/hadoop/landing/starwars.csv /ingest/

# 5. Borrar archivo temporal
rm -f /home/hadoop/landing/starwars.csv

# 6. Mensaje final
echo "✅ Archivo cargado en HDFS y borrado del directorio temporal."
