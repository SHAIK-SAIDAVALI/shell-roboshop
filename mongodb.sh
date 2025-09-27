#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f2 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script started executed at: $(date)" | tee -a $LOG_FILE
if [ $USERID -ne 0 ]; then
    echo " $R Error: Please run this script with root privilege $Y "
    exit 1 # failure is other than 0
fi
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "Error:  $2.... $R Failure $N"
        exit 2 

    else 
        echo -e " $2...  $G success $N"
    fi
}

cp mongo.repo  vim /etc/yum.repos.d/mongo.repo
VALIDATE $? "adding Mongo Repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing Mongo Db"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabiling MongoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Start Mongodb"


