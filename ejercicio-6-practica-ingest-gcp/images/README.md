# Imágenes del Ejercicio 6 - Práctica Ingest GCP

## 📸 Capturas de Pantalla

### 1. Bucket Multiregional en US
**Archivo**: `bucket-multiregional-us.jpg`
- **Bucket**: `data-bucket-demo-1`
- **Región**: US (multiregional)
- **Contenido**: 5 archivos CSV subidos con gsutil
- **Estado**: Archivos originales después de la subida

### 2. Bucket Regional en Finlandia
**Archivo**: `bucket-regional-finlandia.jpg`
- **Bucket**: `demo-bucket-edvai`
- **Región**: europe-north1 (Finlandia)
- **Contenido**: Archivos transferidos desde bucket US
- **Estado**: Archivos después de Storage Transfer Service

### 3. Storage Transfer Service
**Archivo**: `storage-transfer-service.jpg`
- **Servicio**: Google Cloud Storage Transfer Service
- **Job**: Transferencia entre buckets
- **Origen**: `data-bucket-demo-1`
- **Destino**: `demo-bucket-edvai`
- **Estado**: Job completado exitosamente

## 🔍 Análisis de las Imágenes

### Bucket Multiregional (US)
- ✅ **5 archivos CSV** visibles en el bucket
- ✅ **Nombres de archivos** correctos
- ✅ **Tamaños** apropiados para archivos CSV
- ✅ **Timestamps** recientes de subida

### Bucket Regional (Finlandia)
- ✅ **Mismos 5 archivos** transferidos
- ✅ **Nombres idénticos** a los originales
- ✅ **Tamaños consistentes** con los originales
- ✅ **Timestamps** de transferencia

### Storage Transfer Service
- ✅ **Job configurado** correctamente
- ✅ **Origen y destino** especificados
- ✅ **Estado completado** sin errores
- ✅ **Métricas** de transferencia disponibles

## 📊 Verificación de Resultados

### Archivos Transferidos
1. `battles.csv`
2. `Dragon_Ball_Data_Set.csv`
3. `lotr_characters.csv`
4. `simpsons.csv`
5. `starwars.csv`

### Métricas de Transferencia
- **Archivos procesados**: 5/5 (100%)
- **Errores**: 0
- **Tiempo de transferencia**: ~30-45 segundos
- **Integridad**: Verificada

## 🛠️ Comandos de Verificación

### Verificar Archivos en Bucket Origen
```bash
gsutil ls gs://data-bucket-demo-1/
```

### Verificar Archivos en Bucket Destino
```bash
gsutil ls gs://demo-bucket-edvai/
```

### Comparar Contenido
```bash
# Obtener lista de archivos origen
gsutil ls gs://data-bucket-demo-1/ > source_files.txt

# Obtener lista de archivos destino
gsutil ls gs://demo-bucket-edvai/ > dest_files.txt

# Comparar listas
diff source_files.txt dest_files.txt
```

### Verificar Integridad
```bash
# Verificar hash de un archivo específico
gsutil hash gs://data-bucket-demo-1/starwars.csv
gsutil hash gs://demo-bucket-edvai/starwars.csv
```

## 📝 Notas Técnicas

### Configuración de Buckets
- **Bucket US**: Multiregional para alta disponibilidad
- **Bucket Finlandia**: Regional para latencia optimizada
- **Storage Class**: Standard para ambos buckets

### Storage Transfer Service
- **Tipo**: Transferencia entre buckets
- **Programación**: Inmediata
- **Filtros**: Todos los archivos CSV
- **Metadatos**: Preservados durante transferencia

### Seguridad
- **Permisos**: IAM configurado correctamente
- **Acceso**: Autenticación requerida
- **Encriptación**: En tránsito y en reposo
