# Hive - Car Rental Analytics

Este directorio contiene los scripts SQL para Hive.

## 📄 Archivos

### `car_rental_setup.sql`
Script para crear la base de datos y tabla en Hive (Punto 1).

**Uso:**
```bash
hive -f /home/hadoop/hive/car_rental_setup.sql
```

**Schema de la tabla:**
```sql
fuelType         STRING
rating           INT
renterTripsTaken INT
reviewCount      INT
city             STRING
state_name       STRING
owner_id         INT
rate_daily       INT
make             STRING
model            STRING
year             INT
```

---

### `queries.sql`
Consultas de negocio para análisis (Punto 5).

**Consultas incluidas:**

- **5a**: Alquileres ecológicos con rating >= 4
- **5b**: 5 estados con menor cantidad de alquileres
- **5c**: 10 modelos más rentados (con marca)
- **5d**: Alquileres por año (2010-2015)
- **5e**: 5 ciudades con más alquileres ecológicos
- **5f**: Promedio de reviews por tipo de combustible

**Uso:**
```bash
# Ejecutar todas las consultas
hive -f /home/hadoop/hive/queries.sql

# Ejecutar consulta específica
hive -e "USE car_rental_db; SELECT COUNT(*) FROM car_rental_analytics WHERE (fuelType = 'hybrid' OR fuelType = 'electric') AND rating >= 4;"
```

---

## 🔍 Consultas Útiles

```bash
# Ver estructura de tabla
hive -e "USE car_rental_db; DESCRIBE car_rental_analytics;"

# Contar registros
hive -e "USE car_rental_db; SELECT COUNT(*) FROM car_rental_analytics;"

# Ver distribución por fuelType
hive -e "USE car_rental_db; SELECT fuelType, COUNT(*) FROM car_rental_analytics GROUP BY fuelType;"

# Ver estados únicos
hive -e "USE car_rental_db; SELECT COUNT(DISTINCT state_name) FROM car_rental_analytics;"
```

---

## ✅ Verificación

```bash
# Verificar que Texas fue excluido (debe retornar 0)
hive -e "USE car_rental_db; SELECT COUNT(*) FROM car_rental_analytics WHERE state_name = 'Texas';"

# Verificar que no hay rating nulos (debe retornar 0)
hive -e "USE car_rental_db; SELECT COUNT(*) FROM car_rental_analytics WHERE rating IS NULL;"
```

