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
echo "script executed at :$TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "disabling nodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "enabling nodeJS 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "installing nodeJS 20"

id expense
if [ $? -ne 0 ]
 then
    useradd expense
    VALIDATE $? "adding expense user"
 else
    echo -e "expense user already exists $Y ... SKKIPPING $N"
fi
mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "creating folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "downloading backend"

cd /app

rm -rf /app/*

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip backend"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
#preparing schema

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "installing mysql client"

mysql -h mysql.shabbupractice.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "settingup transactions schema"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "sdeamon-reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "enabling backend"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "restarting backend"