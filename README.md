# MySQL Backup Scripts - Cross Platform

Sistema de backup mejorado para bases de datos MySQL que funciona en Windows y Linux **sin dependencias adicionales**.

## 🚀 Características principales

- ✅ **Multiplataforma**: Windows y Linux
- ✅ **Sin dependencias**: Scripts nativos (Batch/Bash) - Solo requiere MySQL
- ✅ **Configuración centralizada**: Archivo .env para todas las configuraciones
- ✅ **Ejecución silenciosa**: Soporte para segundo plano y programación automática
- ✅ **Compresión opcional**: Archivos ZIP/GZ para ahorrar espacio
- ✅ **Rotación automática**: Limpieza inteligente de backups antiguos
- ✅ **Logging detallado**: Registro completo de todas las operaciones
- ✅ **Validaciones robustas**: Verificación de configuración, rutas y permisos
- ✅ **Manejo de errores**: Recuperación ante fallos con mensajes claros
- ✅ **Timestamps compatibles**: Generación de fechas sin dependencias externas

## 📁 Archivos del proyecto

### Scripts principales
- `backup_mysql_native.bat` - Script para Windows (Batch nativo)
- `backup_mysql_native.sh` - Script para Linux (Bash nativo)
- `run_backup.vbs` - Ejecutor silencioso para Windows (opcional)

### Configuración
- `.env` - Archivo de configuración principal
- `.env.example` - Plantilla de configuración

### Programación automática (Linux)
- `mysql-backup.service` - Servicio systemd
- `mysql-backup.timer` - Timer systemd
- `crontab_examples.txt` - Ejemplos de configuración crontab

### Documentación
- `README.md` - Esta documentación
- `.gitignore` - Exclusiones para control de versiones

## 🛠️ Instalación y configuración

### Requisitos mínimos
- **MySQL/MariaDB** con mysqldump instalado
- **Windows**: CMD/PowerShell (incluidos en Windows)
- **Linux**: Bash (incluido en todas las distribuciones)

### Configuración inicial

1. **Clonar o descargar** los archivos del proyecto
2. **Configurar variables de entorno**:
   ```bash
   cp .env.example .env
   ```
   
3. **Editar el archivo .env** con tus configuraciones:
   ```ini
   # Configuración de base de datos
   DB_HOST=localhost
   DB_PORT=3308
   DB_USER=root
   DB_PASSWORD=tu_password_aqui
   DB_NAME=nombre_de_tu_bd
   
   # Configuración de backup
   BACKUP_DIR=D:\Respaldo  # Windows
   # BACKUP_DIR=/home/user/backups  # Linux
   RETENTION_DAYS=7
   COMPRESSION=false
   ```

4. **Verificar rutas de MySQL** en `.env`:
   - Windows: `MYSQL_PATH_WIN`
   - Linux: `MYSQL_PATH_LINUX`

## 🚀 Uso

### Ejecución manual

#### Windows
```cmd
# Ejecución normal (con ventana)
backup_mysql_native.bat

# Ejecución silenciosa (sin ventana)
run_backup.vbs
```

#### Linux
```bash
# Hacer ejecutable el script (solo la primera vez)
chmod +x backup_mysql_native.sh

# Ejecutar backup
./backup_mysql_native.sh
```

### Programación automática

#### Windows - Task Scheduler

**Opción 1: Ejecución normal**
```cmd
schtasks /create /tn "MySQL Backup" /tr "C:\ruta\completa\backup_mysql_native.bat" /sc daily /st 02:00
```

**Opción 2: Ejecución silenciosa (recomendado)**
```cmd
schtasks /create /tn "MySQL Backup Silent" /tr "C:\ruta\completa\run_backup.vbs" /sc daily /st 02:00 /f
```

#### Linux - Crontab

**Configuración básica:**
```bash
# Editar crontab
crontab -e

# Agregar línea para backup diario a las 2:00 AM
0 2 * * * /ruta/completa/backup_mysql_native.sh >/dev/null 2>&1
```

