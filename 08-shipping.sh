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

dnf install maven -y &>> LOGS_FILE
VALIDATE $? "Installing Maven"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0  ]; then    
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>> $LOGS_FILE
    VALIDATE $? "Creating user"
else
    echo "Creating roboshop user already created ... SKIPPING"
fi

rm -rf /app
VALIDATE $? "Removing the existing code"

rm -rf /tmp/shipping.zip
VALIDATE $? "Removing shipping zip"

mkdir  -p  /app   &>> $LOGS_FILE # where we need to store the application code ..
VALIDATE $? "Creating the directory called App" 

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
cd /app 
unzip /tmp/shipping.zip &>> $LOGS_FILE
VALIDATE $? "Downloaded and extracted shipping code"


mvn clean package &>> $LOGS_FILE
mv target/shipping-1.0.jar shipping.jar 
VALIDATE $?  "Installing Dependencies"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Created systemctl service"

dnf install mysql -y &>> $LOGS_FILE
VALIDATE $? "Installing Mysql client"

mysql -h "$MYSQL_HOST" -u root -pRoboShop@1 -e "use cities" &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    mysql -h "$MYSQL_HOST" -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h "$MYSQL_HOST" -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h "$MYSQL_HOST" -uroot -pRoboShop@1 < /app/db/master-data.sql
    VALIDATE $? "Data loaded "
else
    echo  -e "Data already loaded  ... $y SKIPPING $n"
fi

systemctl enable shipping 
systemctl restart shipping
VALIDATE $? "Enable and restarted shipping"