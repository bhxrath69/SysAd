#!/bin/bash

# Remove mentee users and their home directories
while IFS= read -r line; do
    rollno=$(echo $line | cut -d ' ' -f1)
    sudo userdel -r $rollno
    echo "Mentee with Roll No: $rollno removed"
done < menteeDetails.txt

# Remove mentor users and their home directories
while IFS= read -r line; do
    mentor=$(echo $line | cut -d ' ' -f1)
    domain=$(echo $line | cut -d ' ' -f2)
    sudo userdel -r $mentor
    echo "Mentor $mentor from domain $domain removed"
done < mentorDetails.txt

# Remove Core user and home directory
sudo userdel -r core
echo "Core user removed"

# Remove any remaining directories under the core's home directory
core_home=$(eval echo ~core)
if [ -d "$core_home" ]; then
    sudo rm -rf $core_home
    echo "Core home directory removed"
fi

