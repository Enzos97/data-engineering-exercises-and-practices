# 🧪 Testear en Hive - Ejercicio Final 1

## ✅ **Opción 1: Ejecutar Todas las Consultas (Automático)**

### Desde PowerShell (copiar archivo SQL):

```powershell
docker cp ejercicios-Finales/ejercicio-1/hive/queries_aviacion.sql edvai_hadoop:/home/hadoop/
```

### Desde dentro del contenedor:

```bash
# Entrar al contenedor
docker exec -it edvai_hadoop bash
su hadoop

# Ejecutar todas las consultas de una vez
hive -f /home/hadoop/queries_aviacion.sql
```

**Esto ejecutará automáticamente:**
- ✅ Verificación de carga
- ✅ Punto 5: Schema de tablas
- ✅ Punto 6: Vuelos dic 2021 - ene 2022
- ✅ Punto 7: Pasajeros Aerolíneas Argentinas
- ✅ Punto 8: Tablero con ciudades
- ✅ Punto 9: Top 10 aerolíneas
- ✅ Punto 10: Top 10 aeronaves desde Bs. As.
- ✅ Análisis adicionales

---

## ✅ **Opción 2: Ejecutar Consultas Manualmente (Interactivo)**

```bash
# Entrar a Hive
docker exec -it edvai_hadoop bash
su hadoop
hive
```

### 1️⃣ **Verificación Rápida**

```sql
USE aviacion;

-- Ver total de registros
SELECT COUNT(*) FROM aeropuerto_tabla;
-- Resultado esperado: ~143,000 registros

SELECT COUNT(*) FROM aeropuerto_detalles_tabla;
-- Resultado esperado: ~54 aeropuertos

-- Ver muestra
SELECT * FROM aeropuerto_tabla LIMIT 5;
```

---

### 2️⃣ **Punto 5: Ver Schema (Tipos de Datos)**

```sql
DESCRIBE aeropuerto_tabla;
```

**Deberías ver:**
```
fecha                   date
horautc                 string
clase_de_vuelo          string
clasificacion_de_vuelo  string
tipo_de_movimiento      string
aeropuerto              string
origen_destino          string
aerolinea_nombre        string
aeronave                string
pasajeros               int
```

---

### 3️⃣ **Punto 6: Vuelos Diciembre 2021 - Enero 2022**

```sql
SELECT COUNT(*) as total_vuelos
FROM aeropuerto_tabla
WHERE fecha BETWEEN '2021-12-01' AND '2022-01-31';
```

**Resultado esperado:** ~57,984 vuelos

---

### 4️⃣ **Punto 7: Pasajeros Aerolíneas Argentinas**

```sql
SELECT SUM(pasajeros) as total_pasajeros
FROM aeropuerto_tabla
WHERE aerolinea_nombre LIKE '%AEROLINEAS ARGENTINAS%'
  AND fecha BETWEEN '2021-01-01' AND '2022-06-30';
```

**Resultado esperado:** ~7,484,860 pasajeros

---

### 5️⃣ **Punto 8: Tablero de Vuelos (Top 10)**

```sql
SELECT 
    v.fecha, 
    v.horautc, 
    v.aeropuerto as codigo_salida, 
    a_salida.denominacion as ciudad_salida, 
    v.origen_destino as codigo_arribo, 
    a_arribo.denominacion as ciudad_arribo, 
    v.pasajeros
FROM aeropuerto_tabla v
LEFT JOIN aeropuerto_detalles_tabla a_salida 
    ON v.aeropuerto = a_salida.aeropuerto
LEFT JOIN aeropuerto_detalles_tabla a_arribo 
    ON v.origen_destino = a_arribo.aeropuerto
WHERE v.fecha BETWEEN '2022-01-01' AND '2022-06-30'
ORDER BY v.fecha DESC
LIMIT 10;
```

---

### 6️⃣ **Punto 9: Top 10 Aerolíneas**

```sql
SELECT 
    aerolinea_nombre, 
    SUM(pasajeros) as total_pasajeros
FROM aeropuerto_tabla
WHERE aerolinea_nombre IS NOT NULL 
  AND aerolinea_nombre != '0' 
GROUP BY aerolinea_nombre
ORDER BY total_pasajeros DESC
LIMIT 10;
```

**Resultado esperado (Top 3):**
1. AEROLINEAS ARGENTINAS SA - ~7.4M
2. JETSMART AIRLINES S.A. - ~1.5M
3. FB LÍNEAS AÉREAS - FLYBONDI - ~1.4M

---

### 7️⃣ **Punto 10: Top 10 Aeronaves desde Buenos Aires**

```sql
SELECT 
    v.aeronave, 
    COUNT(*) as cantidad_despegues
FROM aeropuerto_tabla v
JOIN aeropuerto_detalles_tabla d 
    ON v.aeropuerto = d.aeropuerto
WHERE (UPPER(d.provincia) LIKE '%BUENOS AIRES%' 
       OR UPPER(d.provincia) LIKE '%CAPITAL FEDERAL%')
  AND v.tipo_de_movimiento = 'Despegue'
  AND v.aeronave IS NOT NULL 
  AND v.aeronave != '0'
GROUP BY v.aeronave
ORDER BY cantidad_despegues DESC
LIMIT 10;
```

**Resultado esperado (Top 3):**
1. EMB-ERJ190100IGW - ~12,000 despegues
2. CE-150-L - ~8,000
3. CE-152 - ~8,000

---

## 🔍 **Consultas de Validación**

### Verificar que NO hay vuelos internacionales:

```sql
SELECT COUNT(*) as vuelos_internacionales
FROM aeropuerto_tabla
WHERE LOWER(clasificacion_de_vuelo) = 'internacional';
```

**Debe retornar:** `0` (porque los filtramos en el procesamiento)

---

### Ver distribución por tipo de movimiento:

```sql
SELECT 
    tipo_de_movimiento,
    COUNT(*) as total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM aeropuerto_tabla), 2) as porcentaje
FROM aeropuerto_tabla
GROUP BY tipo_de_movimiento
ORDER BY total DESC;
```

---

### Aeropuertos más activos:

```sql
SELECT 
    v.aeropuerto,
    d.denominacion,
    d.provincia,
    COUNT(*) as operaciones
FROM aeropuerto_tabla v
LEFT JOIN aeropuerto_detalles_tabla d 
    ON v.aeropuerto = d.aeropuerto
GROUP BY v.aeropuerto, d.denominacion, d.provincia
ORDER BY operaciones DESC
LIMIT 10;
```

---

## 📊 **Capturas para el Examen**

Para el examen, toma capturas de:

1. ✅ Resultado Punto 6 (count de vuelos)
2. ✅ Resultado Punto 7 (sum de pasajeros)
3. ✅ Resultado Punto 8 (tablero con ciudades)
4. ✅ Resultado Punto 9 (top 10 aerolíneas)
5. ✅ Resultado Punto 10 (top 10 aeronaves)
6. ✅ DESCRIBE de las tablas

---

## 🎯 **Salir de Hive**

```sql
exit;
```

---

**¡Listo para testear!** 🚀

Si alguna consulta falla o retorna 0 registros, avísame para revisar.

