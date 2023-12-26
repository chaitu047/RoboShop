#!/bin/bash

TIMESTAMP=$(date +%F-%H-%M-%S)

PWD=$(pwd)

echo "Configuring mysql server --- $TIMESTAMP"

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
    sudo mkdir -p "/var/log/roboshop/"

    VALIDATE $? "RoboShop directory creation"
fi

sudo exec &> $LOGFILE

if [ $(id -u) -ne 0 ]
then
    echo "ERROR:: Not root user"
    exit 1
fi

sudo yum update -y
0
VALIDATE $? "yum update"

sudo touch /etc/yum.repos.d/mysql.repo

VALIDATE $? "Add mysql repo"

sudo cat mysql-repo > /etc/yum.repos.d/mysql.repo

VALIDATE $? "Configure mysql repo"

sudo yum install mysql -y

VALIDATE $? "Install mysql"

sudo systemctl enable mysqld

VALIDATE $? "enable mysqld service"

sudo systemctl start mysqld

VALIDATE $? "start mysqld service"

sudo mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE $? "set mysql root password"