#!/usr/env/bin/ bash
declare -A contatore

while IFS= read -r ip; do
    ((contatore[$ip]++))
done < accessi.txt

for ip in "${!contatore[@]}"; do
    echo "${contatore[$ip]} $ip"
done | sort -rn | head -3
