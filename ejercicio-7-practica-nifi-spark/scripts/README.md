# Scripts de Descarga - Ejercicio 7

## Archivo: download_parquet.sh

Este script automatiza la descarga del archivo Parquet de datos de taxis de NYC desde S3.

### Características del Script

- ✅ **Descarga automática**: Desde S3 a directorio local
- ✅ **Creación de directorios**: Automática si no existen
- ✅ **Verificación de dependencias**: Comprueba que wget esté instalado
- ✅ **Logging detallado**: Registra todo el proceso
- ✅ **Configuración de permisos**: Establece permisos apropiados
- ✅ **Verificación de tamaño**: Confirma descarga exitosa

### Configuración

```bash
# Variables configurables
DOWNLOAD_URL="https://data-engineer-edvai-public.s3.amazonaws.com/yellow_tripdata_2021-01.parquet"
LOCAL_DIR="/home/nifi/ingest"
FILENAME="yellow_tripdata_2021-01.parquet"
LOG_FILE="/home/nifi/download_log.txt"
```

### Uso del Script

```bash
# 1. Dar permisos de ejecución
chmod +x download_parquet.sh

# 2. Ejecutar el script
./download_parquet.sh

# 3. Verificar el log
cat /home/nifi/download_log.txt
```

### Archivo Descargado

- **Nombre**: `yellow_tripdata_2021-01.parquet`
- **Tamaño**: ~20.6 MB
- **Formato**: Parquet (columnar)
- **Contenido**: Datos de taxis amarillos de NYC (Enero 2021)
- **Ubicación**: `/home/nifi/ingest/`

### Verificación de Resultados

```bash
# Verificar que el archivo existe
ls -l /home/nifi/ingest/yellow_tripdata_2021-01.parquet

# Verificar tamaño
du -h /home/nifi/ingest/yellow_tripdata_2021-01.parquet

# Verificar permisos
ls -la /home/nifi/ingest/
```

### Troubleshooting

#### Problemas Comunes

1. **Error de permisos**:
   ```bash
   # Solución: Verificar permisos del directorio
   ls -la /home/nifi/
   chmod 755 /home/nifi/ingest/
   ```

2. **Error de red**:
   ```bash
   # Verificar conectividad
   ping google.com
   curl -I https://data-engineer-edvai-public.s3.amazonaws.com/
   ```

3. **Error de espacio**:
   ```bash
   # Verificar espacio disponible
   df -h /home/nifi/
   ```

#### Logs del Script

El script genera un archivo `download_log.txt` con:
- Timestamp de inicio y fin
- URL de descarga
- Tamaño del archivo descargado
- Permisos configurados
- Errores encontrados

### Mejoras del Script

#### Versión Avanzada
```bash
# Agregar verificación de integridad
wget --spider "$DOWNLOAD_URL" && echo "URL accesible" || echo "URL no accesible"

# Agregar reintentos
wget --tries=3 --timeout=30 -O "$LOCAL_DIR/$FILENAME" "$DOWNLOAD_URL"

# Agregar compresión
gzip "$LOCAL_DIR/$FILENAME"
```

#### Parámetros Adicionales
```bash
# Descargar con progreso
wget --progress=bar -O "$LOCAL_DIR/$FILENAME" "$DOWNLOAD_URL"

# Descargar con resumen
wget --progress=dot -O "$LOCAL_DIR/$FILENAME" "$DOWNLOAD_URL"

# Descargar con timeout personalizado
wget --timeout=60 -O "$LOCAL_DIR/$FILENAME" "$DOWNLOAD_URL"
```

### Integración con NiFi

El script está diseñado para trabajar con NiFi:

1. **Directorio de entrada**: `/home/nifi/ingest/`
2. **Formato compatible**: Parquet
3. **Permisos**: Configurados para NiFi
4. **Logging**: Disponible para monitoreo

### Próximos Pasos

Después de ejecutar el script:

1. **Verificar descarga**: Comprobar que el archivo existe
2. **Configurar NiFi**: Crear flujo de procesamiento
3. **Procesar con Spark**: Cargar datos para análisis
4. **Ejecutar consultas**: Aplicar análisis de datos
