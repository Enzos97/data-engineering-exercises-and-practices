# Scripts - Car Rental Analytics

Este directorio contiene los scripts de descarga y procesamiento de datos.

## 📄 Archivos

### `download_data.sh`
Script bash para descargar archivos desde S3 y subirlos a HDFS.

**Uso:**
```bash
bash /home/hadoop/scripts/download_data.sh
```

**Funciones:**
- Descarga `CarRentalData.csv` desde S3
- Descarga `georef-united-states-of-america-state.csv` (con wget -O para renombrar)
- Crea directorio en HDFS: `/car_rental/raw/`
- Sube ambos archivos a HDFS
- Limpia archivos temporales locales

---

### `process_car_rental.py`
Script PySpark para aplicar todas las transformaciones del Punto 3.

**Uso:**
```bash
spark-submit /home/hadoop/scripts/process_car_rental.py
```

**Transformaciones:**
1. Lee archivos desde HDFS
2. Renombra columnas (quita espacios y puntos)
3. Redondea y castea `rating` a INT
4. Hace JOIN entre car_rental y georef_usa_states
5. Elimina registros con rating nulo
6. Convierte `fuelType` a minúsculas
7. Excluye estado de Texas
8. Inserta datos en Hive: `car_rental_db.car_rental_analytics`

---

## 🔧 Requisitos

- Apache Spark 3.x
- Apache Hive configurado
- HDFS corriendo
- Python 3.x

---

## ✅ Verificación

```bash
# Verificar archivos en HDFS
hdfs dfs -ls -h /car_rental/raw/

# Verificar datos en Hive
hive -e "USE car_rental_db; SELECT COUNT(*) FROM car_rental_analytics;"
```

