# Conclusiones y Arquitectura Alternativa - Aviación Civil

## 📊 PUNTO 12: Conclusiones y Recomendaciones

### 12.1 Análisis de Resultados

#### Insights del Negocio

Basándose en los datos procesados de 143,000 vuelos domésticos argentinos (2021-2022), se obtuvieron los siguientes insights:

#### 1. **Concentración del Mercado Aéreo**

**Hallazgos:**
- **Aerolíneas Argentinas SA**: 7,484,860 pasajeros (70% del mercado)
- **JetSmart Airlines**: 1,511,650 pasajeros (14%)
- **Flybondi**: 1,482,473 pasajeros (14%)
- Top 3 concentran >95% del tráfico doméstico

**Análisis:**
- Existe un claro monopolio de Aerolíneas Argentinas en el mercado doméstico
- Las aerolíneas low-cost (Flybondi, JetSmart) representan una competencia emergente
- La concentración reduce opciones para pasajeros y puede afectar precios

**Recomendaciones:**
1. 📈 Incentivar entrada de nuevas aerolíneas para aumentar competencia
2. 🔍 Monitorear prácticas anticompetitivas o abuso de posición dominante
3. 💰 Evaluar subsidios a rutas no rentables para garantizar conectividad nacional
4. 🛫 Fomentar aerolíneas regionales para rutas interprovinciales directas

---

#### 2. **Patrones de Temporalidad (Punto 6)**

**Hallazgos:**
- **Diciembre 2021 - Enero 2022**: 57,984 vuelos (alta temporada)
- **Promedio diario**: ~475 vuelos/día
- **Picos**: Fines de semana largos, feriados, vacaciones de verano

**Análisis:**
- La temporada de verano (diciembre-febrero) concentra el mayor tráfico
- Existe estacionalidad marcada con baja demanda en otoño/invierno
- Los aeropuertos principales (AEP, EZE) operan cerca de capacidad en alta temporada

**Recomendaciones:**
1. 📅 Implementar precios dinámicos para distribuir demanda
2. 🏢 Ampliar capacidad de handling en aeropuertos principales
3. ⏰ Optimizar slots de despegue/aterrizaje en horas pico
4. 🎫 Campañas promocionales para temporada baja

---

#### 3. **Infraestructura Aeroportuaria**

**Hallazgos:**
- **Buenos Aires (AEP + EZE)**: >60% de todos los vuelos
- **Córdoba, Mendoza, Salta**: Hubs regionales secundarios
- **54 aeropuertos operativos**: Muchos con bajo tráfico

**Análisis:**
- Alta concentración en Buenos Aires genera cuellos de botella
- Aeropuertos provinciales subutilizados
- Falta conectividad directa entre provincias (sin pasar por CABA)

**Recomendaciones:**
1. ✈️ Desarrollar aeropuertos provinciales como hubs secundarios
2. 🛤️ Modernizar pistas en aeropuertos regionales (capacidad A320/B737)
3. 🔗 Promover rutas interprovinciales directas
4. 🌐 Integrar aeropuertos con transporte terrestre (buses, trenes)

---

#### 4. **Flota de Aeronaves (Punto 10)**

**Hallazgos:**
- **Top 3 aeronaves desde Buenos Aires**:
  1. EMB-ERJ190100IGW: 12,470 despegues (Embraer 190)
  2. CE-150-L: 8,117 despegues (Cessna Citation)
  3. CE-152: 7,980 despegues (Cessna 152 - aviación general)

**Análisis:**
- Predominan aeronaves de corto/medio alcance
- Alta presencia de aviación general (Cessna) en AEP
- Flota Embraer 190 (Aerolíneas) bien adaptada a mercado doméstico

**Recomendaciones:**
1. 🌱 Renovar flota con aeronaves más eficientes (A320neo, B737 MAX)
2. ⚡ Evaluar adopción de aeronaves eléctricas/híbridas para rutas cortas
3. 📊 Optimizar utilización de aeronaves (rotación, ocupación)
4. 🛠️ Invertir en centros de mantenimiento locales (reducir costos)

