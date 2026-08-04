#!/bin/bash

# Input validation

LOG_FILE=$1

# Total lines
TOTAL_LINES=$(wc -l < "$LOG_FILE")

# Total errors
ERROR_COUNT=$(grep -iE -c "ERROR|Failed" "$LOG_FILE")

# Report filename
REPORT_FILE="log_report_$(date +%F).txt"

# Generate report
{
echo "===== Log Analysis Report ====="
echo "Date of Analysis : $(date)"
echo "Log File         : $LOG_FILE"
echo "Total Lines      : $TOTAL_LINES"
echo "Total Errors     : $ERROR_COUNT"

echo
echo "----- Top 5 Error Messages -----"
grep -i "ERROR" "$LOG_FILE" | cut -d' ' -f4- | sort | uniq -c | sort -nr | head -5

echo
echo "----- Critical Events -----"
grep -in "CRITICAL" "$LOG_FILE"

} > "$REPORT_FILE"

echo "Report generated successfully: $REPORT_FILE"
