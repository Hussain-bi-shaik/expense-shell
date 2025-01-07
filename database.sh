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
dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "mysql installation is"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "enabling mysql server"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "starting mysql server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "stetting root password"

mysql -h <mysql.shabbupractice.online> -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
    then
         echo "my sql root password is not setup" &>>$LOG_FILE_NAME
      else
        echo -e "mysql root password is already setup $Y skipping $N"
 fi
