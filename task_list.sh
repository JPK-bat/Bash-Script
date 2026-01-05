#!/bin/bash 
# Print server time
echo "Server Time : $(date +"%Y-%m-%d %H:%M:%S %Z")" 

echo "----------------------------------------------------" 
# Get all task List 

aws ecs describe-tasks --cluster "cluste_name" --tasks $(aws ecs list-tasks --cluster "cluster_name" --query 'taskArns[]' --output text) --query 'tasks[*].[taskArn,group]' --output text | awk -F'/' '{split($2, a, ":"); if(a[2]) print "Service Name: " a[2] ", Task ID: " $NF; else print "Task ID: " $NF}'
