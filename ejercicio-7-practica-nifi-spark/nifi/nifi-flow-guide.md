# Guía de Flujo NiFi - Procesamiento de Archivo Parquet

## 🎯 Objetivo

Crear un flujo en NiFi que procese el archivo `yellow_tripdata_2021-01.parquet` desde el sistema de archivos local hacia HDFS.

## 📋 Pasos del Flujo

### 1️⃣ **GetFile Processor**

**Función**: Obtener archivo desde directorio local
**Configuración**:
- **Input Directory**: `/home/nifi/ingest`
- **File Filter**: `yellow_tripdata_2021-01.parquet`
- **Keep Source File**: `true`
- **Recurse Subdirectories**: `false`

**Pasos en la interfaz**:
1. Arrastrar **GetFile** desde la paleta de procesadores
2. Hacer clic derecho → **Configure**
3. En la pestaña **Properties**:
   - `Input Directory`: `/home/nifi/ingest`
   - `File Filter`: `yellow_tripdata_2021-01.parquet`
   - `Keep Source File`: `true`
4. Hacer clic en **Apply**

### 2️⃣ **PutHDFS Processor**

**Función**: Escribir archivo a HDFS
**Configuración**:
- **Hadoop Configuration Resources**: `/opt/hadoop/etc/hadoop/core-site.xml`
- **Directory**: `/nifi`
- **Conflict Resolution Strategy**: `replace`

**Pasos en la interfaz**:
1. Arrastrar **PutHDFS** desde la paleta de procesadores
2. Hacer clic derecho → **Configure**
3. En la pestaña **Properties**:
   - `Hadoop Configuration Resources`: `/opt/hadoop/etc/hadoop/core-site.xml`
   - `Directory`: `/nifi`
   - `Conflict Resolution Strategy`: `replace`
4. Hacer clic en **Apply**

### 3️⃣ **Conexión entre Procesadores**

**Pasos en la interfaz**:
1. Hacer clic en el **GetFile** processor
2. Arrastrar la flecha hacia **PutHDFS**
3. Seleccionar **success** como relación
4. Hacer clic en **Add**

## 🔧 Configuración Detallada

### GetFile Processor

```properties
# Configuración básica
Input Directory: /home/nifi/ingest
File Filter: yellow_tripdata_2021-01.parquet
Keep Source File: true
Recurse Subdirectories: false

# Configuración avanzada
Polling Interval: 0 sec
Minimum File Age: 0 sec
Maximum File Age: 24 hours
```

### PutHDFS Processor

```properties
# Configuración básica
Hadoop Configuration Resources: /opt/hadoop/etc/hadoop/core-site.xml
Directory: /nifi
Conflict Resolution Strategy: replace

# Configuración avanzada
Create Missing Directories: true
Chunk Size: 1 MB
```

## 🚀 Ejecución del Flujo

### 1. Iniciar Procesadores

1. Hacer clic derecho en **GetFile** → **Start**
2. Hacer clic derecho en **PutHDFS** → **Start**
3. Verificar que ambos procesadores estén en estado **Running**

### 2. Monitorear Procesamiento

**Métricas a observar**:
- **GetFile**: Debe mostrar archivos procesados
- **Conexión**: Debe mostrar datos en cola
- **PutHDFS**: Debe mostrar archivos escritos a HDFS

### 3. Verificar Resultados

```bash
# Verificar archivo en HDFS
hdfs dfs -ls /nifi/
hdfs dfs -ls /nifi/yellow_tripdata_2021-01.parquet
```

## 🔍 Troubleshooting

### Problemas Comunes

1. **GetFile no encuentra archivo**:
   - Verificar que el archivo existe en `/home/nifi/ingest/`
   - Verificar permisos del directorio
   - Verificar filtro de archivos

2. **PutHDFS falla**:
   - Verificar configuración de Hadoop
   - Verificar permisos de HDFS
   - Verificar que el directorio `/nifi` existe

3. **Conexión no funciona**:
   - Verificar que ambos procesadores estén iniciados
   - Verificar configuración de la conexión
   - Verificar que no hay errores de validación

### Soluciones

```bash
# Verificar archivo fuente
ls -la /home/nifi/ingest/yellow_tripdata_2021-01.parquet

# Verificar permisos
chmod 644 /home/nifi/ingest/yellow_tripdata_2021-01.parquet

# Verificar HDFS
hdfs dfs -ls /nifi/
hdfs dfs -mkdir -p /nifi
```

## 📊 Métricas de Rendimiento

### Métricas Esperadas

- **Archivos procesados**: 1
- **Tamaño procesado**: ~20.6 MB
- **Tiempo de procesamiento**: 1-2 minutos
- **Errores**: 0

### Monitoreo en Tiempo Real

1. **GetFile Metrics**:
   - Input: 1 (20.6 MB)
   - Output: 1 (20.6 MB)
   - Tasks: 1

2. **PutHDFS Metrics**:
   - Input: 1 (20.6 MB)
   - Output: 1 (20.6 MB)
   - Tasks: 1

## 🎯 Resultado Esperado

Al finalizar el procesamiento:

1. **Archivo en HDFS**: `/nifi/yellow_tripdata_2021-01.parquet`
2. **Tamaño**: ~20.6 MB
3. **Formato**: Parquet
4. **Permisos**: Configurados correctamente
5. **Disponible para Spark**: Listo para análisis

## 📝 Notas Importantes

- **Formato Parquet**: Optimizado para análisis de datos
- **Compresión**: Automática en formato Parquet
- **Esquema**: Preservado durante la transferencia
- **Metadatos**: Incluidos en el archivo final
- **Compatibilidad**: Total con Spark y PySpark
