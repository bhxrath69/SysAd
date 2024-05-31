#!/bin/bash

is_core() {
    [ "$(whoami)" = "core" ]
}

if ! is_core; then
    echo "This script can only be executed by the core user."
    exit 1
fi

core_home=$(eval echo ~core)
mentors_home="$core_home/mentors"
mentees_home="$core_home/mentees"
domain_file="$core_home/mentees_domain.txt"

declare -A mentor_capacity
declare -A mentor_assigned

while IFS= read -r line; do
    mentor=$(echo $line | cut -d ' ' -f1)
    domain=$(echo $line | cut -d ' ' -f2)
    capacity=$(echo $line | cut -d ' ' -f3)
    mentor_capacity["$mentor"]=$capacity
    mentor_assigned["$mentor"]=0
done < mentorDetails.txt

while IFS= read -r line; do
    rollno=$(echo $line | cut -d ' ' -f1)
    domains=($(echo $line | cut -d ' ' -f2-))
    assigned=false
    for domain in "${domains[@]}"; do
        for mentor_dir in "$mentors_home/$domain"/*; do
            mentor=$(basename "$mentor_dir")
            if [ "${mentor_assigned[$mentor]}" -lt "${mentor_capacity[$mentor]}" ]; then
                echo "$rollno" >> "$mentor_dir/allocatedMentees.txt"
                ((mentor_assigned[$mentor]++))
                assigned=true
                break
            fi
        done
        if $assigned; then
            break
        fi
    done
done < "$domain_file"

