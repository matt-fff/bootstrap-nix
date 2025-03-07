#!/usr/bin/env bash
USAGE="
Usage:
    $0 <lockname> <nas_dir> <local_dir> [<folders>]
"

if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
    echo "Error: parameters are required"
    echo "${USAGE}"
    exit 1
fi

LOCK_NAME="$1" # doomnas-projects
NAS_DIR="$2"
if [[ ! "$NAS_DIR" =~ /$ ]]; then
    NAS_DIR="${NAS_DIR}/"
fi
LOCAL_DIR="$3"
if [[ ! "$LOCAL_DIR" =~ /$ ]]; then
    LOCAL_DIR="${LOCAL_DIR}/"
fi

if [ -n "$4" ]; then
    FOLDERS=$(echo "$4" | tr ',' ' ')
else
    FOLDERS='.'
fi

LOG_DIR="/var/log/rsync"
LOG_FILE="${LOG_DIR}/${LOCK_NAME}-$(date +%Y%m%d).log"
LOCK_FILE="${LOG_DIR}/locks/${LOCK_NAME}.lock"

# Create log directory if it does not exist
mkdir -p "${LOG_DIR}/locks"

# Function to log a message with a timestamp
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee "${LOG_FILE}"
}

# Check for existence of lockfile
if [ -e "${LOCK_FILE}" ] && [ "${FORCE_SYNC}" != "1" ]; then
    log_message "The script is already running." >&2
    exit 1
else
    touch "${LOCK_FILE}"
fi

# Define a function to remove lockfile when exiting
cleanup() {
    rm -f "${LOCK_FILE}"
}

# Set the trap to call cleanup function
# when script exits or receives common termination signals
trap cleanup EXIT INT TERM HUP

for folder in ${FOLDERS}; do
    nas_dir="${NAS_DIR}${folder}"
    local_dir="${LOCAL_DIR}${folder}"

    log_message "Syncing local:${local_dir} <-> nas:${nas_dir}"

    # Main rsync operation with logging
    if rsync \
        --partial \
        --progress \
        -avr \
        --no-group \
        --exclude='.SynologyWorkingDirectory' \
        --exclude='#*' \
        --exclude='part.*' \
        --exclude='.DS_Store' \
        --exclude='old/' \
        --exclude='.Trash*' \
        --exclude='.stignore.*' \
        --delete "${nas_dir}/" "${local_dir}/" &>> "${LOG_FILE}"; then
        log_message "   Sync nas->local completed successfully."
    else
        log_message "   An error occurred during rsync." >&2
        exit 1
    fi

    # Main rsync operation with logging
    if rsync \
        --partial \
        --progress \
        -avr \
        --no-group \
        --exclude='.SynologyWorkingDirectory' \
        --exclude='#*' \
        --exclude='part.*' \
        --exclude='.DS_Store' \
        --exclude='old/' \
        --exclude='.Trash*' \
        --exclude='.stignore.*' \
        "${local_dir}/" "${nas_dir}/" &>> "${LOG_FILE}"; then
        log_message "   Sync local->nas completed successfully."
    else
        log_message "   An error occurred during rsync." >&2
        exit 1
    fi
done

log_message "Synchronization completed successfully."
