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

if [ ! -d "/var/log/roboshop/"]
then
    mkdir -p "/var/log/roboshop/"

    VALIDATE $? "RoboShop directory creation"
fi

exec &> $LOGFILE

if [ $(id -u) -ne 0 ]
then
    echo "ERROR:: Not root user"
    exit 1
fi

yum update -y

VALIDATE $? "yum update"

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

VALIDATE $? "install redis repo"

dnf module enable redis:remi-6.2 -y

VALIDATE $? "enable redis:6.2 version to install"

dnf install redis -y

VALIDATE $? "install redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf

VALIDATE $? "configure source IP"

systemctl enable redis

VALIDATE $? "enable redis"

systemctl start redis

VALIDATE $? "start redis"