**Ejemplos avanzados** (ver `crontab_examples.txt`):
```bash
# Backup cada 6 horas
0 */6 * * * /ruta/completa/backup_mysql_native.sh >/dev/null 2>&1

# Solo días laborables
0 3 * * 1-5 /ruta/completa/backup_mysql_native.sh >/dev/null 2>&1

# Con logging detallado
0 2 * * * /ruta/completa/backup_mysql_native.sh >> /var/log/mysql_backup.log 2>&1
```

#### Linux - Systemd (alternativa moderna)

1. **Copiar archivos de servicio:**
   ```bash
   sudo cp mysql-backup.service /etc/systemd/system/
   sudo cp mysql-backup.timer /etc/systemd/system/
   ```

2. **Activar y configurar:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable mysql-backup.timer
   sudo systemctl start mysql-backup.timer
   ```

3. **Verificar estado:**
   ```bash
   sudo systemctl status mysql-backup.timer
   sudo systemctl list-timers mysql-backup.timer
   ```

## ⚙️ Configuración avanzada

### Variables de entorno disponibles

| Variable | Descripción | Valor por defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `DB_HOST` | Host de la base de datos | `localhost` | `192.168.1.100` |
| `DB_PORT` | Puerto de MySQL | `3306` | `3308` |
| `DB_USER` | Usuario de MySQL | `root` | `backup_user` |
| `DB_PASSWORD` | Contraseña (requerida) | - | `mi_password_seguro` |
| `DB_NAME` | Nombre de la base de datos (requerida) | - | `mi_aplicacion` |
| `BACKUP_DIR` | Directorio de backups | `./backups` | `D:\Respaldos` |
| `RETENTION_DAYS` | Días de retención | `7` | `30` |
| `COMPRESSION` | Comprimir backups | `false` | `true` |
| `MYSQL_PATH_WIN` | Ruta mysqldump Windows | Ver .env.example | - |
| `MYSQL_PATH_LINUX` | Ruta mysqldump Linux | `/usr/bin/mysqldump` | - |
| `LOG_FILE` | Archivo de log | `backup.log` | `mysql_backup.log` |

### Opciones de compresión

- **Windows**: Usa PowerShell para crear archivos ZIP
- **Linux**: Usa gzip para crear archivos .gz
- **Activar**: Cambiar `COMPRESSION=true` en `.env`
- **Beneficio**: Reduce significativamente el tamaño de los backups

### Rotación de backups

- **Automática**: Se ejecuta después de cada backup exitoso
- **Configurable**: Ajustar `RETENTION_DAYS` en `.env`
- **Inteligente**: Solo elimina archivos que coinciden con el patrón `backup_*.sql*`

## 🔄 Migración desde scripts antiguos

Si tienes scripts anteriores con `config.ini`, `backup_mysql.bat` original, o `run_backup.vbs`:

### Pasos de migración:

1. **Migrar configuración**:
   ```ini
   # De config.ini (formato antiguo):
   [client]
   user=root
   password=mi_password
   port=3308
   
   # A .env (formato nuevo):
   DB_USER=root
   DB_PASSWORD=mi_password
   DB_PORT=3308
   DB_NAME=nombre_de_tu_bd  # Agregar este campo
   ```

2. **Actualizar rutas**:
   - Cambiar rutas hardcodeadas por variables en `.env`
   - Verificar `BACKUP_DIR` y rutas de MySQL

3. **Reemplazar ejecución**:
   - **Antes**: `backup_mysql.bat` (original)
   - **Ahora**: `backup_mysql_native.bat` (mejorado)
   - **VBS**: Actualizar ruta en `run_backup.vbs` (ya actualizado)

4. **Actualizar programación**:
   - Cambiar Task Scheduler para usar nuevos scripts
   - Mantener horarios y frecuencia existentes

### Ventajas de la migración:

- ✅ Mejor manejo de errores
- ✅ Logging detallado
- ✅ Configuración más flexible
- ✅ Soporte para compresión
- ✅ Rotación automática mejorada
- ✅ Compatibilidad con sistemas modernos

## 🔧 Troubleshooting

### Errores comunes y soluciones

#### Error: "MySQL dump not found"
```
[ERROR] MySQL dump not found at: C:\Program Files\MySQL\...
```
**Solución**:
- Verificar la ruta en `MYSQL_PATH_WIN` o `MYSQL_PATH_LINUX` en `.env`
- Instalar MySQL Client si no está disponible
- En Linux: `sudo apt install mysql-client` o `sudo yum install mysql`

#### Error: "DB_PASSWORD is required"
```
[ERROR] DB_PASSWORD is required
```
**Solución**:
- Configurar la contraseña en el archivo `.env`
- No dejar espacios alrededor del signo `=`
- Verificar que el archivo `.env` existe en el directorio correcto

#### Error: "Permission denied"
```
bash: ./backup_mysql_native.sh: Permission denied
```
**Solución**:
- En Linux: `chmod +x backup_mysql_native.sh`
- Verificar permisos de escritura en `BACKUP_DIR`
- Ejecutar con `sudo` si es necesario para directorios del sistema

#### Error: "Cannot create backup directory"
```
[ERROR] Cannot create backup directory: D:\Respaldo
```
**Solución**:
- Verificar que la ruta padre existe
- Comprobar permisos de escritura
- En Windows: verificar que la unidad existe
- Cambiar `BACKUP_DIR` a una ruta accesible

#### Backup se ejecuta pero está vacío
**Posibles causas**:
- Credenciales incorrectas de MySQL
- Base de datos no existe
- Usuario sin permisos de lectura

**Solución**:
- Verificar conexión: `mysql -h localhost -P 3308 -u root -p`
- Comprobar que la base de datos existe: `SHOW DATABASES;`
- Revisar logs en `backup.log`

### Comandos de diagnóstico

#### Windows
```cmd
# Verificar MySQL
"%MYSQL_PATH_WIN%" --version

