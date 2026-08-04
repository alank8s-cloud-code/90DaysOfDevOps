#!/bin/bash

<< read

This script tell the input and validation
give me log for a specific file
there is log file is exist also check
if any failure occur stop the script
Usage: ./log_analyzer.sh <give the log file path>

read


display_usage() {


        #check the file path provided or not
        if [ $# -ne 1 ]; then
                echo "Usage: ./log_analyzer.sh <give the log file path>"
                exit 1
        fi

}

LOGFILE=$1
display_usage ${LOGFILE}


check_file() {

        # check the file is exit or not
        if [ ! -f "${LOGFILE}" ]; then
                echo "Your given log path file is doesn't exist : give me correct  log path file"
                exit 1

        fi


}


find_error_count() {

        # Count ERROR or Failed entries
        ERROR_COUNT=$(grep -iE -c "error|FAILED" "${LOGFILE}")

        #display how many error count
        echo "---Error EVENTS---"
        echo "Total errors: ${ERROR_COUNT}"
        echo ""

        CRITCAL_COUNT=$(grep -in "CRITICAL" "${LOGFILE}")

        #display the critical events
        echo "---CRITICAL EVENTS---"
        echo "${CRITCAL_COUNT}"


}

find_error_message() {

        # Count ERROR or Failed entries
        ERROR_COUNT=$(grep -i "error" "${LOGFILE}" | cut -d' ' -f4- | sort | uniq -c | sort -nr | head -5)

        #display --- Top 5 Error Messages ---
        echo "--- Top 5 Error Messages ---"
        echo "${ERROR_COUNT}"
        echo ""

}

check_file

find_error_message