---

### 12.2 Calidad de Datos

#### Aspectos Positivos

✅ **Dataset robusto**: 143,000 registros de vuelos domésticos procesados  
✅ **Cobertura temporal completa**: 18 meses continuos (2021-2022)  
✅ **Integridad referencial**: JOIN exitoso entre vuelos y aeropuertos  
✅ **Granularidad temporal**: Fecha + Hora UTC para análisis detallado  
✅ **Información operativa**: Tipo de vuelo, movimiento, aerolínea, aeronave  

#### Aspectos a Mejorar

⚠️ **Valores nulos en pasajeros**: ~5% de registros (reemplazados con 0)  
⚠️ **Valores nulos en distancia_ref**: ~10% de registros  
⚠️ **Vuelos internacionales**: 67,941 registros excluidos (47.5% del total)  
⚠️ **Columnas innecesarias**: `inhab`, `fir`, `calidad del dato` eliminadas  
⚠️ **Normalización inconsistente**: Nombres con tildes, paréntesis, mayúsculas  
⚠️ **Falta información de ocupación**: No hay % de asientos ocupados  
⚠️ **Sin datos de puntualidad**: No hay información de retrasos  

#### Recomendaciones de Calidad de Datos

1. **Implementar validaciones en sistema origen (ANAC)**:
   ```sql
   -- Validar pasajeros NOT NULL y >= 0
   CHECK (pasajeros IS NOT NULL AND pasajeros >= 0)
   ```

2. **Agregar campos adicionales**:
   - `asientos_disponibles` (INT): Capacidad de la aeronave
   - `ocupacion_porcentaje` (FLOAT): pasajeros / asientos * 100
   - `retraso_minutos` (INT): Diferencia entre hora programada y real
   - `estado_vuelo` (STRING): Completado, Cancelado, Desviado

3. **Estandarizar nomenclatura**:
   - Códigos IATA/OACI en MAYÚSCULAS
   - Nombres de aerolíneas sin acentos
   - Formato fecha ISO 8601 (YYYY-MM-DD)

4. **Documentar diccionario de datos**:
   - Crear catálogo de datos con definiciones claras
   - Documentar fuente, frecuencia, responsables

---

### 12.3 Performance del Pipeline

#### Tiempos de Ejecución Observados

| Etapa | Tiempo | Registros |
|-------|--------|-----------|
| Descarga de archivos (S3 → Local) | 60-90 seg | 3 archivos (54 MB) |
| Ingesta a HDFS | 20-30 seg | 143k registros |
| Procesamiento PySpark | 5-8 min | Union + Transformaciones |
| Escritura a Hive | 40-60 seg | 2 tablas |
| **Total Pipeline** | **~10 min** | **143k registros** |

#### Consultas SQL (Hive)

| Consulta | Tiempo | Complejidad |
|----------|--------|-------------|
| Punto 6: COUNT con filtro fecha | 5-8 seg | Simple |
| Punto 7: SUM con filtro | 8-12 seg | Simple |
| Punto 8: JOIN + ORDER BY | 15-25 seg | Media |
| Punto 9: GROUP BY + ORDER BY | 12-18 seg | Media |
| Punto 10: JOIN + GROUP BY + filtros | 20-30 seg | Alta |

#### Optimizaciones Aplicadas

✅ **Union eficiente**: `unionByName()` para datasets con mismo schema  
✅ **Filtrado temprano**: Excluir vuelos internacionales antes de JOIN  
✅ **Normalización única**: Función `normalizar_nombre_columna()` reutilizable  
✅ **Select específico**: Solo columnas necesarias en df_final  
✅ **Broadcast**: Implícito para tabla aeropuertos (pequeña, 54 registros)  

#### Recomendaciones de Performance

##### 1. Particionar Tabla Hive por Mes/Año

