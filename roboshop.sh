#!/bin/bash

AMI_ID=""
SG_ID=""

for instance in $@
do 

INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0e09997fe1acc7cb9 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

if [ $instance != "frontend" ]; then
    IP=


done
