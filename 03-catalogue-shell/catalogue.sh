#!/bin/bash

TIMESTAMP=$(date +%F-%H-%M-%S)

PWD=$(pwd)

echo "Configuring catalogue server --- $TIMESTAMP"

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
        echo "$R failed $N - $2"
        exit 1
    fi
}

if [ ! -d "/var/log/roboshop/" ]
then
    mkdir -p "/var/log/roboshop/"

    VALIDATE $? "RoboShop directory creation"
fi

exec &> LOGFILE

if [ $(id -u) -ne 0 ]
then
    echo "ERROR:: Not root user"
    exit 1
fi

MONGO_IP=$(cat MONGO-IP)

dnf module disable nodejs -y

VALIDATE $? "disable NodeJs default version"

dnf module enable nodejs:18 -y

VALIDATE $? "enable NodeJs:18 version"

dnf install nodejs -y

VALIDATE $? "NodeJs:18 Installation"

useradd roboshop

VALIDATE $? "roboshop user added"

mkdir /app

VALIDATE $? "create /app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "download source code for catalogue server"

cd /app

VALIDATE $? "change to /app directory"

npm install

VALIDATE $? "npm install"

touch /etc/systemd/system/catalogue.service

VALIDATE $? "create service config for cataloue"

cd $PWD

sed -i "s/<MONGODB-SERVER-IPADDRESS>/$MONGO_IP/g" catalogue-conf

VALIDATE $? "change to git directory"

cat catalogue-conf >> /etc/systemd/system/catalogue.service

VALIDATE $? "create config file for catalogue service"

systemctl daemon-reload

VALIDATE $? "daemon-reload"

systemctl enable catalogue

VALIDATE $? "enable service catalogue"

systemctl start catalogue

VALIDATE $? "start service catalogue"

touch /etc/yum.repos.d/mongo.repo

cat mongo-repo >> /etc/yum.repos.d/mongo.repo

VALIDATE $? "Add mongo-client repo"

dnf install mongodb-org-shell -y

VALIDATE $? "Install mongodb-org-shell"

mongo --host $MONGO_IP </app/schema/catalogue.js

VALIDATE $? "load data into mongo-server"