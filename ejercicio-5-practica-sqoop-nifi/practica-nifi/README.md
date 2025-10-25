# Práctica NiFi - Procesamiento de Datos con Apache NiFi

## Configuración del Ambiente

### 1. Descargar y Ejecutar NiFi

```bash
# Descargar imagen de NiFi
docker pull apache/nifi:2.3.0

# Ejecutar contenedor NiFi
docker run --name nifi -p 8443:8443 -d apache/nifi:2.3.0
```

### 2. Configurar Librerías HDFS

Para versiones de NiFi superiores a la 2.0, es necesario agregar las librerías de Hadoop:

```bash
# Descargar archivos NAR desde Maven
wget https://repo1.maven.org/maven2/org/apache/nifi/nifi-hadoop-libraries-nar/2.3.0/nifi-hadoop-libraries-nar-2.3.0.nar
wget https://repo1.maven.org/maven2/org/apache/nifi/nifi-hadoop-nar/2.3.0/nifi-hadoop-nar-2.3.0.nar

# Copiar archivos al contenedor NiFi
docker cp nifi-hadoop-libraries-nar-2.3.0.nar nifi:/opt/nifi/nifi-current/lib
docker cp nifi-hadoop-nar-2.3.0.nar nifi:/opt/nifi/nifi-current/lib

# Reiniciar NiFi
docker restart nifi
```

### 3. Acceder a la Interfaz Web

**URL**: https://localhost:8443/nifi

**Obtener credenciales:**
```bash
# Linux
docker logs nifi | grep Generated

# Windows
docker logs nifi | findstr Generated
```

**Ejemplo de salida:**
```
Generated Username [5daf9eec-62d4-42cd-ad9c-acac425ee7f9]
Generated Password [2nYLm8aFtpszu+Ft0txirYOpxNGbrvXx]
```

**Cambiar contraseña (opcional):**
```bash
./bin/nifi.sh set-single-user-credentials <username> <password>
```

## Ejercicio: Procesar archivo starwars.csv

### Objetivo
Crear un flujo en NiFi que:
1. Ingiera el archivo `starwars.csv`
2. Lo convierta a formato `starwars.avro`
3. Lo guarde en HDFS en la carpeta `/nifi`

### Pasos del Flujo

#### 1. GetFile Processor
- **Función**: Monitorea un directorio y crea FlowFiles desde archivos nuevos o actualizados
- **Configuración**:
  - Input Directory: `/path/to/starwars.csv`
  - File Filter: `starwars.csv`
- **Conexión**: `success` → ConvertRecord

#### 2. ConvertRecord Processor
- **Función**: Convierte el contenido de un FlowFile de un formato de datos orientado a registros a otro
- **Configuración**:
  - Record Reader: CSV Reader
  - Record Writer: Avro Writer
- **Conexión**: `success` → UpdateAttribute

#### 3. UpdateAttribute Processor
- **Función**: Agrega, modifica o elimina atributos de FlowFile
- **Configuración**:
  - Agregar atributo: `filename` = `starwars.avro`
  - Agregar atributo: `path` = `/nifi/`
- **Conexión**: `success` → PutHDFS

#### 4. PutHDFS Processor
- **Función**: Escribe el contenido de un FlowFile a HDFS
- **Configuración**:
  - Hadoop Configuration Resources: `/opt/hadoop/etc/hadoop/core-site.xml`
  - Directory: `/nifi`
  - Conflict Resolution Strategy: `replace`
- **Conexión**: `success` → (fin del flujo)

### Configuración Detallada

#### GetFile Processor
```properties
Input Directory: /opt/nifi/input
File Filter: starwars.csv
Keep Source File: true
Recurse Subdirectories: false
```

#### ConvertRecord Processor
```properties
Record Reader: CSVReader
Record Writer: AvroRecordSetWriter
```

#### UpdateAttribute Processor
```properties
Add Property:
  - filename: starwars.avro
  - path: /nifi/
```

#### PutHDFS Processor
```properties
Hadoop Configuration Resources: /opt/hadoop/etc/hadoop/core-site.xml
Directory: /nifi
Conflict Resolution Strategy: replace
```

### Flujo Visual

El flujo se compone de los siguientes procesadores conectados en secuencia:

```
GetFile → ConvertRecord → UpdateAttribute → PutHDFS
```

Cada procesador tiene métricas que muestran:
- **Input/Output**: Número de registros procesados
- **Tasks/Time**: Tiempo de procesamiento
- **Queued**: Registros en cola

### Verificación de Resultados

1. **Verificar archivo en HDFS:**
```bash
hdfs dfs -ls /nifi/
hdfs dfs -cat /nifi/starwars.avro | head
```

2. **Verificar formato Avro:**
```bash
# Usar herramientas de Avro para verificar el formato
avro-tools tojson /nifi/starwars.avro | head
```

### Troubleshooting

#### Problemas Comunes

1. **Error de conexión HDFS:**
   - Verificar que Hadoop esté ejecutándose
   - Comprobar configuración de core-site.xml

2. **Error de formato CSV:**
   - Verificar que el archivo CSV tenga headers
   - Comprobar delimitadores y encoding

3. **Error de permisos:**
   - Verificar permisos de escritura en HDFS
   - Comprobar usuario de NiFi

#### Logs de NiFi
```bash
# Ver logs del contenedor
docker logs nifi

# Ver logs específicos de procesadores
# (desde la interfaz web de NiFi)
```

### Mejores Prácticas

1. **Monitoreo**: Revisar métricas de procesadores regularmente
2. **Backpressure**: Configurar límites de cola para evitar sobrecarga
3. **Error Handling**: Configurar rutas de error para procesadores críticos
4. **Logging**: Habilitar logging detallado para debugging
5. **Performance**: Usar múltiples mappers para archivos grandes

### Extensiones del Ejercicio

1. **Validación de datos**: Agregar procesador de validación
2. **Transformación**: Aplicar transformaciones de datos
3. **Particionado**: Dividir archivos por criterios específicos
4. **Compresión**: Aplicar compresión a los archivos de salida
