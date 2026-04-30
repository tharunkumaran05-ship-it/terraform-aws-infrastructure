#!/bin/bash
apt update -y
apt install apache2 -y
systemctl start apache2
systemctl enable apache2

echo "<h1>Terraform Infra Working</h1>" > /var/www/html/index.html
echo "<p>AWS + DevOps Project</p>" >> /var/www/html/index.html