```sql
CREATE TABLE aeropuerto_tabla (
    horaUTC STRING,
    clase_de_vuelo STRING,
    -- ... resto de columnas
    pasajeros INT
)
PARTITIONED BY (year INT, month INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Consultas serán más rápidas:
SELECT COUNT(*) FROM aeropuerto_tabla 
WHERE year = 2021 AND month = 12;
```

##### 2. Usar Formato Columnar (ORC o Parquet)

```python
# En process_aviacion_spark.py
df_vuelos_final.write \
    .mode("overwrite") \
    .format("orc") \
    .option("compression", "snappy") \
    .saveAsTable("aviacion.aeropuerto_tabla")
```

**Beneficio:** Reducción de 60-70% en tamaño y tiempo de lectura

##### 3. Crear Índices en Hive

```sql
-- Índice en fecha para consultas temporales
CREATE INDEX idx_fecha ON TABLE aeropuerto_tabla(fecha)
AS 'COMPACT' WITH DEFERRED REBUILD;

-- Índice en aerolínea para consultas por carrier
CREATE INDEX idx_aerolinea ON TABLE aeropuerto_tabla(aerolinea_nombre)
AS 'COMPACT' WITH DEFERRED REBUILD;
```

##### 4. Implementar Caché en Spark

```python
# En script PySpark para desarrollo/testing
df_vuelos = df_2021.unionByName(df_2022)
df_vuelos.cache()  # Mantener en memoria

# Realizar múltiples transformaciones
df_filtrado = df_vuelos.filter(...)
df_final = df_filtrado.select(...)
```

##### 5. Aumentar Paralelismo en Spark

```bash
# En spark-submit
spark-submit \
    --master yarn \
    --num-executors 4 \
    --executor-cores 2 \
    --executor-memory 4G \
    --driver-memory 2G \
    /home/hadoop/scripts/process_aviacion_spark.py
```

---

### 12.4 Arquitectura Actual - Evaluación

#### Fortalezas ✅

1. **Pipeline completo**: Cubre todo el ciclo ETL (Extract, Transform, Load)
2. **Orquestación**: Airflow permite scheduling y monitoreo
3. **Escalabilidad**: Spark distribuye procesamiento
4. **Persistencia**: Hive como DW centralizado
5. **Código versionado**: Scripts en Git
6. **Automatización**: Sin intervención manual

#### Debilidades ❌

1. **Single point of failure**: Cluster de 1 nodo (no HA)
2. **Sin monitoreo**: No hay alertas de fallos
3. **Sin backup**: Datos solo en HDFS local
4. **Sin versionado de datos**: No hay snapshots históricos
5. **CI/CD manual**: Deployment manual de scripts
6. **Testing limitado**: Sin tests unitarios/integración

---

## 🏗️ PUNTO 13: Arquitectura Alternativa

### Opción 1: Cloud AWS (Recomendada para Escala)

#### Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────┐
│                    CAPA DE INGESTA                        │
├──────────────────────────────────────────────────────────┤
│  ANAC Sistema  →  Lambda  →  S3 Raw  →  EventBridge      │
│  (CSV export)     (trigger)   (bucket)    (schedule)     │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│                  CAPA DE PROCESAMIENTO                    │
├──────────────────────────────────────────────────────────┤
│  AWS Glue ETL (PySpark)                                  │
│  • Normalize columns                                      │
│  • Filter international flights                           │
│  • Union 2021 + 2022                                      │
│  • Transform dates                                        │
│  • Join flights + airports                               │
│  └──→ S3 Processed (Parquet)                             │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│                  CAPA DE ALMACENAMIENTO                   │
├──────────────────────────────────────────────────────────┤
│  Amazon Redshift (DW)  ←  Glue Data Catalog              │
│  • aeropuerto_tabla                                       │
│  • aeropuerto_detalles_tabla                             │
│                                                           │
│  Alternativa: Athena (serverless SQL sobre S3)          │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│                  CAPA DE ANÁLISIS                         │
├──────────────────────────────────────────────────────────┤
│  Amazon QuickSight (BI)                                   │
│  • Dashboards de Vuelos                                  │
│  • Top Aerolíneas                                         │
│  • Análisis Temporal                                      │
│  • Reportes Ejecutivos                                    │
└──────────────────────────────────────────────────────────┘

         ┌───────────────────────────────┐
         │   ORQUESTACIÓN: Step Functions│
         │   o MWAA (Managed Airflow)    │
         └───────────────────────────────┘

         ┌───────────────────────────────┐
         │   MONITOREO: CloudWatch       │
         │   • Logs  • Métricas  • Alertas│
         └───────────────────────────────┘
