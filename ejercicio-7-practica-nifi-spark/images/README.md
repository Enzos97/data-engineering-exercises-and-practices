# Imágenes del Ejercicio 7 - Práctica NiFi + Spark

## 📸 Capturas de Pantalla

### 1. Flujo de NiFi
**Archivo**: `nifi-process.jpg`
- **Procesadores**: GetFile y PutHDFS
- **Conexión**: success (50 archivos, 1.01 GB)
- **Estado**: Procesamiento activo
- **Métricas**: Datos en cola esperando procesamiento

## 🔍 Análisis de la Imagen

### GetFile Processor
- **Estado**: Procesado exitosamente
- **Archivos**: 1 archivo Parquet procesado
- **Tamaño**: 20.6 MB original
- **Conexión**: Datos enviados a PutHDFS

### Conexión "success"
- **Estado**: 50 archivos en cola
- **Tamaño**: 1.01 GB (comprimido)
- **Progreso**: Barra de progreso visible
- **Flujo**: Datos fluyendo hacia PutHDFS

### PutHDFS Processor
- **Estado**: Procesando archivos
- **Destino**: HDFS `/nifi/`
- **Formato**: Parquet preservado
- **Configuración**: Hadoop configurado

## 📊 Métricas de Procesamiento

### Datos Procesados
- **Archivos fuente**: 1
- **Tamaño original**: 20.6 MB
- **Tamaño comprimido**: 1.01 GB
- **Formato**: Parquet
- **Compresión**: Automática

### Estado del Flujo
- **GetFile**: ✅ Completado
- **Conexión**: 🔄 Procesando
- **PutHDFS**: 🔄 Escribiendo a HDFS

## 🛠️ Configuración del Flujo

### GetFile Processor
```properties
Input Directory: /home/nifi/ingest
File Filter: yellow_tripdata_2021-01.parquet
Keep Source File: true
Recurse Subdirectories: false
```

### PutHDFS Processor
```properties
Hadoop Configuration: /opt/hadoop/etc/hadoop/core-site.xml
Directory: /nifi
Conflict Resolution: replace
Create Missing Directories: true
```

## 🔧 Troubleshooting

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

# Verificar HDFS
hdfs dfs -ls /nifi/
hdfs dfs -mkdir -p /nifi

# Verificar permisos
chmod 644 /home/nifi/ingest/yellow_tripdata_2021-01.parquet
```

## 📝 Notas Técnicas

### Formato Parquet
- **Ventajas**: Compresión automática, esquema preservado
- **Compatibilidad**: Total con Spark y PySpark
- **Rendimiento**: Optimizado para análisis de datos
- **Metadatos**: Incluidos en el archivo

### Procesamiento NiFi
- **Paralelización**: Procesamiento eficiente
- **Monitoreo**: Métricas en tiempo real
- **Recuperación**: Manejo automático de errores
- **Escalabilidad**: Fácil escalado horizontal

### Almacenamiento HDFS
- **Distribución**: Archivos replicados automáticamente
- **Tolerancia a fallos**: Alta disponibilidad
- **Escalabilidad**: Crecimiento horizontal
- **Integración**: Compatible con ecosistema Hadoop

## 🎯 Resultado Esperado

Al finalizar el procesamiento:

1. **Archivo en HDFS**: `/nifi/yellow_tripdata_2021-01.parquet`
2. **Tamaño**: ~20.6 MB (descomprimido)
3. **Formato**: Parquet
4. **Permisos**: Configurados correctamente
5. **Disponible para Spark**: Listo para análisis
6. **Métricas**: Procesamiento exitoso
