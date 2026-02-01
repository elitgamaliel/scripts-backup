# MySQL Backup Scripts - Cross Platform

Sistema de backup mejorado para bases de datos MySQL que funciona en Windows y Linux **sin dependencias adicionales**.

## Características

- ✅ **Multiplataforma**: Windows y Linux
- ✅ **Sin dependencias**: Scripts nativos (Batch/Bash)
- ✅ **Configuración centralizada**: Archivo .env
- ✅ **Compresión opcional**: Archivos comprimidos para ahorrar espacio
- ✅ **Rotación automática**: Limpieza de backups antiguos
- ✅ **Logging detallado**: Registro de todas las operaciones
- ✅ **Validaciones**: Verificación de configuración y rutas
- ✅ **Manejo de errores**: Recuperación robusta ante fallos

## Archivos incluidos

- `backup_mysql_native.bat` - Script para Windows (Batch nativo)
- `backup_mysql_native.sh` - Script para Linux (Bash nativo)
- `.env.example` - Plantilla de configuración
- `.env` - Archivo de configuración (crear desde .example)

## Instalación

### Requisitos
- MySQL/MariaDB con mysqldump
- Windows: CMD/PowerShell
- Linux: Bash

### Configuración inicial

1. **Configurar variables de entorno**:
   ```bash
   cp .env.example .env
   ```
   
2. **Editar el archivo .env** con tus configuraciones:
   ```ini
   DB_HOST=localhost
   DB_PORT=3308
   DB_USER=root
   DB_PASSWORD=tu_password
   DB_NAME=healthy
   BACKUP_DIR=D:\Respaldo
   ```

## Uso

#### Windows
```cmd
# Ejecutar backup
backup_mysql_native.bat
```

#### Linux
```bash
# Hacer ejecutable el script (solo la primera vez)
chmod +x backup_mysql_native.sh

# Ejecutar backup
./backup_mysql_native.sh
```

## Configuración avanzada

### Variables de entorno disponibles

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `DB_HOST` | Host de la base de datos | `localhost` |
| `DB_PORT` | Puerto de MySQL | `3306` |
| `DB_USER` | Usuario de MySQL | `root` |
| `DB_PASSWORD` | Contraseña (requerida) | - |
| `DB_NAME` | Nombre de la base de datos (requerida) | - |
| `BACKUP_DIR` | Directorio de backups | `./backups` |
| `RETENTION_DAYS` | Días de retención | `7` |
| `COMPRESSION` | Comprimir backups | `false` |
| `LOG_FILE` | Archivo de log | `backup.log` |

### Programar backups automáticos

#### Windows (Task Scheduler)
```cmd
schtasks /create /tn "MySQL Backup" /tr "C:\ruta\backup_mysql_native.bat" /sc daily /st 02:00
```

#### Linux (Crontab)
```bash
# Editar crontab
crontab -e

# Backup diario a las 2:00 AM
0 2 * * * /ruta/completa/backup_mysql_native.sh
```

## Migración desde scripts antiguos

Si tienes los scripts originales (.bat, .vbs, config.ini), puedes migrar fácilmente:

1. Copia los valores de `config.ini` al nuevo `.env`
2. Ajusta las rutas en `.env`
3. Reemplaza la ejecución del .bat antiguo con el nuevo sistema

## Troubleshooting

### Error: "MySQL dump not found"
- Verifica la ruta en `MYSQL_PATH_WIN` o `MYSQL_PATH_LINUX`
- Asegúrate de que MySQL esté instalado

### Error: "Permission denied"
- En Linux: `chmod +x backup_mysql_native.sh`
- Verifica permisos de escritura en `BACKUP_DIR`

### Error: "DB_PASSWORD is required"
- Configura la contraseña en el archivo `.env`
- No dejes espacios alrededor del signo `=`

## Logs

Los logs se guardan en `backup.log` por defecto. Incluyen:
- Timestamp de cada operación
- Éxito/fallo de backups
- Archivos eliminados en la rotación
- Errores detallados

## Seguridad

- El archivo `.env` contiene credenciales sensibles
- Agrégalo a `.gitignore` si usas control de versiones
- Configura permisos restrictivos: `chmod 600 .env` (Linux)