#!/usr/bin/env python3

import sys
import os
import json
from datetime import datetime


def is_json_file(file_path):
    with open(file_path, "r") as f:
        try:
            json.load(f)
            return True
        except json.JSONDecodeError:
            return False


if len(sys.argv) < 2:
    print("Error: Please provide the file name to process as a command-line argument")
    print("Usage: {} <file_name>".format(sys.argv[0]))
    sys.exit(1)

input_file = sys.argv[1]

if not os.path.isfile(input_file):
    print("Error: File {} not found".format(input_file))
    sys.exit(1)

num_cpu_cores = os.cpu_count()

if is_json_file(input_file):
    with open(input_file, "r") as f:
        data = json.load(f)
    data = [{"CPU": r["CPU"], "Memory": r["Memory"], "Disk Read": r["Disk Read"], "Disk Write": r["Disk Write"]} for r in data]
else:
    with open(input_file, "r") as f:
        lines = f.readlines()
    lines = lines[1:]  # Remove header
    data = [{"CPU": float(cols[1]), "Memory": float(cols[2]), "Disk Read": float(cols[3]), "Disk Write": float(cols[4])} for cols in (l.strip().split(", ") for l in lines)]

cpu_total = 0
mem_total = 0
disk_read_total = 0
disk_write_total = 0
count = 0

start_time = datetime.now()

for record in data:
    cpu = float(record["CPU"])
    mem = float(record["Memory"])
    disk_read = float(record["Disk Read"])
    disk_write = float(record["Disk Write"])

    cpu_total += cpu
    mem_total += mem
    disk_read_total += disk_read
    disk_write_total += disk_write

    count += 1
    progress = (count / len(data)) * 100
    print(f"Processing: {progress:.2f}%", end="\r")

print("")  # Move to the next line after the progress bar

if count > 0:
    cpu_avg = cpu_total / count
    cpu_avg_per_core = cpu_avg / num_cpu_cores
    mem_avg = mem_total / count
    disk_read_avg = disk_read_total / count
    disk_write_avg = disk_write_total / count

    print(f"Average CPU usage: {cpu_avg:.2f} % (total)")
    print(f"Average CPU usage per core: {cpu_avg_per_core:.2f} %")
    print(f"Average memory usage: {mem_avg:.2f} %")
    print(f"Average disk read rate: {disk_read_avg:.2f} KB/s")
    print(f"Average disk write rate: {disk_write_avg:.2f} KB/s")
else:
    print("No data available to calculate averages.")

