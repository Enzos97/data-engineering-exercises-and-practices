# 📊 Guía Completa: Looker Studio Paso a Paso (15 minutos)

## 🎯

✅ Exportar datos desde Hive a CSV (automático con script)  
✅ Subir CSVs a Google Sheets  
✅ Crear visualizaciones profesionales en Looker Studio  
✅ Tener dashboards completos de ambos ejercicios  

**Tiempo total:** 15-20 minutos por ejercicio

---

## 📋 Prerrequisitos

- ✅ Cuenta de Gmail (gratuita)
- ✅ Datos de ejercicios 1 y 2 cargados en Hive
- ✅ Contenedor Docker corriendo

---

## 🚀 PARTE 1: Exportar Datos desde Hive (5 minutos)

### Paso 1.1: Copiar script al contenedor

```powershell
# En PowerShell (Windows)
cd C:\Users\enz_9\OneDrive\Desktop\EDVai\data-engineering-exercises-and-practices\ejercicios-Finales

# Copiar script
docker cp scripts/export_para_looker.sh edvai_hadoop:/home/hadoop/scripts/
```

### Paso 1.2: Ejecutar script de exportación

```bash
# Entrar al contenedor
docker exec -it edvai_hadoop bash

# Cambiar a usuario hadoop
su hadoop

# Dar permisos y ejecutar
chmod +x /home/hadoop/scripts/export_para_looker.sh
/home/hadoop/scripts/export_para_looker.sh
```

**Salida esperada:**
```
╔════════════════════════════════════════════════╗
║  📊 EXPORTACIÓN PARA LOOKER STUDIO            ║
║  Datos listos para Google Sheets              ║
╚════════════════════════════════════════════════╝

✈️  EJERCICIO 1 - AVIACIÓN CIVIL
📊 1/6 - Exportando: Total de vuelos (Punto 6)...
   ✅ ej1_total_vuelos.csv
...
✅ EXPORTACIÓN COMPLETADA
```

### Paso 1.3: Copiar archivos a Windows

```powershell
# En PowerShell (Windows)
mkdir C:\Users\enz_9\Desktop\looker_exports

# Copiar todos los archivos
docker cp edvai_hadoop:/tmp/looker_exports C:\Users\enz_9\Desktop\
```

**Verifica que tienes estos archivos:**
```
C:\Users\enz_9\Desktop\looker_exports\
├── ej1_top10_aerolineas.csv
├── ej1_top10_aeronaves.csv
├── ej2_estados_baja_demanda.csv
├── ej2_top10_modelos.csv
├── ej2_alquileres_por_anio.csv
├── ej2_top5_ciudades_ecologicas.csv
```

---

## 📤 PARTE 2: Subir CSVs a Google Sheets (3 minutos)

### Paso 2.1: Crear Google Sheet para Ejercicio 1