# Probar conexión
mysql -h localhost -P 3308 -u root -p

# Ver logs
type backup.log
```

#### Linux
```bash
# Verificar MySQL
mysqldump --version

# Probar conexión
mysql -h localhost -P 3306 -u root -p

# Ver logs en tiempo real
tail -f backup.log

# Verificar crontab
crontab -l

# Ver logs de cron
sudo tail -f /var/log/cron
```

## 📋 Logs y monitoreo

### Archivo de logs

Los logs se guardan en el archivo especificado en `LOG_FILE` (por defecto `backup.log`):

**Información registrada**:
- ✅ Timestamp de cada operación
- ✅ Inicio y fin de backups
- ✅ Éxito/fallo de operaciones
- ✅ Archivos eliminados en la rotación
- ✅ Errores detallados con contexto
- ✅ Tamaño de archivos generados
- ✅ Tiempo de ejecución

**Ejemplo de log**:
```
[2024-01-31 14:30:01] [INFO] Starting backup of database: healthy
[2024-01-31 14:30:15] [SUCCESS] Backup completed: D:\Respaldo\backup_healthy_2024-01-31_14-30.sql
[2024-01-31 14:30:16] [INFO] Starting cleanup of backups older than 7 days
[2024-01-31 14:30:16] [INFO] Removed old backup: backup_healthy_2024-01-24_02-00.sql
[2024-01-31 14:30:16] [SUCCESS] Backup process completed
```

### Monitoreo de backups

#### Verificar último backup
```bash
# Linux
ls -la /ruta/backups/ | head -10

# Windows
dir D:\Respaldo /o-d
```

#### Verificar logs recientes
```bash
# Linux - últimas 20 líneas
tail -20 backup.log

