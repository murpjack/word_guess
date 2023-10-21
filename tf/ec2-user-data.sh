#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd
yum install unzip

systemctl start httpd
systemctl enable httpd

BUCKET=arn:aws:s3:::infra-1
PATH_TO_KEY='app/dist_dir.zip'
OUT_FILE=dist_dir.zip

/usr/local/bin/aws s3api get-object --bucket $BUCKET --key $PATH_TO_KEY $OUT_FILE

unzip $OUT_FILE -l -o -d /var/www/html/

# echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
# cp --verbose --update -r -t /var/www/html $/*
