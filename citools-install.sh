#!/usr/bin/env bash

sudo yum update -y

sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

sudo yum remove java-1.7.0-openjdk
sudo yum install docker nginx git jenkins java-1.8.0 -y

sudo service docker start

sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker jenkins

sudo truncate -s 0 /etc/nginx/nginx.conf

echo "
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;
    server {
        listen 80;
        server_name _;
        location / {
            proxy_pass http://127.0.0.1:8080;
        }
    }
}
" >> /etc/nginx/nginx.conf

sudo service jenkins start
sudo service nginx start

sudo chkconfig jenkins on
sudo chkconfig nginx on

# Maven Setup
sudo yum install java-1.7.0-openjdk
sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install -y apache-maven
echo "export M3_HOME=/usr/share/apache-maven" >> ~/.bashrc
echo "export PATH=$PATH:$M3_HOME/bin" >> ~/.bashrc
mvn --version