```

#### Stack Tecnológico Detallado

| Componente | Servicio AWS | Justificación |
|------------|--------------|---------------|
| **Almacenamiento Raw** | S3 Standard | Durabilidad 99.999999999%, bajo costo |
| **ETL** | AWS Glue | Spark managed, pago por uso, auto-scaling |
| **Orquestación** | MWAA (Airflow) | Compatible con DAGs actuales |
| **Data Warehouse** | Redshift o Athena | Redshift: OLAP rápido, Athena: serverless |
| **Catálogo de Datos** | Glue Data Catalog | Metastore centralizado (Hive compatible) |
| **BI** | QuickSight | Nativo AWS, integración directa |
| **Monitoreo** | CloudWatch | Logs, métricas, alertas integradas |
| **Seguridad** | IAM + KMS | Permisos granulares, cifrado at rest/transit |
| **Backup** | S3 Glacier | Retención larga, cumplimiento normativo |

#### Ventajas ✅

1. **Escalabilidad**: Auto-scaling según volumen de datos
2. **Alta Disponibilidad**: SLA 99.99% (multi-AZ)
3. **Pago por uso**: OPEX variable (sin CAPEX inicial)
4. **Managed Services**: AWS gestiona infraestructura
5. **Integración nativa**: Servicios se comunican sin glue code
6. **Seguridad**: Compliance (SOC2, ISO 27001)
7. **Backup automático**: S3 versionado + Glacier
8. **Disaster Recovery**: Multi-región disponible

#### Desventajas ❌

1. **Vendor lock-in**: Difícil migrar a otra plataforma
2. **Costo variable**: Difícil presupuestar (puede escalar mucho)
3. **Curva de aprendizaje**: Equipo debe aprender AWS
4. **Latencia de red**: Datos en cloud (vs on-premise)
5. **Cumplimiento normativo**: Datos sensibles fuera del país
6. **Dependencia de internet**: Sin conexión = sin acceso

#### Estimación de Costos Mensuales

| Servicio | Uso | Costo USD/mes |
|----------|-----|---------------|
| S3 Standard (raw) | 10 GB | $0.23 |
| S3 Standard (processed) | 5 GB (Parquet) | $0.12 |
| AWS Glue ETL | 10 DPU-hours/mes | $44.00 |
| MWAA (Airflow) | Small environment | $315.00 |
| Redshift (dc2.large) | 730 hours | $180.00 |
| QuickSight (Enterprise) | 5 usuarios | $90.00 |
| CloudWatch | Logs + Metrics | $15.00 |
| **TOTAL MENSUAL** | | **~$650** |

**Alternativa Serverless (Athena + Step Functions):** ~$250/mes

---

### Opción 2: Cloud GCP (Alternativa Competitiva)

#### Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────┐
│  Cloud Storage  →  Dataproc (Spark)  →  BigQuery         │
│  (CSV raw)         (ETL)                  (DW)            │
└────────────────────────┬─────────────────────────────────┘
                         │
                  Cloud Composer
                   (Airflow)
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│  Looker Studio / Data Studio (BI)                        │
└──────────────────────────────────────────────────────────┘
```

#### Stack Tecnológico

