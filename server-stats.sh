#!/bin/bash

prev_idle=0
prev_total=0

while true
do

clear
#cpu
cpu=($(grep '^cpu ' /proc/stat))

user=${cpu[1]}
nice=${cpu[2]}
system=${cpu[3]}
idle=${cpu[4]}
iowait=${cpu[5]}
irq=${cpu[6]}
softirq=${cpu[7]}
steal=${cpu[8]}
guest=${cpu[9]}
guest_nice=${cpu[10]}

total=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))

diff_idle=$((idle - prev_idle))
diff_total=$((total - prev_total))

cpu_usage_percentage=$(((diff_total - diff_idle) * 100 / diff_total))

prev_idle=$idle
prev_total=$total

#memory
mem=($(grep -A 2 "MemTotal" /proc/meminfo | grep -o "[0-9]\+"))

mem_total=${mem[0]}
mem_avai=${mem[2]}
mem_usage_percentage=$(((mem_total - mem_avai) * 100 / mem_total))

#disk
disk_avail=0
disk_used=0
disk_space_avail=($(df | grep / | awk '{print $4}'))
disk_space_used=($(df | grep / | awk '{print $3}'))

for item in "${disk_space_avail[@]}"
do
    disk_avail=$((disk_avail + item))
done

for item in "${disk_space_used[@]}"
do
    disk_used=$((disk_used + item))
done

disk_usage_percentage=$((disk_used * 100 / (disk_used + disk_avail)))

# Output Statistics
echo "======CPU Statistics======"
echo "CPU total: ${diff_total}"
echo "CPU idle: ${diff_idle}"
echo "CPU usage: ${cpu_usage_percentage}%"
echo ""

echo "======Memory Info======"
echo "Memory total: ${mem_total} kB"
echo "Memory available: ${mem_avai} kB"
echo "Memory usage: ${mem_usage_percentage}%"
echo ""

echo "======Disk Info======"
echo "Disk space used: ${disk_used} kB"
echo "Disk space available: ${disk_avail} kB"
echo "Disk usage: ${disk_usage_percentage}%"
echo ""

echo "======Top processes use most cpu and memory======"
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 6 | column -t
echo ""

echo "======OS Statistics======"
hostnamectl | grep -E "Static hostname|Icon name|Machine ID|Virtualization|Operating System|Kernel|Architecture|Hardware Vendor|Hardware Model"

sleep 2
done