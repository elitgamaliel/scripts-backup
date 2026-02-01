#!/bin/bash
# MySQL Backup Script - Native Linux (No Python required)
# Improved version with .env support and better error handling

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
DB_HOST="localhost"
DB_PORT="3306"
DB_USER="root"
DB_PASSWORD=""
DB_NAME=""
BACKUP_DIR="./backups"
RETENTION_DAYS="7"
COMPRESSION="false"
MYSQL_PATH_LINUX="/usr/bin/mysqldump"
LOG_FILE="backup.log"

# Functions for colored output
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1" >> "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1" >> "$LOG_FILE"
}

# Load .env file if exists
if [ -f ".env" ]; then
    log_info "Loading configuration from .env file..."
    # Export variables from .env file, ignoring comments and empty lines
    export $(grep -v '^#' .env | grep -v '^$' | xargs)
else
    log_warn ".env file not found, using default configuration"
fi

# Validate required configuration
if [ -z "$DB_PASSWORD" ]; then
    log_error "DB_PASSWORD is required"
    echo "Please set DB_PASSWORD in .env file"
    exit 1
fi

if [ -z "$DB_NAME" ]; then
    log_error "DB_NAME is required"
    echo "Please set DB_NAME in .env file"
    exit 1
fi

# Check if mysqldump exists
if [ ! -f "$MYSQL_PATH_LINUX" ]; then
    log_error "MySQL dump not found at: $MYSQL_PATH_LINUX"
    echo "Please verify MYSQL_PATH_LINUX in .env file or install mysql-client"
    exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        log_error "Cannot create backup directory: $BACKUP_DIR"
        exit 1
    fi
fi

# Generate timestamp
timestamp=$(date '+%Y-%m-%d_%H-%M')

# Generate backup filename
backup_file="$BACKUP_DIR/backup_${DB_NAME}_${timestamp}.sql"

# Start backup process
log_info "Starting backup of database: $DB_NAME"

# Build and execute mysqldump command
dump_cmd="$MYSQL_PATH_LINUX --host=$DB_HOST --port=$DB_PORT --user=$DB_USER --password=$DB_PASSWORD --single-transaction --routines --triggers $DB_NAME"

if $dump_cmd > "$backup_file" 2>/tmp/backup_error.log; then
    log_success "Backup completed: $backup_file"
    
    # Compress if enabled
    if [ "$COMPRESSION" = "true" ]; then
        log_info "Compressing backup..."
        if gzip "$backup_file"; then
            backup_file="${backup_file}.gz"
            log_success "Backup compressed: $backup_file"
        else
            log_warn "Compression failed, keeping uncompressed backup"
        fi
    fi
else
    log_error "Backup failed for $DB_NAME"
    echo "Error details:"
    cat /tmp/backup_error.log
    cat /tmp/backup_error.log >> "$LOG_FILE"
    rm -f /tmp/backup_error.log
    exit 1
fi

# Cleanup old backups
log_info "Cleaning up old backups (older than $RETENTION_DAYS days)"

# Find and remove old backup files
old_backups=$(find "$BACKUP_DIR" -name "backup_*.sql*" -type f -mtime +$RETENTION_DAYS 2>/dev/null)

if [ -n "$old_backups" ]; then
    echo "$old_backups" | while read -r old_file; do
        rm -f "$old_file"
        log_info "Removed old backup: $old_file"
    done
    log_success "Old backups cleaned up"
else
    log_info "No old backups found to clean up"
fi

# Cleanup temporary files
rm -f /tmp/backup_error.log

log_success "Backup process completed successfully"

# Show backup file size
if [ -f "$backup_file" ]; then
    file_size=$(du -h "$backup_file" | cut -f1)
    log_info "Backup file size: $file_size"
fi