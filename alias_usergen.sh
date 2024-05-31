#!/bin/bash

# Creating Core user
sudo useradd -m core
core_home=$(eval echo ~core)
sudo mkdir -p $core_home/mentors
sudo mkdir -p $core_home/mentees

# Reading mentor details from mentorDetails.txt
while IFS= read -r line; do
    mentor=$(echo $line | cut -d ' ' -f1)
    domain=$(echo $line | cut -d ' ' -f2)
    sudo useradd -m -d $core_home/mentors/$domain/$mentor $mentor
    sudo mkdir -p $core_home/mentors/$domain/$mentor/submittedTasks/{task1,task2,task3}
    sudo touch $core_home/mentors/$domain/$mentor/allocatedMentees.txt
    echo "Mentor $mentor added to domain $domain"
done < mentorDetails.txt

# Reading mentee details from menteeDetails.txt
while IFS= read -r line; do
    rollno=$(echo $line | cut -d ' ' -f1)
    name=$(echo $line | cut -d ' ' -f2)
    sudo useradd -m -d $core_home/mentees/$rollno $rollno
    sudo touch $core_home/mentees/$rollno/domain_pref.txt
    sudo touch $core_home/mentees/$rollno/task_completed.txt
    sudo touch $core_home/mentees/$rollno/task_submitted.txt
    echo "Mentee $name (Roll No: $rollno) added"
done < menteeDetails.txt

# Permissions
sudo chmod 700 $core_home/mentees/*
sudo chmod 700 $core_home/mentors/*/*

# Core permissions
sudo chmod 755 $core_home/mentees
sudo chmod 755 $core_home/mentors
sudo chmod 755 $core_home

# Core file that mentees can write to
sudo touch $core_home/mentees_domain.txt
sudo chmod 622 $core_home/mentees_domain.txt

