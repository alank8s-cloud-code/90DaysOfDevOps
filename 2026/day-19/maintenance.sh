#!/bin/bash

<< info

Master maintenance scirpt
Run log rotation and backup

info

# -----------------------------
# Configuration
# -----------------------------

set -euo pipefail

LOGFILE="/var/log/maintenance.log"

log_rotate_script="/home/alan/DevOps_Journay_Zero_to_Hero/linux_practice/day-19/log_rotate.sh"
backup_rotate_script="/home/alan/DevOps_Journay_Zero_to_Hero/linux_practice/day-19/backup.sh"

log_dir="/var/log/nginx"
source_dir="/home/alan/DevOps_Journay_Zero_to_Hero/linux_practice/day-19/data"
backup_dir="/home/alan/DevOps_Journay_Zero_to_Hero/linux_practice/day-19/backups"

echo "========== Maintenance Started =========="

echo "===== Maintenance Started : $(date) =====" >> $LOGFILE

# Run log rotation

echo "Running Log Rotation..." >> ${LOGFILE}

bash ${log_rotate_script} ${log_dir} >>  ${LOGFILE} 2>&1

echo "Log Rotation Completed..."

# Run backup

echo "Running Backup..." >> ${LOGFILE}

bash ${backup_rotate_script} ${source_dir} ${backup_dir} >> ${LOGFILE} 2>&1

echo "Backup Completed..."

echo "===== Maintenance Finished : $(date) =====" >> $LOGFILE

echo "" >> $LOGFILE

echo "========== Maintenance Finished =========="
