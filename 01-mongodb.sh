#!/bin/bash
LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log "
TIMESTAMP=$( date "+%Y-%m-%d %H:%M:%S")

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m" 
N="\e[0m"

if [ "$USERID" -ne 0 ]; then
    echo " $IMESTAMP [ERROR] Please run the script with root access " | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];then
        echo -e " $IMESTAMP [ERROR] $2 ... $R FAILURE $N " | tee -a $LOGS_FILE
    else
        echo -e "$IMESTAMP [INFO] $G SUCCESS $N "  | tee -a $LOGS_FILE

}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"
