#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log "

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m" 
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if [ "$USERID" -ne 0 ]; then
    echo -e "$IMESTAMP [ERROR] $R Please run the script with root access $N " | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];then
        echo -e "$TIMESTAMP [ERROR] $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$TIMESTAMP [INFO] $2 $G SUCCESS $N"  | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y    &>> $LOGS_FILE
dnf module enable nodejs:20 -y  &>> $LOGS_FILE
dnf install nodejs -y           &>> $LOGS_FILE
VALIDATE $? "Disable the old version and enable and install the latest version"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0  ]; then    
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>> $LOGS_FILE
    VALIDATE $? "Creating user"
else
    echo "Creating roboshop user already created ... SKIPPING"
fi


mkdir  -p  /app   &>> $LOGS_FILE # where we need to store the application code ..
VALIDATE $? "Creating the directory called App" 