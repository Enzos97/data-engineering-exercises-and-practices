# Scripts de Ingesta GCP

## Archivo: upload_csvs.sh

Este script automatiza la subida de archivos CSV a Google Cloud Storage utilizando gsutil CLI.

### Características del Script

- ✅ **Verificación de dependencias**: Comprueba que gsutil esté instalado
- ✅ **Validación de directorio**: Verifica que la carpeta de archivos CSV exista
- ✅ **Subida individual**: Procesa cada archivo CSV por separado
- ✅ **Logging detallado**: Registra el proceso en archivo de log
- ✅ **Manejo de errores**: Gestiona errores de subida individualmente

### Configuración

```bash
# Variables configurables
BUCKET_NAME="data-bucket-demo-1"                    # Nombre del bucket destino
LOCAL_DIR="/mnt/c/Users/enz_9/OneDrive/Desktop/EDVai/csvFiles"  # Directorio local
LOG_FILE="./upload_log.txt"                         # Archivo de log
```

### Uso del Script

```bash
# 1. Dar permisos de ejecución
chmod +x upload_csvs.sh

# 2. Ejecutar el script
./upload_csvs.sh

# 3. Verificar el log
cat upload_log.txt
```

### Archivos CSV Procesados

El script procesa los siguientes archivos CSV:
- `battles.csv`
- `Dragon_Ball_Data_Set.csv`
- `lotr_characters.csv`
- `simpsons.csv`
- `starwars.csv`

### Verificación de Resultados

```bash
# Listar archivos en el bucket
gsutil ls gs://data-bucket-demo-1/

# Verificar archivos específicos
gsutil ls gs://data-bucket-demo-1/*.csv

# Descargar un archivo para verificar
gsutil cp gs://data-bucket-demo-1/starwars.csv ./
```

### Troubleshooting

#### Problemas Comunes

1. **Error de autenticación**:
   ```bash
   # Reautenticar con GCP
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Error de permisos**:
   ```bash
   # Verificar permisos del bucket
   gsutil iam get gs://data-bucket-demo-1
   ```

3. **Error de red**:
   ```bash
   # Verificar conectividad
   gsutil version
   ```

#### Logs del Script

El script genera un archivo `upload_log.txt` con:
- Timestamp de inicio y fin
- Archivos procesados
- Errores encontrados
- Resumen del proceso

### Mejoras del Script

#### Versión Avanzada
```bash
# Agregar compresión
gsutil -m cp -Z "$file" "gs://$BUCKET_NAME/"

# Agregar metadatos
gsutil cp -h "Content-Type:text/csv" "$file" "gs://$BUCKET_NAME/"

# Agregar verificación de integridad
gsutil hash "$file" > temp_hash.txt
gsutil hash "gs://$BUCKET_NAME/$(basename "$file")" > remote_hash.txt
diff temp_hash.txt remote_hash.txt
```

#### Parámetros Adicionales
```bash
# Subir con paralelización
gsutil -m cp "$file" "gs://$BUCKET_NAME/"

# Subir con compresión
gsutil cp -Z "$file" "gs://$BUCKET_NAME/"

# Subir con metadatos personalizados
gsutil cp -h "x-goog-meta-source:script" "$file" "gs://$BUCKET_NAME/"
```
