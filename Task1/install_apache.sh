#! /bin/bash
sudo yum -y update
sudo yum -y install httpd && sudo systemctl start httpd && sudo systemctl enable httpd
echo "<h1>Welcome to MY Terraform</h1>" | sudo tee /var/www/html/index.html