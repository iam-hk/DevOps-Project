#!/bin/bash
sudo dnf update -y
sudo dnf install mariadb105 -y

sudo dnf update -y
sudo dnf install -y httpd php php-mysqli mariadb105
sudo systemctl start httpd
sudo systemctl enable httpd
sudo bash -c 'echo Bastion server for Database subnet RDS > /var/www/html/index.html'