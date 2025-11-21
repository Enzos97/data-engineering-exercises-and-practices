# Scripts - Titanic Data Ingestion

Este directorio contiene scripts de bash para la descarga automatizada de datos del Titanic.

## 📄 Scripts Disponibles

### `ingest.sh`

Script principal para descargar el archivo `titanic.csv` desde S3 al directorio de ingesta de NiFi.

## 🎯 Funcionalidad

### Script: `ingest.sh`

**Propósito**: Descargar datos del Titanic desde S3 de AWS a NiFi.

**Ubicación de ejecución**: `/home/nifi/ingest/`

**Flujo de ejecución**:

```
1. Crear directorio /home/nifi/ingest (si no existe)
2. Descargar titanic.csv desde S3
3. Verificar descarga exitosa
4. Mostrar mensaje de confirmación
```

## 📦 Requisitos

- `wget` instalado en el contenedor NiFi
- Conexión a internet
- Permisos de escritura en `/home/nifi/ingest`

## 🚀 Instalación

### 1. Copiar script al contenedor NiFi

```bash
# Opción A: Copiar desde host
docker cp ingest.sh nifi:/home/nifi/scripts/

# Opción B: Crear dentro del contenedor
docker exec -it nifi bash
mkdir -p /home/nifi/scripts
cd /home/nifi/scripts
nano ingest.sh
# Copiar contenido del script
```

### 2. Dar permisos de ejecución

```bash
docker exec -it nifi bash
chmod +x /home/nifi/scripts/ingest.sh
```

### 3. Verificar permisos

```bash
ls -la /home/nifi/scripts/ingest.sh
```

**Salida esperada**:
```
-rwxr-xr-x 1 nifi nifi 582 Nov 12 10:00 ingest.sh
```

## ▶️ Ejecución

### Método 1: Desde dentro del contenedor

```bash
# Ingresar al contenedor
docker exec -it nifi bash

# Ejecutar script
/home/nifi/scripts/ingest.sh
```

### Método 2: Desde el host

```bash
docker exec -it nifi /home/nifi/scripts/ingest.sh
```

### Método 3: Con bash explícito

```bash
docker exec -it nifi bash /home/nifi/scripts/ingest.sh
```

## 📊 Salida Esperada

```
=== INICIANDO DESCARGA DE TITANIC.CSV ===
1. Creando directorio de ingesta: /home/nifi/ingest
2. Descargando titanic.csv desde https://data-engineer-edvai-public.s3.amazonaws.com/titanic.csv a /home/nifi/ingest...
--2025-11-12 10:00:00--  https://data-engineer-edvai-public.s3.amazonaws.com/titanic.csv
Resolving data-engineer-edvai-public.s3.amazonaws.com... 52.219.72.1
Connecting to data-engineer-edvai-public.s3.amazonaws.com|52.219.72.1|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 61194 (60K) [text/csv]
Saving to: '/home/nifi/ingest/titanic.csv'

/home/nifi/ingest/ti 100%[===================>]  59.76K  --.-KB/s    in 0.02s

2025-11-12 10:00:00 (3.45 MB/s) - '/home/nifi/ingest/titanic.csv' saved [61194/61194]

✅ Descarga completada exitosamente: /home/nifi/ingest/titanic.csv
=== PROCESO DE DESCARGA COMPLETADO ===
```

## ✅ Verificación

### 1. Verificar que el archivo existe

```bash
docker exec -it nifi ls -lh /home/nifi/ingest/
```

**Salida esperada**:
```
total 60K
-rw-r--r-- 1 nifi nifi 60K Nov 12 10:00 titanic.csv
```

### 2. Verificar contenido del archivo

```bash
docker exec -it nifi head -5 /home/nifi/ingest/titanic.csv
```

**Salida esperada**:
```
PassengerId,Survived,Pclass,Name,Sex,Age,SibSp,Parch,Ticket,Fare,Cabin,Embarked
1,0,3,"Braund, Mr. Owen Harris",male,22,1,0,A/5 21171,7.25,,S
2,1,1,"Cumings, Mrs. John Bradley (Florence Briggs Thayer)",female,38,1,0,PC 17599,71.2833,C85,C
3,1,3,"Heikkinen, Miss. Laina",female,26,0,0,STON/O2. 3101282,7.925,,S
4,1,1,"Futrelle, Mrs. Jacques Heath (Lily May Peel)",female,35,1,0,113803,53.1,C123,S
```

### 3. Contar líneas (debe ser 892: 1 header + 891 registros)

```bash
docker exec -it nifi wc -l /home/nifi/ingest/titanic.csv
```

**Salida esperada**:
```
892 /home/nifi/ingest/titanic.csv
```

### 4. Verificar tamaño del archivo

```bash
docker exec -it nifi du -h /home/nifi/ingest/titanic.csv
```

**Salida esperada**:
```
60K     /home/nifi/ingest/titanic.csv
```

## 🐛 Troubleshooting

### Error: "Permission denied"

**Causa**: El script no tiene permisos de ejecución.

**Solución**:
```bash
docker exec -it nifi chmod +x /home/nifi/scripts/ingest.sh
```

### Error: "wget: command not found"

**Causa**: `wget` no está instalado en el contenedor.

**Solución**:
```bash
docker exec -it nifi bash
apt-get update
apt-get install -y wget
```

O usar `curl` en su lugar:
```bash
curl -o /home/nifi/ingest/titanic.csv https://data-engineer-edvai-public.s3.amazonaws.com/titanic.csv
```

### Error: "No such file or directory"

**Causa**: El directorio `/home/nifi/ingest` no existe.

**Solución**: El script debe crearlo automáticamente. Si no, crearlo manualmente:
```bash
docker exec -it nifi mkdir -p /home/nifi/ingest
```

### Error: "Failed to resolve hostname"

**Causa**: Problemas de DNS o sin conexión a internet.

**Solución**:
```bash
# Verificar conexión
docker exec -it nifi ping -c 3 8.8.8.8

# Verificar DNS
docker exec -it nifi ping -c 3 google.com
```

### Archivo descargado está vacío o corrupto

**Solución**:
```bash
# Eliminar archivo
docker exec -it nifi rm /home/nifi/ingest/titanic.csv

# Re-ejecutar script
docker exec -it nifi /home/nifi/scripts/ingest.sh
```

## 🔄 Re-ejecución

Si necesitas volver a descargar el archivo:

```bash
# El script sobrescribirá el archivo existente automáticamente
docker exec -it nifi /home/nifi/scripts/ingest.sh
```

O eliminar manualmente primero:

```bash
docker exec -it nifi rm /home/nifi/ingest/titanic.csv
docker exec -it nifi /home/nifi/scripts/ingest.sh
```

## 📝 Personalización

### Cambiar directorio de destino

Modificar la variable `INGEST_DIR`:

```bash
INGEST_DIR="/ruta/personalizada"
```

### Descargar desde otra fuente

Modificar la variable `URL`:

```bash
URL="https://tu-servidor.com/datos/titanic.csv"
```

### Cambiar nombre del archivo

Modificar la variable `FILENAME`:

```bash
FILENAME="datos_titanic.csv"
```

### Agregar validaciones

```bash
# Después de la descarga, agregar:
if [ $(wc -l < $INGEST_DIR/$FILENAME) -lt 800 ]; then
    echo "❌ Error: El archivo tiene muy pocas líneas"
    exit 1
fi
```

## 📚 Referencias

- [wget Manual](https://www.gnu.org/software/wget/manual/wget.html)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [Titanic Dataset](https://data-engineer-edvai-public.s3.amazonaws.com/titanic.csv)

---

**Última actualización**: 2025-11-20