- **Almacenamiento**: Cloud Storage (equivalente a S3)
- **ETL**: Dataproc (Spark managed) o Dataflow (streaming)
- **Orquestación**: Cloud Composer (Airflow managed)
- **DW**: BigQuery (columnar, serverless, extremadamente rápido)
- **BI**: Looker Studio (gratis) o Looker (premium)
- **Monitoreo**: Cloud Logging + Cloud Monitoring

#### Ventajas ✅

1. **BigQuery**: Consultas extremadamente rápidas (SQL estándar)
2. **Costo predecible**: Pricing más transparente que AWS
3. **ML integrado**: BigQuery ML para modelos predictivos
4. **Looker Studio**: BI gratuito con buena UI
5. **Simplicidad**: Menos servicios, más integrados

#### Costo Estimado: **~$400-500/mes**

---

### Opción 3: On-Premise Mejorado (Alta Disponibilidad)

#### Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────┐
│                  CLUSTER HADOOP (3 NODOS)                 │
├──────────────────────────────────────────────────────────┤
│  Master:       NameNode + ResourceManager + HiveServer    │
│  Worker 1-2:   DataNode + NodeManager + Spark             │
│  Replication:  HDFS factor 3 (tolerancia a fallos)       │
└────────────────────────┬─────────────────────────────────┘
                         │
┌────────────────────────┴─────────────────────────────────┐
│             SERVICIOS ADICIONALES                         │
├──────────────────────────────────────────────────────────┤
│  • Airflow (orquestación) - VM dedicada                  │
│  • NiFi (ingest) - VM dedicada                           │
│  • Superset (BI) - VM dedicada                           │
│  • PostgreSQL (metastore Hive + Airflow DB)              │
└────────────────────────┬─────────────────────────────────┘
                         │
┌────────────────────────┴─────────────────────────────────┐
│             MONITOREO Y SEGURIDAD                         │
├──────────────────────────────────────────────────────────┤
│  • Prometheus + Grafana (métricas)                       │
│  • ELK Stack (logs centralizados)                        │
│  • Kerberos (autenticación)                              │
│  • Apache Ranger (autorización)                          │
│  • Apache Atlas (lineage + catálogo)                     │
└──────────────────────────────────────────────────────────┘

         ┌───────────────────────────────┐
         │   BACKUP: Rsync a NAS         │
         │   + S3 Glacier (offsite)      │
         └───────────────────────────────┘
```

#### Hardware Requerido (Cluster 3 Nodos)

| Componente | Especificación | Cantidad | Costo Unitario | Total |
|------------|---------------|----------|----------------|-------|
| **Servidor Master** | 32GB RAM, 8 cores, 2TB SSD | 1 | $4,000 | $4,000 |
| **Servidor Worker** | 64GB RAM, 16 cores, 4TB SSD | 2 | $6,000 | $12,000 |
| **Switch 10GbE** | 24 puertos | 1 | $1,500 | $1,500 |
| **UPS** | 3KVA | 1 | $1,000 | $1,000 |
| **NAS Backup** | 20TB RAID 6 | 1 | $3,500 | $3,500 |
| **Rack + Cableado** | 42U | 1 | $1,500 | $1,500 |
| **Software Licenses** | Red Hat Enterprise Linux | 3 | $800/año | $2,400 |
| **CAPEX TOTAL** | | | | **$25,900** |

#### Costos Operativos (OPEX Anual)

| Item | Costo Anual |
|------|-------------|
| Electricidad (1.5KW x 24h x 365d x $0.15/KWh) | $1,971 |
| Conectividad (dedicada 100Mbps) | $3,600 |
| Salarios (DevOps + SysAdmin part-time 50%) | $24,000 |
| Mantenimiento hardware (5% CAPEX) | $1,295 |
| Licencias software (RHEL + monitoring) | $3,000 |
| **OPEX TOTAL** | **$33,866/año** |

**Costo mensual equivalente:** ~$2,822/mes

#### Ventajas ✅

1. **Control total**: Sobre datos, infraestructura, software
2. **Cumplimiento normativo**: Datos en territorio argentino
3. **Costo fijo**: Presupuesto predecible (post-CAPEX)
4. **Baja latencia**: Red local (< 1ms)
5. **Privacidad**: Datos sensibles no salen del datacenter
6. **Personalización**: Stack tecnológico a medida

#### Desventajas ❌

1. **CAPEX alto**: $26k inversión inicial
2. **Escalabilidad limitada**: Por hardware físico
3. **Requiere equipo dedicado**: DevOps, SysAdmin, Networking
4. **Single datacenter**: DR requiere segundo site
5. **Mantenimiento**: Hardware, software, seguridad
6. **Obsolescencia**: Hardware deprecia en 3-5 años

---

### Opción 4: Arquitectura Híbrida (Recomendada para ANAC)

#### Diagrama de Arquitectura Híbrida

```
┌──────────────────────────────────────────────────────────┐
│                  ON-PREMISE (PRODUCCIÓN)                  │
├──────────────────────────────────────────────────────────┤
│  Cluster Hadoop (3 nodos)                                │
│  • Datos operativos                                       │
│  • ETL crítico                                            │
│  • Hive DW (datos sensibles)                             │
└────────────────────────┬─────────────────────────────────┘
                         │
                         │ VPN Site-to-Site
                         │ (cifrado IPSec)
                         ▼
