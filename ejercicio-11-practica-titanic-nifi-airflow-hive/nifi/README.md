# NiFi - Configuración y Flujo Titanic

Este directorio contiene los archivos de configuración necesarios para que NiFi pueda conectarse a HDFS y realizar la ingesta de datos.

## 📄 Archivos

### `core-site.xml`
Archivo de configuración principal de Hadoop para NiFi.

**Ubicación en NiFi**: `/home/nifi/hadoop/core-site.xml`

**Configuración clave**:
- `fs.defaultFS`: URL del NameNode de HDFS (`hdfs://172.17.0.2:9000`)

### `hdfs-site.xml`
Archivo de configuración específica de HDFS para NiFi.

**Ubicación en NiFi**: `/home/nifi/hadoop/hdfs-site.xml`

**Configuración clave**:
- `dfs.replication`: Factor de replicación (1 para desarrollo)
- `dfs.name.dir`: Directorio del NameNode
- `dfs.data.dir`: Directorio del DataNode

## 🚀 Instalación

### 1. Copiar archivos al contenedor NiFi

```bash
# Opción A: Copiar desde host
docker cp core-site.xml nifi:/home/nifi/hadoop/
docker cp hdfs-site.xml nifi:/home/nifi/hadoop/

# Opción B: Crear dentro del contenedor
docker exec -it nifi bash
mkdir -p /home/nifi/hadoop
# Luego crear los archivos con nano o cat
```

### 2. Verificar archivos

```bash
docker exec -it nifi bash
ls -la /home/nifi/hadoop/
cat /home/nifi/hadoop/core-site.xml
cat /home/nifi/hadoop/hdfs-site.xml
```

## 🔧 Flujo NiFi

### Procesadores Necesarios

#### 1. GetFile (Origen)
**Propósito**: Leer archivo desde directorio local de NiFi

**Configuración**:
```
Input Directory: /home/nifi/ingest
File Filter: titanic.csv
Keep Source File: false
Minimum File Age: 0 sec
```

#### 2. PutFile (Intermedio)
**Propósito**: Mover archivo a directorio bucket

**Configuración**:
```
Directory: /home/nifi/bucket
Conflict Resolution Strategy: replace
Create Missing Directories: true
```

#### 3. GetFile (Bucket)
**Propósito**: Leer archivo desde bucket

**Configuración**:
```
Input Directory: /home/nifi/bucket
File Filter: titanic.csv
Keep Source File: false
Minimum File Age: 0 sec
```

#### 4. PutHDFS
**Propósito**: Ingestar archivo en HDFS

**Configuración**:
```
Hadoop Configuration Resources:
  /home/nifi/hadoop/core-site.xml,/home/nifi/hadoop/hdfs-site.xml
  
Directory: /nifi
Conflict Resolution Strategy: replace
Compression codec: NONE
```

### Conexiones

Conectar los procesadores en este orden:

```
GetFile (ingest)
    |
    | success
    v
PutFile (bucket)
    |
    | success
    v
GetFile (bucket)
    |
    | success
    v
PutHDFS
```

## 📊 Diagrama del Flujo

```
┌────────────────┐
│   GetFile      │
│ /nifi/ingest   │
└───────┬────────┘
        │ success
        v
┌────────────────┐
│   PutFile      │
│ /nifi/bucket   │
└───────┬────────┘
        │ success
        v
┌────────────────┐
│   GetFile      │
│ /nifi/bucket   │
└───────┬────────┘
        │ success
        v
┌────────────────┐
│   PutHDFS      │
│ /nifi          │
└────────────────┘
```

## ✅ Verificación

### 1. Verificar que NiFi puede leer los archivos

```bash
docker exec -it nifi bash
cat /home/nifi/hadoop/core-site.xml
cat /home/nifi/hadoop/hdfs-site.xml
```

### 2. Verificar permisos HDFS

```bash
docker exec -it edvai_hadoop bash
hdfs dfs -ls /
hdfs dfs -ls /nifi
```

Debe mostrar permisos `drwxrwxrwx` para `/nifi`.

### 3. Probar conexión desde NiFi a HDFS

Ejecutar el flujo y revisar los logs de PutHDFS. No debe haber errores de conexión.

### 4. Verificar archivo en HDFS

```bash
hdfs dfs -ls /nifi
hdfs dfs -cat /nifi/titanic.csv | head -5
```

## 🐛 Troubleshooting

### Error: "Could not connect to HDFS"

**Causa**: Archivos de configuración mal ubicados o incorrectos.

**Solución**:
```bash
# Verificar ruta completa en PutHDFS
/home/nifi/hadoop/core-site.xml,/home/nifi/hadoop/hdfs-site.xml

# Verificar que la IP del NameNode es correcta
docker inspect edvai_hadoop | grep IPAddress
```

### Error: "Permission denied"

**Causa**: El directorio `/nifi` en HDFS no tiene permisos.

**Solución**:
```bash
hdfs dfs -chmod 777 /nifi
```

### Error: "File already exists"

**Causa**: El archivo ya existe en HDFS y la estrategia no es `replace`.

**Solución**:
```
En PutHDFS → Properties → Conflict Resolution Strategy → replace
```

### NiFi no puede leer el archivo

**Causa**: El archivo no está en el directorio correcto.

**Solución**:
```bash
# Verificar ubicación
docker exec -it nifi ls -la /home/nifi/ingest/

# Mover si es necesario
docker exec -it nifi mv /path/actual /home/nifi/ingest/
```

## 📚 Referencias

- [NiFi PutHDFS Processor](https://nifi.apache.org/docs/nifi-docs/components/org.apache.nifi/nifi-hdfs-nar/1.14.0/org.apache.nifi.processors.hadoop.PutHDFS/index.html)
- [Hadoop Configuration Files](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/core-default.xml)

---

**Última actualización**: 2025-11-20

