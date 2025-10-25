# Diagrama de Flujo NiFi - Procesamiento de starwars.csv

## Descripción del Flujo

El siguiente diagrama muestra el flujo de procesamiento en NiFi para convertir el archivo `starwars.csv` a formato `starwars.avro` y almacenarlo en HDFS.

![Diagrama de Flujo NiFi](images/nifi-flow-diagram.jpg)

## Componentes del Flujo

### 1. GetFile Processor
- **Función**: Monitorea un directorio y crea FlowFiles desde archivos nuevos o actualizados
- **Estado**: Running (indicado por el cuadrado verde)
- **Métricas**: 0 (0 bytes) - Procesador inactivo esperando archivos
- **Conexión**: `success` → ConvertRecord

### 2. ConvertRecord Processor  
- **Función**: Convierte el contenido de un FlowFile de CSV a formato Avro
- **Estado**: Running
- **Métricas**: 0 (0 bytes) - Procesador inactivo
- **Conexión**: `success` → UpdateAttribute

### 3. UpdateAttribute Processor
- **Función**: Agrega, modifica o elimina atributos de FlowFile
- **Estado**: Running  
- **Métricas**: 0 (0 bytes) - Procesador inactivo
- **Conexión**: `success` → PutHDFS

### 4. PutHDFS Processor
- **Función**: Escribe el contenido de un FlowFile a HDFS
- **Estado**: Running
- **Métricas**: 0 (0 bytes) - Procesador inactivo
- **Conexión**: `success` → (fin del flujo)

## Interpretación de Métricas

Todas las métricas muestran `0 (0 bytes)` porque:
- Los procesadores están en estado **idle** (inactivo)
- No hay archivos siendo procesados actualmente
- El flujo está listo para procesar cuando llegue el archivo `starwars.csv`

### Métricas Explicadas:
- **Input/Output**: Número de registros procesados
- **Tasks/Time**: Tiempo de procesamiento (00:00:00.000)
- **Queued**: Registros en cola (0 bytes)

## Flujo de Datos

```
starwars.csv → GetFile → ConvertRecord → UpdateAttribute → PutHDFS → /nifi/starwars.avro
```

### Pasos del Procesamiento:

1. **GetFile**: Detecta y lee el archivo `starwars.csv`
2. **ConvertRecord**: Convierte CSV a formato Avro
3. **UpdateAttribute**: Establece atributos como nombre de archivo y ruta
4. **PutHDFS**: Guarda el archivo Avro en HDFS en la carpeta `/nifi`

## Configuración de Procesadores

### GetFile Processor
```properties
Input Directory: /opt/nifi/input
File Filter: starwars.csv
Keep Source File: true
```

### ConvertRecord Processor
```properties
Record Reader: CSVReader
Record Writer: AvroRecordSetWriter
```

### UpdateAttribute Processor
```properties
Add Property:
  - filename: starwars.avro
  - path: /nifi/
```

### PutHDFS Processor
```properties
Hadoop Configuration Resources: /opt/hadoop/etc/hadoop/core-site.xml
Directory: /nifi
Conflict Resolution Strategy: replace
```

## Verificación del Proceso

Una vez que el flujo procese el archivo, las métricas cambiarán mostrando:
- Número de registros procesados
- Tiempo de procesamiento
- Bytes transferidos

Para verificar el resultado:
```bash
# Listar archivos en HDFS
hdfs dfs -ls /nifi/

# Verificar el archivo Avro generado
hdfs dfs -ls /nifi/starwars.avro
```