1. **Ir a:** [Google Sheets](https://sheets.google.com)
2. **Crear:** Nueva hoja de cálculo en blanco
3. **Título:** `Ejercicio 1 - Datos Aviación`

### Paso 2.2: Importar primer CSV (Total Vuelos)

1. **Archivo** → **Importar** → **Subir**
2. Arrastrar archivo: `ej1_total_vuelos.csv`
3. **Configurar importación:**
   - Ubicación: **Crear nueva hoja**
   - Tipo separador: **Coma**
   - Convertir texto a números: ✅ **Sí**
4. **Importar datos**
5. **Renombrar hoja:** Clic derecho en la pestaña → Renombrar → `Total_Vuelos`

### Paso 2.3: Importar los demás CSVs del Ejercicio 1

Repetir el proceso para cada archivo, pero seleccionando **"Insertar nueva hoja"**:

| Archivo CSV | Nombre de Hoja |
|-------------|----------------|
| `ej1_top10_aerolineas.csv` | `Top10_Aerolineas` |
| `ej1_top10_aeronaves.csv` | `Top10_Aeronaves` |

**Resultado:** 1 Google Sheet con 2 pestañas

### Paso 2.4: Crear Google Sheet para Ejercicio 2

1. **Crear otra hoja nueva**
2. **Título:** `Ejercicio 2 - Datos Car Rental`
3. Importar los 4 CSVs del ejercicio 2:

| Archivo CSV | Nombre de Hoja |
|-------------|----------------|
| `ej2_estados_baja_demanda.csv` | `Estados_Baja_Demanda` |
| `ej2_top10_modelos.csv` | `Top10_Modelos` |
| `ej2_alquileres_por_anio.csv` | `Alquileres_Anio` |
| `ej2_top5_ciudades_ecologicas.csv` | `Ciudades_Ecologicas` |

---

## 🎨 PARTE 3: Crear Dashboard en Looker Studio (7 minutos)

### Paso 3.1: Crear nuevo informe

1. **Ir a:** [Looker Studio](https://lookerstudio.google.com)
2. **Crear** → **Informe**
3. Cuando pregunte por fuente de datos, seleccionar **Google Sheets**
4. Buscar y seleccionar: `Ejercicio 1 - Datos Aviación`
5. Seleccionar hoja: `Top10_Aerolineas`
6. **Agregar**

### Paso 3.2: Diseñar el lienzo

1. **Tamaño del lienzo:** Tema → Diseño actual → **Tamaño fijo (1200x900)**
2. **Fondo:** Blanco o gris claro (#F9FAFB)

### Paso 3.3: Agregar título principal

1. **Insertar** → **Texto**
2. Escribir: `Análisis de Aviación Civil Argentina`
3. **Estilo:**
   - Fuente: **Roboto Bold**
   - Tamaño: **32**
   - Color: Azul oscuro (#1E3A8A)
   - Alineación: Centro
4. Posicionar en la parte superior

### Paso 3.4: Crear Gráfico de Barras - Top 10 Aerolíneas

1. **Insertar** → **Gráfico de barras**
2. Cambiar fuente: Hoja `Top10_Aerolineas`
3. **Configuración:**
   - Dimensión: `Aerolinea`
   - Métrica: `Total_Pasajeros`
   - Ordenar: **Descendente** por `Total_Pasajeros`
   - Número de filas: **10**
4. **Estilo:**
   - Serie de barras:
     - Color: Azul (#2563EB)
     - Mostrar etiquetas de datos: ✅ Activado
     - Etiquetas compactas: ✅ Activado
   - Eje X:
     - Título: `Pasajeros Transportados`
   - Eje Y:
     - Título: `Aerolínea`
   - Título del gráfico: `Top 10 Aerolíneas por Pasajeros`
5. **Redimensionar:** Ancho completo, debajo de los KPIs

### Paso 3.5: Crear Gráfico de Barras - Top 10 Aeronaves

1. **Insertar** → **Gráfico de barras** (vertical esta vez)
2. Cambiar fuente: Hoja `Top10_Aeronaves`
3. **Configuración:**
   - Dimensión: `Aeronave`
   - Métrica: `Cantidad_Despegues`
   - Ordenar: **Descendente**
4. **Estilo:**
   - Color: Azul oscuro (#1E3A8A)
   - Mostrar etiquetas: ✅
   - Rotar etiquetas del eje X: **45°** (para que se lean mejor)
   - Título: `Top 10 Aeronaves - Despegues desde Buenos Aires`
5. **Posicionar:** Debajo del gráfico anterior

### Paso 3.7: Agregar anotaciones (opcional pero recomendado)

1. **Insertar** → **Cuadro de texto**
2. Escribir insights clave:
```
📊 INSIGHTS PRINCIPALES:
• Aerolíneas Argentinas domina con 70% del mercado
• 57,984 vuelos en período dic 2021 - ene 2022
• EMB-ERJ190100IGW es la aeronave más utilizada
```
3. **Estilo:**
   - Fuente: Roboto Regular, 14pt
   - Fondo: Amarillo claro (#FEF3C7)
   - Borde: Naranja (#F59E0B)

---

## 📸 PARTE 4: Capturar y Exportar (2 minutos)

### Paso 4.1: Tomar capturas de pantalla

1. **Ver** → **Modo de presentación**
2. Capturar pantalla completa: `Win + Shift + S` (Windows)
3. Guardar como:
   ```
   C:\Users\enz_9\Desktop\EDVai\ejercicios-Finales\ejercicio-1\visualizaciones\
   ├── looker_dashboard_completo.png
   ├── looker_kpis.png
   ├── looker_top10_aerolineas.png
   └── looker_top10_aeronaves.png
   ```

### Paso 4.2: Exportar a PDF

1. **Compartir** → **Descargar informe** → **PDF**
2. Configuración:
   - Tamaño: **Carta**
   - Orientación: **Horizontal**
   - Calidad: **Alta**
3. Guardar como: `Ejercicio_1_Dashboard_Aviacion.pdf`

### Paso 4.3: Obtener enlace para compartir

1. **Compartir** → **Gestionar acceso**
2. Cambiar a: **Cualquier persona con el enlace puede ver**
3. **Copiar enlace**
4. Agregar al README del ejercicio

---

## 🚗 PARTE 5: Repetir para Ejercicio 2 (10 minutos)

Seguir los mismos pasos pero con:

### Visualizaciones requeridas Ejercicio 2:

1. **Gráfico de barras:** 5 Estados Baja Demanda
3. **Gráfico de barras:** Top 10 Modelos
4. **Gráfico de líneas:** Alquileres por Año (2010-2015)
5. **Gráfico de barras apiladas:** Top 5 Ciudades Ecológicas


## ✅ Checklist Final

### Ejercicio 1 - Aviación
- [ ] CSV exportado desde Hive
- [ ] Google Sheet creado con 2 pestañas
- [ ] Dashboard en Looker Studio con 2 visualizaciones
- [ ] Gráfico: Top 10 Aerolíneas
- [ ] Gráfico: Top 10 Aeronaves
- [ ] Capturas de pantalla guardadas
- [ ] PDF exportado
- [ ] Enlace compartible obtenido

### Ejercicio 2 - Car Rental
- [ ] CSV exportado desde Hive
- [ ] Google Sheet creado con 4 pestañas
- [ ] Dashboard en Looker Studio con 4 visualizaciones
- [ ] Gráfico: Estados Baja Demanda
- [ ] Gráfico: Top 10 Modelos
- [ ] Gráfico de líneas: Alquileres por Año
- [ ] Gráfico apilado: Ciudades Ecológicas
- [ ] Capturas y PDF guardados
- [ ] Enlace compartible obtenido

**Enlaces de tus dashboards:**
- Ejercicio 1: `[https://lookerstudio.google.com/reporting/097a5d41-f133-4182-b0b2-c230eba75360]`
- Ejercicio 2: `[https://lookerstudio.google.com/reporting/0a27dabb-7650-42f1-b7ec-33528cfc1f62]`

---

**Fecha:** Diciembre 2025  
**Autor:** Data Engineering Team - EDVai  
**Tiempo total:** ~35 minutos (ambos ejercicios)

