#!/bin/bash

# Function to check if the current user is core
is_core() {
    [ "$(whoami)" = "core" ]
}

# If the current user is not core, exit
if ! is_core; then
    echo "This script can only be executed by the core user."
    exit 1
fi

core_home=$(eval echo ~core)
mentors_home="$core_home/mentors"
mentees_home="$core_home/mentees"
status_file="$core_home/display_status_last_run.txt"
current_status_file="$core_home/current_status.txt"

# Initialize current status file
> "$current_status_file"

# List of tasks
tasks=("task1" "task2" "task3")

# Function to calculate submission percentages and details
calculate_status() {
    local domain_filter=$1
    total_mentees=0
    declare -A submitted_tasks

    # Iterate over mentees and count task submissions
    for mentee_dir in "$mentees_home"/*; do
        if [ -d "$mentee_dir" ]; then
            ((total_mentees++))
            for task in "${tasks[@]}"; do
                task_submitted_file="$mentee_dir/task_submitted.txt"
                if grep -q "$task" "$task_submitted_file"; then
                    if [ -z "$domain_filter" ] || grep -q "$domain_filter" "$task_submitted_file"; then
                        ((submitted_tasks["$task"]++))
                    fi
                fi
            done
        fi
    done

    # Display results
    for task in "${tasks[@]}"; do
        submitted_count=${submitted_tasks["$task"]}
        percentage=0
        if [ "$total_mentees" -gt 0 ]; then
            percentage=$((submitted_count * 100 / total_mentees))
        fi
        echo "$task: $submitted_count out of $total_mentees mentees submitted ($percentage%)" | tee -a "$current_status_file"
    done
}

# Function to display new submissions since last run
display_new_submissions() {
    if [ -f "$status_file" ]; then
        echo "New submissions since last run:"
        diff "$status_file" "$current_status_file" | grep '>' | sed 's/> //'
    else
        echo "This is the first run, no previous data to compare."
    fi
}

# Check if domain filter is provided
domain_filter=""
if [ "$#" -eq 1 ]; then
    domain_filter=$1
    echo "Filtering by domain: $domain_filter"
fi

# Calculate status
calculate_status "$domain_filter"

# Display new submissions
display_new_submissions

# Update status file
mv "$current_status_file" "$status_file"

