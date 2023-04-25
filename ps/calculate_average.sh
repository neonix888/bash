#!/bin/bash

# Check if the file name is provided as a command-line argument
if [ -z "$1" ]
then
    echo "Error: Please provide the file name to process as a command-line argument"
    echo "Usage: $0 <file_name>"
    exit 1
fi

# Get the file name from command-line argument
INPUT_FILE=$1

# Detect the number of CPU cores
NUM_CPU_CORES=$(nproc)

# Read the input file into an array
readarray -t STATS < "$INPUT_FILE"

# Remove the header from the array
unset STATS[0]

# Initialize counters
CPU_TOTAL=0
MEM_TOTAL=0
DISK_READ_TOTAL=0
DISK_WRITE_TOTAL=0
COUNT=0

# Calculate the total number of lines in the array
TOTAL_LINES=${#STATS[@]}

# Loop over the array, summing the statistics and counting the lines
for LINE in "${STATS[@]}"
do
    CPU=$(echo "$LINE" | awk -F, '{print $2}')
    MEM=$(echo "$LINE" | awk -F, '{print $3}')
    DISK_READ=$(echo "$LINE" | awk -F, '{print $4}')
    DISK_WRITE=$(echo "$LINE" | awk -F, '{print $5}')

    CPU_TOTAL=$(echo "$CPU_TOTAL $CPU" | awk '{print $1 + $2}')
    MEM_TOTAL=$(echo "$MEM_TOTAL $MEM" | awk '{print $1 + $2}')
    DISK_READ_TOTAL=$(echo "$DISK_READ_TOTAL $DISK_READ" | awk '{print $1 + $2}')
    DISK_WRITE_TOTAL=$(echo "$DISK_WRITE_TOTAL $DISK_WRITE" | awk '{print $1 + $2}')

    COUNT=$((COUNT + 1))

    # Calculate progress percentage and display progress bar
    PROGRESS=$(awk "BEGIN { printf \"%.2f\", ($COUNT / $TOTAL_LINES) * 100 }")
    printf "Processing: %s%%\r" "$PROGRESS"
done

echo "" # Move to the next line after the progress bar

# Check if COUNT is greater than zero to avoid division by zero error
if [ "$COUNT" -gt 0 ]; then
    CPU_AVG=$(awk "BEGIN { printf \"%.2f\", $CPU_TOTAL / $COUNT }")
    CPU_AVG_PER_CORE=$(awk "BEGIN { printf \"%.2f\", $CPU_AVG / $NUM_CPU_CORES }")
    MEM_AVG=$(awk "BEGIN { printf \"%.2f\", $MEM_TOTAL / $COUNT }")
    DISK_READ_AVG=$(awk "BEGIN { printf \"%.2f\", $DISK_READ_TOTAL / $COUNT }")
    DISK_WRITE_AVG=$(awk "BEGIN { printf \"%.2f\", $DISK_WRITE_TOTAL / $COUNT }")

    # Print averages to console
    echo "Average CPU usage: $CPU_AVG % (total)"
    echo "Average CPU usage per core: $CPU_AVG_PER_CORE %"
    echo "Average memory usage: $MEM_AVG %"
    echo "Average disk read rate: $DISK_READ_AVG KB/s"
    echo "Average disk write rate: $DISK_WRITE_AVG KB/s"
else
    echo "No data available to calculate averages."
fi

