#!/bin/bash
# Backup processed recordings to NAS
# Runs as a cron job to archive old sessions

set -euo pipefail

# Configuration
SOURCE_DIR="/path/to/processed"
BACKUP_DIR="/path/to/nas/podcast-backups"
RETENTION_DAYS=90

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log "Starting podcast backup..."

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    log "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Find sessions older than retention period
OLD_SESSIONS=$(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +$RETENTION_DAYS)

if [ -z "$OLD_SESSIONS" ]; then
    log "No sessions found for archival"
    exit 0
fi

# Archive each old session
while IFS= read -r session_dir; do
    session_name=$(basename "$session_dir")
    log "Archiving session: $session_name"

    # Use rsync for efficient copying
    rsync -avh --progress "$session_dir/" "$BACKUP_DIR/$session_name/"

    if [ $? -eq 0 ]; then
        log "✓ Archived: $session_name"

        # Remove from local storage
        log "Removing from local storage..."
        rm -rf "$session_dir"
    else
        error "Failed to archive: $session_name"
    fi
done <<< "$OLD_SESSIONS"

log "✓ Backup complete"

exit 0
