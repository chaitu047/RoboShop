#!/bin/bash

TIMESTAMP=$(date +%F-%H-%M-%S)

PWD=$(pwd)

echo "Configuring web server --- $TIMESTAMP"

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

dnf install nginx -y

VALIDATE $? "Nginx installation"

systemctl enable nginx

VALIDATE $? "Nginx enabled"

systemctl start nginx

VALIDATE $? "Nginx started"

rm -rf /usr/share/nginx/html/*

VALIDATE $? "Remove default nginx files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "download web server files"

cd /usr/share/nginx/html

VALIDATE $? "change directory to /usr/share/nginx/html"

unzip /tmp/web.zip

VALIDATE $? "unzip downloaded web server files"

touch /etc/nginx/default.d/roboshop.conf

VALIDATE $? "create nginx config"

cd $PWD

VALIDATE $? "change to git directory"

cat nginx-conf >> /etc/nginx/default.d/roboshop.conf

VALIDATE $? "configure nginx"

systemctl restart nginx 

VALIDATE $? "configure nginx"







