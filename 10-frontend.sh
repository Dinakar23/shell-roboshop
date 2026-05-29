#!/bin/bash

LOGS_FOLDER="/var/log/roboshop"
sudo mkdir -p $LOGS_FOLDER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log "
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.dinakardevops.online

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

dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y
VALIDATE $? "Installing Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removed defalut code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "Download and extracted frontend code"

rm -rf /etc/nginx/nginx/conf
VALIDATE $? "Removed defalut conf"

cp SCRIPT_DIR nginx.cong /etc/nginx/nginx/conf
VALIDATE $? "Copied roboshop nginx conf"

systemctl restart nginx 
systemctl enable nginx
VALIDATE $? "Restart Nginx"