┌──────────────────────────────────────────────────────────┐
│                    CLOUD (AWS/GCP)                        │
├──────────────────────────────────────────────────────────┤
│  • S3 Glacier (backup long-term, inmutable)              │
│  • Athena (consultas ad-hoc para público)                │
│  • QuickSight (dashboards públicos ANAC)                 │
│  • SageMaker (ML/forecasting experimental)               │
└──────────────────────────────────────────────────────────┘
```

#### Distribución de Responsabilidades

| Componente | On-Premise | Cloud |
|------------|------------|-------|
| **Datos sensibles (vuelos completos)** | ✅ Hive DW | ❌ |
| **Datos públicos (agregados)** | ✅ Hive | ✅ Athena |
| **ETL crítico** | ✅ Spark | ❌ |
| **Backup long-term (7+ años)** | ⚠️ NAS (1 año) | ✅ S3 Glacier |
| **BI interno (ANAC staff)** | ✅ Superset | ❌ |
| **BI público (ciudadanos)** | ❌ | ✅ QuickSight |
| **ML/Forecasting** | ❌ | ✅ SageMaker |
| **Disaster Recovery** | ❌ | ✅ EC2 standby |

#### Ventajas de Arquitectura Híbrida ✅

1. **Soberanía de datos**: Datos sensibles on-premise (cumplimiento normativo)
2. **Mejor de ambos mundos**: Control local + flexibilidad cloud
3. **Costo optimizado**: CAPEX on-premise + OPEX cloud variable
4. **Escalabilidad selectiva**: Solo cloud para cargas variables (ML, backups)
5. **DR económico**: Cloud como sitio de recuperación (activo solo en desastre)
6. **Transparencia pública**: Dashboards cloud accesibles sin VPN

#### Costos de Arquitectura Híbrida

| Componente | Costo Anual |
|------------|-------------|
| **On-Premise** (CAPEX amortizado 5 años + OPEX) | $39,046 |
| **Cloud** (Backup S3 Glacier + Athena + QuickSight) | $3,600 |
| **VPN Site-to-Site** | $1,200 |
| **TOTAL ANUAL** | **$43,846** |

**Costo mensual equivalente:** ~$3,654/mes

---

## 🏆 Recomendación Final para ANAC

### ✅ Opción Recomendada: **Arquitectura Híbrida**

#### Justificación

1. **Cumplimiento Normativo** ✅
   - Datos sensibles (DNI pasajeros, rutas estratégicas) permanecen en Argentina
   - Cumple Ley de Protección de Datos Personales (Ley 25.326)
   - Auditorías gubernamentales más simples (infraestructura local)

2. **Presupuesto Gubernamental** ✅
   - CAPEX inicial más fácil de aprobar (inversión con vida útil 5 años)
   - OPEX variable cloud solo para servicios no críticos
   - Costo total predecible para presupuestos plurianuales

3. **Soberanía Tecnológica** ✅
   - Know-how queda en equipo local (no depende 100% de proveedor cloud)
   - Puede cambiar proveedor cloud (backup) sin afectar operación principal
   - Datos estratégicos bajo control nacional

4. **Escalabilidad Pragmática** ✅
   - On-premise para cargas estables (ETL diario)
   - Cloud para cargas variables (ML, análisis ad-hoc, picos de tráfico web)

5. **Transparencia Ciudadana** ✅
   - Dashboards públicos en cloud (QuickSight) sin exponer infraestructura interna
   - Cumple mandatos de Gobierno Abierto (datos.gob.ar)

#### Roadmap de Implementación (12 meses)

**Fase 1 (Meses 1-3): Infraestructura On-Premise**
- ✅ Adquisición hardware (licitación pública)
- ✅ Instalación cluster Hadoop 3 nodos
- ✅ Migración pipeline actual → cluster nuevo
- ✅ Configuración Kerberos + Ranger (seguridad)

**Fase 2 (Meses 4-6): Servicios Cloud**
- ✅ Configurar cuenta AWS GovCloud o región Sao Paulo (latencia)
- ✅ Setup VPN Site-to-Site (cifrado IPSec)
- ✅ Configurar S3 Glacier para backups
- ✅ Implementar job backup diario automático

**Fase 3 (Meses 7-9): BI Público**
- ✅ Publicar datos agregados en S3 (sin info sensible)
- ✅ Configurar Athena para consultas públicas
- ✅ Crear dashboards QuickSight (datos.gob.ar integration)
- ✅ Campañas de difusión (transparencia)

**Fase 4 (Meses 10-12): ML & Optimización**
- ✅ Proof of Concept: Forecasting demanda con SageMaker
- ✅ Optimización costos cloud (Reserved Instances)
- ✅ Documentación completa
- ✅ Training equipo ANAC

---

## 📈 Métricas de Éxito

### KPIs Técnicos

| Métrica | Baseline Actual | Target (6 meses) |
|---------|-----------------|------------------|
| Tiempo pipeline completo | 10 min | 5 min |
| Uptime cluster | N/A (single node) | 99.9% |
| Tiempo consulta promedio | 15 seg | 5 seg |
| Backup RPO (Recovery Point) | N/A | 24 horas |
| Backup RTO (Recovery Time) | N/A | 4 horas |

### KPIs de Negocio

| Métrica | Baseline | Target (12 meses) |
|---------|----------|-------------------|
| Reportes generados/mes | Manual | 50+ automáticos |
| Usuarios BI (staff ANAC) | 0 | 20 usuarios |
| Consultas públicas/mes (datos.gob.ar) | 0 | 1,000+ |
| Datos históricos disponibles | 18 meses | 5 años |
| Alertas operacionales | 0 | 10 configuradas |

---

## 📚 Referencias

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Framework](https://cloud.google.com/architecture/framework)
- [Cloudera Enterprise Reference Architecture](https://www.cloudera.com/products/cloudera-data-platform.html)
- [ANAC - Datos Abiertos](https://www.argentina.gob.ar/anac)
- [Ley 25.326 - Protección Datos Personales](http://servicios.infoleg.gob.ar/infolegInternet/anexos/60000-64999/64790/norma.htm)

---

**Documento elaborado por:** Data Engineering Team - Edvai  
**Fecha:** 2025-11-24  
**Versión:** 1.0  
**Cliente:** Administración Nacional de Aviación Civil (ANAC)