# Windows - últimas líneas
powershell "Get-Content backup.log -Tail 20"
```

#### Alertas por email (Linux)
Agregar al crontab para recibir notificaciones de errores:
```bash
0 2 * * * /ruta/backup_mysql_native.sh || echo "MySQL Backup Failed $(date)" | mail -s "Backup Error" admin@example.com
```

## 🔒 Seguridad y mejores prácticas

### Protección de credenciales
- ✅ **Archivo .env**: Mantén las credenciales separadas del código
- ✅ **Control de versiones**: Agrega `.env` a `.gitignore`
- ✅ **Permisos restrictivos**: `chmod 600 .env` en Linux
- ✅ **Usuario dedicado**: Crea un usuario MySQL específico para backups

### Configuración de usuario MySQL para backups
```sql
-- Crear usuario específico para backups
CREATE USER 'backup_user'@'localhost' IDENTIFIED BY 'password_seguro';

-- Otorgar permisos mínimos necesarios
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON *.* TO 'backup_user'@'localhost';

-- Aplicar cambios
FLUSH PRIVILEGES;
```

### Recomendaciones de seguridad
- 🔐 **Contraseñas fuertes**: Usa contraseñas complejas
- 🔐 **Rotación regular**: Cambia credenciales periódicamente
- 🔐 **Acceso limitado**: Restringe acceso a archivos de configuración
- 🔐 **Backups cifrados**: Considera cifrar backups sensibles
- 🔐 **Ubicación segura**: Almacena backups en ubicaciones protegidas

### Configuración de permisos (Linux)
```bash
# Permisos restrictivos para archivos de configuración
chmod 600 .env
chmod 700 backup_mysql_native.sh

# Permisos para directorio de backups
chmod 750 /ruta/backups
chown usuario:grupo /ruta/backups
```

### Ejemplo de .gitignore
```gitignore
# Archivos de configuración con credenciales
.env

# Logs
*.log

# Backups locales
backups/
*.sql
*.sql.gz
*.sql.zip

# Archivos temporales
temp_*
backup_error.tmp
```
## 📊 
Comparación con scripts originales

| Característica | Script Original | Scripts Nativos Mejorados |
|----------------|-----------------|---------------------------|
| **Dependencias** | Solo MySQL | Solo MySQL ✅ |
| **Configuración** | Hardcodeada en script | Archivo .env centralizado ✅ |
| **Manejo de errores** | Básico | Robusto con validaciones ✅ |
| **Logging** | Mínimo | Detallado con timestamps ✅ |
| **Compresión** | No | Opcional (ZIP/GZ) ✅ |
| **Rotación** | Básica con forfiles | Inteligente multiplataforma ✅ |
| **Timestamps** | Dependiente de wmic | Compatible sin dependencias ✅ |
| **Multiplataforma** | Solo Windows | Windows + Linux ✅ |
| **Ejecución silenciosa** | Con VBS | Nativo + VBS mejorado ✅ |
| **Programación** | Task Scheduler básico | Task Scheduler + Cron + Systemd ✅ |

## 🤝 Contribuciones

¿Encontraste un bug o tienes una mejora? ¡Las contribuciones son bienvenidas!

### Cómo contribuir:
1. Fork del repositorio
2. Crea una rama para tu feature: `git checkout -b feature/nueva-funcionalidad`
3. Commit tus cambios: `git commit -am 'Agregar nueva funcionalidad'`
4. Push a la rama: `git push origin feature/nueva-funcionalidad`
5. Crear un Pull Request

### Reportar problemas:
- Incluye información del sistema operativo
- Versión de MySQL/MariaDB
- Contenido del archivo `.env` (sin credenciales)
- Logs de error completos

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver archivo `LICENSE` para más detalles.

## 🙏 Agradecimientos

- Basado en scripts originales de backup MySQL
- Mejorado para compatibilidad multiplataforma
- Inspirado en mejores prácticas de DevOps y automatización

---

**¿Necesitas ayuda?** Revisa la sección de [Troubleshooting](#-troubleshooting) o abre un issue en el repositorio.