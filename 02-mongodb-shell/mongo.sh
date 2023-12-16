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

touch /etc/yum.repos.d/mongo.repo

VALIDATE $? "Add mongo repo"

cat mongo-repo >> /etc/yum.repos.d/mongo.repo

VALIDATE $? "configure mongo repo"

dnf install mongodb-org -y

VALIDATE $? "install mongo server"

systemctl enable mongod

VALIDATE $? "enable mongod"

systemctl start mongod

VALIDATE $? "start mongod"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

VALIDATE $? "change bind ip"

systemctl restart mongod

VALIDATE $? "restart mongod"