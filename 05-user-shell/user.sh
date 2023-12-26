#!/bin/bash

TIMESTAMP=$(date +%F-%H-%M-%S)

PWD=$(pwd)

echo "Configuring redis server --- $TIMESTAMP"

LOGFILE="/var/log/roboshop/$0-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){

    if [ $1 -eq 0 ]
    then
        echo "$G success $N - $2"
    else
        echo "$R success $N - $2"
        exit 1
    fi
}

if [ ! -d "/var/log/roboshop/" ]
then
    mkdir -p "/var/log/roboshop/"

    VALIDATE $? "RoboShop directory creation"
fi

exec &>> $LOGFILE

if [ $(id -u) -ne 0 ]
then
    echo "ERROR:: Not root user"
    exit 1
fi

yum update -y

VALIDATE $? "yum update"

dnf module disable nodejs -y

VALIDATE $? "disable nodejs default version"

dnf module enable nodejs:18 -y

VALIDATE $? "disable nodejs 18 version"

dnf install nodejs -y

VALIDATE $? "install nodejs 18"

useradd roboshop

VALIDATE $? "add user roboshop"

mkdir /app

VALIDATE $? "create /app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip

VALIDATE $? "download bytecode"

cd /app 

VALIDATE $? "change directory to /app"

unzip /tmp/user.zip

VALIDATE $? "unzip downloaded bytecode to /app"

npm install 

VALIDATE $? "install npm"

cp user-service-config /etc/systemd/system/user.service

VALIDATE $? "copy user.service config"

REDIS_IP=$(grep -i 'REDIS_IP' redis-IP | cut -d '=' -f 2)

VALIDATE $? "Retrieve REDIS_IP"

MONGO_IP=$(grep -i 'MONGO_IP' redis-IP | cut -d '=' -f 2)

VALIDATE $? "Retrieve MONGO_IP"

sed -i "s/<REDIS-SERVER-IP>/$REDIS_IP/g" user-service-config

VALIDATE $? "Replace REDIS_IP"

sed -i "s/<MONGODB-SERVER-IP-ADDRESS>/$MONGO_IP/g" user-service-config

VALIDATE $? "configure user.service"

VALIDATE $? "Replace MONGO_IP"

systemctl daemon-reload

VALIDATE $? "reload-daemon"

systemctl enable user

VALIDATE $? "enable user service"

systemctl start user

VALIDATE $? "start user service"

cp mongo-repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copy mongo-repo"

dnf install mongodb-org-shell -y

VALIDATE $? "install mongo-shell"