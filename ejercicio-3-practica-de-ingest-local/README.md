# 🚀 Práctica Ingest - Hadoop

Este repositorio contiene la práctica de ingest solicitada, donde se descarga un archivo CSV desde GitHub, se mueve a HDFS y se limpia el directorio temporal.

---

## 📂 Archivos incluidos

- **`landing.sh`** → Script ejecutable en Bash que realiza todo el proceso de ingest.  

---

## 📝 Descripción del proceso

1. Crear un directorio temporal `/home/hadoop/landing`.  
2. Descargar el archivo [`starwars.csv`](https://github.com/fpineyro/homework-0/blob/master/starwars.csv) en ese directorio.  
3. Crear el directorio `/ingest` en HDFS (si no existe).  
4. Subir el archivo CSV desde el directorio local al HDFS.  
5. Eliminar el archivo temporal de `/home/hadoop/landing`.  
6. Verificar que el archivo está en `/ingest` dentro de HDFS.  

---

## ⚙️ Cómo ejecutar

En la terminal de Hadoop:

```bash
# 1. Dar permisos de ejecución
chmod +x landing.sh

# 2. Ejecutar el script
./landing.sh

# 3. Verificar en HDFS
hdfs dfs -ls /ingest
