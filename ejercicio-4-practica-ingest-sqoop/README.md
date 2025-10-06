# 🚀 Práctica Sqoop - Script Automatizado

Este script (`sqoop.sh`) contiene una serie de comandos básicos para practicar la conexión entre **PostgreSQL** y **Hadoop** utilizando **Sqoop**.

---

## 🔧 Requisitos previos

1. Tener corriendo los contenedores de **Hadoop** y **Postgres**.  
2. Acceder al contenedor de Hadoop:  
   ```bash
   docker exec -it edvai_hadoop bash
   su hadoop

3. En otra shell, verificar Ip y puerto del contendor Postgres:
    ```bash
   docker inspect edvai_postgres
