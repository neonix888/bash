# BASH script to collect utilization of a process

    echo "Usage: $0 -p <PID> [-o output_file] [-d duration] [-s delay]"
    echo "  -p: Process ID (required)"
    echo "  -o: Output file name (default: process_stats.txt)"
    echo "  -d: Duration in seconds (default: 1800)"
    echo "  -s: Delay between updates in seconds (default: 1)"

Ex: ./hughps.sh -p 125584 -o test.txt -d 60 -s 1
