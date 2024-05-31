#!/bin/bash

# Function to check if the current user is a mentee
is_mentee() {
    current_user=$(whoami)
    grep -q "^$current_user " /path/to/menteesDetails.txt
}

# Function to check if the current user is a mentor
is_mentor() {
    current_user=$(whoami)
    grep -q "^$current_user " /path/to/mentorsDetails.txt
}

# If the current user is not a mentee, exit
if ! is_mentee && ! is_mentor; then
    echo "This script can only be executed by mentees or mentors."
    exit 1
fi

if is_mentee; then
    current_user=$(whoami)
    mentee_home=$(eval echo ~$current_user)
    core_home=$(eval echo ~core)
    
    read -p "Enter task number (e.g., task1, task2, task3): " task
    read -p "Enter domain (Webdev, Appdev, Sysad): " domain
    
    task_dir="$mentee_home/$domain/$task"
    mkdir -p "$task_dir"
    
    read -p "Enter task details: " task_details
    echo "$task_details" > "$task_dir/task.txt"
    
    echo "$task - $domain" >> "$mentee_home/task_submitted.txt"
    
    echo "$current_user - $task - $domain" >> "$core_home/mentees_domain.txt"
    
    echo "Task $task submitted in domain $domain."

elif is_mentor; then
    current_user=$(whoami)
    core_home=$(eval echo ~core)
    
    mentor_domain=$(grep "^$current_user " /path/to/mentorsDetails.txt | cut -d ' ' -f2)
    mentor_home=$(eval echo ~$current_user)
    
    while IFS= read -r line; do
        mentee=$(echo $line | cut -d ' ' -f1)
        mentee_rollno=$(echo $line | cut -d ' ' -f2)
        
        mentee_home=$(eval echo ~$mentee_rollno)
        
        for task in task1 task2 task3; do
            task_dir="$mentee_home/$mentor_domain/$task"
            if [ -d "$task_dir" ]; then
                ln -s "$task_dir" "$mentor_home/submittedTasks/$task"
                if [ "$(ls -A $task_dir)" ]; then
                    echo "$task - completed" >> "$mentee_home/task_completed.txt"
                else
                    echo "$task - not completed" >> "$mentee_home/task_completed.txt"
                fi
            fi
        done
    done < "$mentor_home/allocatedMentees.txt"
    
    echo "Mentor tasks checked and symlinked."
fi

