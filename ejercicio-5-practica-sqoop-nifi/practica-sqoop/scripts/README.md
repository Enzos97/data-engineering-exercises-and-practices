# Scripts de Sqoop

## Archivo: sqoop-exercises.sh

Este script contiene todos los comandos ejecutados en la práctica de Sqoop, organizados por ejercicios.

### Contenido del Script

El script incluye:

1. **Configuración inicial**: Variables para conexión a PostgreSQL
2. **Ejercicio 1**: Listar tablas de la base de datos northwind
3. **Ejercicio 2**: Mostrar clientes de Argentina
4. **Ejercicio 3**: Importar tabla orders completa
5. **Ejercicio 4**: Importar productos con más de 20 unidades en stock
6. **Verificación**: Comandos para verificar los resultados

### Uso del Script

```bash
# Ejecutar el script completo
./sqoop-exercises.sh

# O ejecutar comandos individuales copiando y pegando desde el script
```

### Características

- **Comentarios detallados**: Cada sección está explicada
- **Variables configurables**: Fácil modificación de parámetros de conexión
- **Verificación automática**: Incluye comandos para verificar resultados
- **Formato organizado**: Estructura clara por ejercicios

### Parámetros Configurables

```bash
DB_HOST="172.17.0.1"      # IP del contenedor PostgreSQL
DB_PORT="5432"             # Puerto de PostgreSQL
DB_NAME="northwind"        # Nombre de la base de datos
DB_USER="postgres"         # Usuario de la base de datos
DB_PASSWORD="edvai"        # Contraseña (se solicita con -P)
```

### Requisitos Previos

1. Contenedor de Hadoop ejecutándose
2. Contenedor de PostgreSQL ejecutándose
3. Sqoop instalado y configurado
4. Acceso a HDFS

### Troubleshooting

Si el script falla:

1. **Verificar contenedores**: `docker ps`
2. **Verificar IP de PostgreSQL**: `docker inspect edvai_postgres`
3. **Verificar HDFS**: `hdfs dfs -ls /`
4. **Verificar permisos**: Asegurar que el usuario tenga permisos de escritura en HDFS
