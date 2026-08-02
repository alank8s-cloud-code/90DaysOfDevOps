#!/bin/bash

<< readme

This script for log rotation for 7 days


Usage: ./log_rotate.sh <path log rotation>

readme

display_usage() {

        echo "Usage: ./backup.sh <path log directory rotation >"
}

if [ $# -ne 1 ]; then

        display_usage
        exit 1
fi

LOG_DIR="$1"

# ------------------------------
# Check directory exists
# ------------------------------
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory '$LOG_DIR' does not exist."
    exit 1
fi

# ------------------------------
# Check for root
# ------------------------------

if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo."
    exit 1
fi


perform_logrotaion() {

        set -euo pipefail

        echo "Compressing logs older than 7 days..."

        find "${LOG_DIR}" -type f -name "*.log" -mtime +7 -exec gzip {} \;


        echo "Deleting logs older than 30 days..."

        # Delete them

        find "${LOG_DIR}" -type f -name "*.gz" -mtime +30 -delete

        echo "============================="
        echo "Log rotation complete."

}

perform_logrotaion
