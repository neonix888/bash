#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -p <PID> [-o output_file] [-d duration] [-s delay]"
    echo "  -p: Process ID (required)"
    echo "  -o: Output file name (default: process_stats.txt)"
    echo "  -d: Duration in seconds (default: 1800)"
    echo "  -s: Delay between updates in seconds (default: 1)"
    exit 1
}

# Default values
OUTPUT_FILE="process_stats.txt"
DURATION=$((30*60))
DELAY=1
PID=""

# Parse command-line options
while getopts "p:o:d:s:" opt; do
    case $opt in
        p)
            PID=$OPTARG
            ;;
        o)
            OUTPUT_FILE=$OPTARG
            ;;
        d)
            DURATION=$OPTARG
            ;;
        s)
            DELAY=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done

# Check if PID is provided
if [ -z "$PID" ]; then
    usage
fi

# Header for output file
echo "Time, CPU (%), Memory (%), Disk Read (KB/s), Disk Write (KB/s)" > $OUTPUT_FILE

# Loop over specified duration of time, collecting statistics every DELAY seconds
for ((i=0; i<$DURATION; i+=$DELAY)); do
    # Get current time stamp
    TIME=$(date +%H:%M:%S)

    # Run top command and extract CPU, memory, and disk I/O statistics for specified process
    TOP_OUTPUT=$(top -b -n1 -p $PID | awk -v pid=$PID '$1==pid {print $9, $10, $6, $7}')

    if [ -z "$TOP_OUTPUT" ]; then
        echo "Error: Process with PID $PID not found."
        exit 1
    fi

    # Extract individual statistics
    CPU=$(echo $TOP_OUTPUT | awk '{print $1}')
    MEM=$(echo $TOP_OUTPUT | awk '{print $2}')
    DISK_READ=$(echo $TOP_OUTPUT | awk '{print $3}')
    DISK_WRITE=$(echo $TOP_OUTPUT | awk '{print $4}')

    # Append statistics to output file
    echo "$TIME, $CPU, $MEM, $DISK_READ, $DISK_WRITE" >> $OUTPUT_FILE

    # Wait for specified delay before collecting next set of statistics
    sleep $DELAY
done

