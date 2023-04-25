#!/bin/bash

# Check if PID is provided as command-line argument
if [ -z "$1" ]
then
  echo "Error: Please provide the PID of the process to monitor as a command-line argument"
  echo "Usage: ./script.sh <PID>"
  exit 1
fi

# Get PID from command-line argument
PID=$1

# Specify the duration of time to collect statistics (in seconds)
DURATION=$((30*60))

# Specify the delay between updates (in seconds)
DELAY=5

# Output file for statistics
OUTPUT_FILE="process_stats.txt"

# Header for output file
echo "Time, CPU (%), Memory (%), Disk Read (KB/s), Disk Write (KB/s)" > $OUTPUT_FILE

# Loop over specified duration of time, collecting statistics every DELAY seconds
for ((i=0; i<$DURATION; i+=$DELAY)); do
    # Get current time stamp
    TIME=$(date +%H:%M:%S)

    # Run top command and extract CPU, memory, and disk I/O statistics for specified process
    TOP_OUTPUT=$(top -b -n1 -p $PID | grep $PID)
    CPU=$(echo $TOP_OUTPUT | awk '{print $9}')
    MEM=$(echo $TOP_OUTPUT | awk '{print $10}')
    DISK_READ=$(echo $TOP_OUTPUT | awk '{print $6}')
    DISK_WRITE=$(echo $TOP_OUTPUT | awk '{print $7}')

    # Append statistics to output file
    echo "$TIME, $CPU, $MEM, $DISK_READ, $DISK_WRITE" >> $OUTPUT_FILE

    # Wait for specified delay before collecting next set of statistics
    sleep $DELAY
done