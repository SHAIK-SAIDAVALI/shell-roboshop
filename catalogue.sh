#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f3 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MONGODB_HOST=mongodb.daws86a.store
SCRIPT_DIR=$PWD

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

##Node Js Setup ##

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling Nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

##system user setup##
id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
    else 
        echo -e "user already exists....$Y SKIPPING $N"
fi

 ###setup of app directory ##

mkdir -p /app 
VALIDATE $? "Creating App directory"

##Downloading the App code ##

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "downloading the app code"

cd /app 
VALIDATE $? "changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing the old code"

unzip /tmp/catalogue.zip
VALIDATE $? "Unzip catalogue"

npm install  &>>$LOG_FILE
VALIDATE $? "installing dependecies"


cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copy systemctl service"

systemctl daemon-reload
VALIDATE $? "reloading deamon"


systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enable catalogue"



cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copy mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "install mongodb client"


mongosh --host $MONGODB_HOST </app/db/master-data.js
VALIDATE $? "load catalogue products"

systemctl restart catalogue
VALIDATE $? "restarting catalogue"
