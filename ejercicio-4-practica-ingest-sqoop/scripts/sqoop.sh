
---

## 2️⃣ `sqoop.sh`

```bash
#!/bin/bash
# sqoop.sh
# Script con comandos básicos de Sqoop para la práctica
# Autor: Enzo

# 1. Listar tablas
sqoop list-tables \
  --connect jdbc:postgresql://172.17.0.1:5432/northwind \
  --username postgres -P

# 2. Query simple (region)
sqoop eval \
  --connect jdbc:postgresql://172.17.0.1:5432/northwind \
  --username postgres -P \
  --query "select * from region limit 10"

# 3. Importar tabla completa
sqoop import \
  --connect "jdbc:postgresql://172.17.0.1:5432/northwind" \
  --username postgres -P \
  --table region \
  --m 1 \
  --target-dir /sqoop/ingest \
  --as-parquetfile \
  --delete-target-dir

# 4. Importar con WHERE (solo Southern)
sqoop import \
  --connect "jdbc:postgresql://172.17.0.1:5432/northwind" \
  --username postgres -P \
  --table region \
  --m 1 \
  --target-dir /sqoop/ingest/southern \
  --as-parquetfile \
  --where "region_description = 'Southern'" \
  --delete-target-dir

echo "✅ Ejercicios de Sqoop completados."
