# Guía de Google Cloud Console - Creación de Buckets

## 🎯 Objetivo

Crear buckets en Google Cloud Storage utilizando la interfaz gráfica de Google Cloud Console.

## 📋 Pasos para Crear Buckets

### 1️⃣ **Acceder a Google Cloud Console**

1. Abrir navegador web
2. Ir a [console.cloud.google.com](https://console.cloud.google.com)
3. Iniciar sesión con cuenta de Google
4. Seleccionar el proyecto correspondiente

### 2️⃣ **Navegar a Cloud Storage**

1. En el menú lateral izquierdo, buscar "Storage"
2. Hacer clic en "Cloud Storage"
3. Seleccionar "Buckets" en el submenú

### 3️⃣ **Crear Bucket Regional (Finlandia)**

1. Hacer clic en el botón **"Create bucket"**
2. Configurar los siguientes parámetros:
   - **Name**: `demo-bucket-edvai`
   - **Location type**: Regional
   - **Region**: europe-north1 (Finlandia)
   - **Storage class**: Standard
   - **Access control**: Uniform
3. Hacer clic en **"Create"**

### 4️⃣ **Crear Bucket Multiregional (US)**

1. Hacer clic en el botón **"Create bucket"**
2. Configurar los siguientes parámetros:
   - **Name**: `data-bucket-demo-1`
   - **Location type**: Multi-region
   - **Region**: US
   - **Storage class**: Standard
   - **Access control**: Uniform
3. Hacer clic en **"Create"**

## 🔍 Verificación de Buckets Creados

### Listar Buckets
```bash
# Ver todos los buckets del proyecto
gsutil ls

# Verificar bucket específico
gsutil ls -L -b gs://demo-bucket-edvai
gsutil ls -L -b gs://data-bucket-demo-1
```

### Verificar Configuración
```bash
# Ver detalles del bucket regional
gsutil ls -L -b gs://demo-bucket-edvai

# Ver detalles del bucket multiregional
gsutil ls -L -b gs://data-bucket-demo-1
```

## 📊 Diferencias entre Regional y Multiregional

### Bucket Regional (Finlandia)
- **Ventajas**: 
  - Menor latencia para usuarios en Finlandia
  - Costos más bajos para datos que no necesitan alta disponibilidad
- **Desventajas**: 
  - Menor disponibilidad en caso de fallas regionales
  - Latencia más alta para usuarios fuera de la región

### Bucket Multiregional (US)
- **Ventajas**: 
  - Alta disponibilidad y durabilidad
  - Mejor rendimiento para usuarios en múltiples regiones
- **Desventajas**: 
  - Costos más altos
  - Mayor latencia para usuarios en regiones específicas

## 🛠️ Configuraciones Adicionales

### Permisos IAM
1. Seleccionar el bucket
2. Ir a la pestaña "Permissions"
3. Configurar permisos según necesidades

### Lifecycle Management
1. Seleccionar el bucket
2. Ir a la pestaña "Lifecycle"
3. Configurar reglas de ciclo de vida

### Versioning
1. Seleccionar el bucket
2. Ir a la pestaña "Protection"
3. Habilitar versioning si es necesario

## 📝 Notas Importantes

- **Nombres únicos**: Los nombres de buckets deben ser únicos globalmente
- **Regiones**: Elegir región según ubicación de usuarios
- **Costos**: Considerar costos de almacenamiento y transferencia
- **Permisos**: Configurar permisos apropiados para seguridad
- **Naming**: Usar convenciones de nomenclatura consistentes

## 🔧 Troubleshooting

### Error: Bucket name already exists
- Solución: Cambiar el nombre del bucket
- Los nombres deben ser únicos globalmente

### Error: Permission denied
- Solución: Verificar permisos IAM
- Asegurar que el usuario tenga rol "Storage Admin"

### Error: Region not available
- Solución: Verificar disponibilidad de la región
- Considerar regiones alternativas
