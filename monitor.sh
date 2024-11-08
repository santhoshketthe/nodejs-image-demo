#!/bin/bash

# Get the current date and time
current_date_time=$(date '+%Y-%m-%d %H:%M:%S')

# Define the output file
output_file="logreport.csv"

# Start the report with headers
echo "Section,Data" > $output_file
echo "Generated on,$current_date_time" >> $output_file

# Function to format Docker Stats
format_docker_stats() {
    ssh -i "jenkins23.pem" ec2-user@15.207.72.81 "docker stats --no-stream" | awk '
        NR==1 {gsub(" +", ","); print "Docker Stats," $0}
        NR>1 {gsub(" +", ","); print "," $0}
    ' >> $output_file
}

# Function to format Docker Containers
format_docker_containers() {
    ssh -i "jenkins23.pem" ec2-user@15.207.72.81 "docker ps -a" | awk '
        NR==1 {gsub(" +", ","); print "Docker Containers," $0}
        NR>1 {gsub(" +", ","); print "," $0}
    ' >> $output_file
}

# Function to format Memory Usage
format_memory_usage() {
    ssh -i "jenkins23.pem" ec2-user@15.207.72.81 "free -h" | awk '
        NR==1 {gsub(" +", ","); print "Memory Usage," $0}
        NR>1 {gsub(" +", ","); print "," $0}
    ' >> $output_file
}

# Function to format Disk Usage
format_disk_usage() {
    ssh -i "jenkins23.pem" ec2-user@15.207.72.81 "df -h" | awk '
        NR==1 {gsub(" +", ","); print "Disk Usage," $0}
        NR>1 {gsub(" +", ","); print "," $0}
    ' >> $output_file
}

# Generate the report sections
format_docker_stats
format_docker_containers
format_memory_usage
format_disk_usage

echo "Report saved to $output_file"

