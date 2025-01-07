#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\E[0m"

LOGS_FOLDER="/var/log/expenses-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
        then    
                echo -e "$2...$R failure $N"
                exit 1
     else
        echo -e "$2...$G success $N"

     fi              
}
CHECK_ROOT(){
    if [ $USERID -ne 0 ]
      then
            echo "error : you must have root access"
            exit 1
     fi       
}
mkdir -p $LOGS_FOLDER 
echo "script executed at :$TIMESTAMP" &>>$LOG_FILE_NAME
CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "enabling nginx"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "removing existing verision of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "downloading frontend code"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "moving to html directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzipping frontend code"
 
cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
VALIDATE $? "copied expense config"

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "restarting nginx"