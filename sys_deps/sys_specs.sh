#!/bin/bash

# --- Memory Usage ---
# Extracts the "available" memory (column 7) which is the most accurate 
# metric for how much RAM is actually free for new processes.
echo "--- Memory Statistics ---"
free -h | awk '/^Mem:/ {print "Total Memory:     " $2 "\nUsed Memory:      " $3 "\nAvailable Memory: " $7}'

echo ""

# --- Disk Usage ---
# Extracts the available space for the root partition (/).
echo "--- Disk Statistics (Root) ---"
df -h / | awk 'NR==2 {print "Total Size:       " $2 "\nUsed Space:       " $3 "\nAvailable Space:  " $4 "\nUsage Percentage: " $5}'
