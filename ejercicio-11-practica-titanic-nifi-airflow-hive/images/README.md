# Imágenes - Ejercicio 11

Este directorio contiene todas las capturas de pantalla y diagramas relacionados con el Ejercicio 11 - Titanic con NiFi + Airflow + Hive.

## 📸 Capturas Requeridas

### Ejercicio 1: Script de Descarga
- `01_script_descarga.png` - Código del script ingest.sh
- `01_ejecucion_script.png` - Ejecución exitosa del script
- `01_archivo_descargado.png` - Verificación del archivo en /home/nifi/ingest

### Ejercicio 2: Preparación de Directorios
- `02_directorios_nifi.png` - Estructura de directorios en NiFi
- `02_core_site_xml.png` - Contenido de core-site.xml
- `02_hdfs_site_xml.png` - Contenido de hdfs-site.xml
- `02_directorio_hdfs.png` - Directorio /nifi en HDFS con permisos

### Ejercicio 3: NiFi GetFile (Origen)
- `03_getfile_config.png` - Configuración del procesador GetFile
- `03_getfile_properties.png` - Propiedades detalladas
- `03_getfile_running.png` - Procesador en ejecución

### Ejercicio 4: NiFi PutFile (Bucket)
- `04_putfile_config.png` - Configuración del procesador PutFile
- `04_putfile_properties.png` - Propiedades detalladas
- `04_archivo_bucket.png` - Archivo en /home/nifi/bucket

### Ejercicio 5: NiFi GetFile (Bucket)
- `05_getfile_bucket_config.png` - Configuración del segundo GetFile
- `05_getfile_bucket_properties.png` - Propiedades detalladas

### Ejercicio 6: NiFi PutHDFS
- `06_puthdfs_config.png` - Configuración del procesador PutHDFS
- `06_puthdfs_properties.png` - Propiedades detalladas
- `06_hadoop_config_resources.png` - Configuración de archivos Hadoop
- `06_archivo_hdfs.png` - Archivo en HDFS (/nifi/titanic.csv)
- `06_flujo_completo_nifi.png` - Flujo completo de NiFi ejecutándose

### Ejercicio 7: Pipeline Airflow
- `07_dag_code.png` - Código del DAG de Airflow
- `07_dag_ui.png` - DAG en la UI de Airflow
- `07_dag_graph.png` - Vista de grafo del DAG
- `07_dag_logs.png` - Logs de ejecución exitosa
- `07_transformaciones.png` - Logs mostrando transformaciones

### Ejercicio 8: Análisis Hive
- `08_tabla_hive.png` - Estructura de la tabla en Hive
- `08_count_registros.png` - COUNT(*) mostrando 891 registros
- `08_sobrevivientes_genero.png` - Resultado consulta sobrevivientes por género
- `08_sobrevivientes_clase.png` - Resultado consulta sobrevivientes por clase
- `08_mayor_edad.png` - Persona de mayor edad que sobrevivió
- `08_menor_edad.png` - Persona más joven que sobrevivió

### Diagramas Adicionales
- `arquitectura_completa.png` - Diagrama de arquitectura del pipeline completo
- `flujo_datos.png` - Diagrama de flujo de datos

## 📋 Checklist de Capturas

Usa esta checklist para asegurarte de tener todas las imágenes necesarias:

- [ ] Ejercicio 1 - Script de Descarga (3 imágenes)
- [ ] Ejercicio 2 - Preparación (4 imágenes)
- [ ] Ejercicio 3 - GetFile Origen (3 imágenes)
- [ ] Ejercicio 4 - PutFile Bucket (3 imágenes)
- [ ] Ejercicio 5 - GetFile Bucket (2 imágenes)
- [ ] Ejercicio 6 - PutHDFS (6 imágenes)
- [ ] Ejercicio 7 - Airflow (5 imágenes)
- [ ] Ejercicio 8 - Hive (6 imágenes)
- [ ] Diagramas (2 imágenes)

**Total**: ~34 imágenes

## 🎨 Recomendaciones para Capturas

### Herramientas
- **Windows**: Snipping Tool, Lightshot, ShareX
- **macOS**: Cmd + Shift + 4
- **Linux**: Flameshot, GNOME Screenshot

### Formato
- **Formato recomendado**: PNG (sin pérdida de calidad)
- **Resolución**: Al menos 1280x720
- **Tamaño máximo**: 5 MB por imagen

### Contenido
1. **Incluir contexto**: Muestra suficiente pantalla para entender el contexto
2. **Resaltar información importante**: Usa flechas o recuadros si es necesario
3. **Texto legible**: Asegúrate de que el texto sea legible en la captura
4. **Ocultar información sensible**: IPs internas, contraseñas, tokens

### Organización
```
images/
├── 01_ejercicio1/
│   ├── script_descarga.png
│   ├── ejecucion_script.png
│   └── archivo_descargado.png
├── 02_ejercicio2/
│   ├── directorios_nifi.png
│   ├── core_site_xml.png
│   ├── hdfs_site_xml.png
│   └── directorio_hdfs.png
├── 03_ejercicio3/
│   └── ...
└── diagramas/
    ├── arquitectura_completa.png
    └── flujo_datos.png
```

## 📝 Comando para Capturas desde Terminal

### Capturar terminal con colores

```bash
# Opción 1: Usar script command
script -c "comando" output.txt
# Luego convertir a imagen con herramientas como carbon.now.sh

# Opción 2: Usar ansi2html
comando | ansi2html > output.html
# Luego capturar el navegador
```

### Capturas de Hive

```bash
# Exportar resultados a archivo
hive -e "SELECT * FROM tabla LIMIT 10;" > resultado.txt

# Con formato bonito
hive --outputformat=table -e "SELECT * FROM tabla LIMIT 10;"
```

### Capturas de Airflow

Acceder directamente a las URLs específicas:
```
http://localhost:8080/dags/titanic_processing_dag/graph
http://localhost:8080/dags/titanic_processing_dag/grid
http://localhost:8080/log?dag_id=titanic_processing_dag&task_id=transform_and_load_hive
```

### Capturas de NiFi

Zoom recomendado: 75-100% para ver el flujo completo

## 🔗 Referencias en Documentación

Las imágenes deben ser referenciadas en `ejercicios-resueltos.md`:

```markdown
## Ejercicio 1

![Script de descarga](images/01_script_descarga.png)

![Ejecución del script](images/01_ejecucion_script.png)
```

## 📚 Herramientas de Diagramas

Para crear diagramas profesionales:

- [Draw.io](https://app.diagrams.net/) - Gratuito, online/offline
- [Lucidchart](https://www.lucidchart.com/) - Online, con plantillas
- [Excalidraw](https://excalidraw.com/) - Minimalista, hand-drawn style
- [Mermaid](https://mermaid.live/) - Diagramas desde texto
- [PlantUML](https://plantuml.com/) - UML desde texto

## 📐 Ejemplo de Diagrama Arquitectura

```
┌─────────────┐
│   AWS S3    │
│ titanic.csv │
└──────┬──────┘
       │ wget
       ▼
┌─────────────┐
│    NiFi     │
│  Container  │
└──────┬──────┘
       │ GetFile → PutFile → GetFile → PutHDFS
       ▼
┌─────────────┐
│    HDFS     │
│   /nifi/    │
└──────┬──────┘
       │ hdfs dfs
       ▼
┌─────────────┐
│   Airflow   │
│  + Pandas   │
└──────┬──────┘
       │ Transformaciones
       ▼
┌─────────────┐
│    Hive     │
│ titanic_db  │
└─────────────┘
```

---

**Última actualización**: 2025-11-20

