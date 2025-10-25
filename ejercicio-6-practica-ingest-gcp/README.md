# Ejercicio 6 - Práctica Ingest GCP

Este ejercicio se enfoca en la **ingesta de datos en Google Cloud Platform (GCP)** utilizando **Google Cloud Storage** y **Storage Transfer Service**.

## 🎯 Objetivos

- Crear buckets en Google Cloud Storage
- Realizar ingesta de archivos CSV usando gsutil CLI
- Configurar Storage Transfer Service para migración de datos
- Gestionar buckets multiregionales y regionales

## 📋 Ejercicios Incluidos

### 1️⃣ **Crear Buckets en GCP**
- Bucket regional estándar en Finlandia: `demo-bucket-edvai`
- Bucket multiregional estándar en US: `data-bucket-demo-1`
- **Método**: Interfaz gráfica de Google Cloud Console

### 2️⃣ **Ingesta con gsutil CLI**
- Subir 5 archivos CSV al bucket `data-bucket-demo-1`
- Script automatizado para carga masiva
- Verificación de archivos subidos

### 3️⃣ **Storage Transfer Service**
- Crear job de transferencia entre buckets
- Configurar migración automática de datos
- Monitorear el proceso de transferencia

## 📁 Estructura del Ejercicio

```
ejercicio-6-practica-ingest-gcp/
├── README.md                    # Documentación principal
├── scripts/
│   ├── upload_csvs.sh          # Script de subida de archivos
│   └── README.md               # Documentación de scripts
├── images/                     # Capturas de pantalla
│   ├── bucket-regional-finlandia.jpg
│   ├── bucket-multiregional-us.jpg
│   └── storage-transfer-service.jpg
├── documentation/              # Documentación adicional
│   └── gcp-console-guide.md    # Guía de creación de buckets
└── ejercicios-resueltos.md     # Resultados de ejercicios
```

## 🚀 Tecnologías Utilizadas

- **Google Cloud Storage** - Almacenamiento de objetos
- **gsutil CLI** - Herramienta de línea de comandos
- **Storage Transfer Service** - Migración de datos
- **Bash Scripting** - Automatización de procesos

## 📊 Datos Utilizados

- **Fuente**: Archivos CSV locales
- **Destino**: Buckets de Google Cloud Storage
- **Formato**: CSV
- **Cantidad**: 5 archivos

## 🔧 Requisitos Previos

- Cuenta de Google Cloud Platform
- gsutil CLI instalado y configurado
- Permisos para crear buckets y usar Storage Transfer Service
- Archivos CSV en directorio local
- Acceso a Google Cloud Console (interfaz gráfica)

## 📖 Guías Adicionales

- **Creación de Buckets**: `documentation/gcp-console-guide.md`
- **Scripts de Automatización**: `scripts/README.md`
- **Resultados de Ejercicios**: `ejercicios-resueltos.md`
