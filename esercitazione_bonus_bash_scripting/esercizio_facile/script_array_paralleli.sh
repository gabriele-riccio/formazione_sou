#!/usr/bin/env bash

ip_list=()
count_list=()

while IFS= read -r ip; do
    trovato=0
    for i in "${!ip_list[@]}"; do
        if [[ "${ip_list[$i]}" == "$ip" ]]; then
            ((count_list[$i]++))
            trovato=1
            break
        fi
    done
    if [[ $trovato -eq 0 ]]; then
        ip_list+=("$ip")
        count_list+=(1)
    fi
done < accessi.txt

for i in "${!ip_list[@]}"; do
    echo "${count_list[$i]} ${ip_list[$i]}"
done | sort -rn | head -3
