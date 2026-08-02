!/bin/bash

<< readme

This script for backup the files


Usage: ./log_rotate.sh <path to  source directory> <path to backup directory>


readme

display_usage() {

        echo "Usage: ./log_rotate.sh <path to  source directory> <path to backup directory>"
}

if [ $# -ne 2 ]; then

        display_usage
        exit 1
fi

source_dir=$1
timestamp=$(TZ="Asia/Kolkata" date '+%Y-%m-%d-%H-%M-%S')
backup_dir=$2

ARCHIVE_PATH="${backup_dir}/backup_${timestamp}.tar.gz"

create_backup() {

        set -eou pipefail

        echo "Creating backup..."

        tar -czvf "${backup_dir}/backup_${timestamp}.tar.gz" "${source_dir}" > /dev/null

        if [ $? -eq 0 ]; then

                echo "Backup created successfully"
        else
                echo "Backup failed"
                exit 1
        fi

        if [ -s "${ARCHIVE_PATH}" ]; then

                echo "Verification Success: Archive exit."
        else
                echo "Verification Failure: Archive does not exist or is 0 bytes."
                exit
        fi

        echo "Archive Name: $(basename "${ARCHIVE_PATH}")"
        echo "Archive Size: $(du -sh "${ARCHIVE_PATH}" | cut -f1)"

        sudo find "${backup_dir}" -type f -name "*.tar.gz" -mtime +14 -delete
        echo "Deletes backups older than 14 days from the destination"


}

create_backup
