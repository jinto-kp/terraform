provider "aws" {
  region = "ap-southeast-1"
  access_key = "AKIAQLFJ73WDJ5IOQYNB"
  secret_key = "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"
}

resource "aws_key_pair" "webserver-key" {
  key_name   = "webserver-key"
  public_key = file("~/.ssh/id_rsa.pub")
  #provider   = aws.oregon
}


resource "aws_security_group" "my-secnew" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "test-SG"
  }
  #provider = aws.oregon
}

// Key


// AMI

data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

output "test" {
  value = data.aws_ami.ubuntu
}


// EC2 Instance

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my-secnew.id]
  key_name             = aws_key_pair.webserver-key.key_name
  # user_data              = file("install_apache.sh")
  #provider               = aws.oregon


  # user_data              = <<-EOT
  #                                     #! /bin/bash
  #                                     sudo yum -y update
  #                                     sudo yum -y install httpd && sudo systemctl start httpd && sudo systemctl enable httpd
  #                                     echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
  #                          EOT

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo yum -y install httpd && sudo systemctl start httpd",
  #     "echo '<h1><center>My Test Website With Help From Terraform Provisioner</center></h1>' > index.html",
  #     "sudo mv index.html /var/www/html/"
  #   ]
  #   connection {
  #     type        = "ssh"
  #     user        = "ec2-user"
  #     private_key = file("~/.ssh/id_rsa")
  #     host        = aws_instance.web.public_ip
  #   }
  # }

   provisioner "local-exec" {
     command = "echo server private IP address is ${self.private_ip}"
   #  command = "echo server Public IP address is ${self.public_ip}"
   }

  # provisioner "file" {
  #   source      = "./install_apache.sh"
  #   destination = "/home/ec2-user/install_apache.sh"

  #   connection {
  #     type        = "ssh"
  #     user        = "ec2-user"
  #     private_key = file("~/.ssh/id_rsa")
  #     host        = aws_instance.web.public_ip
  #   }
  # }

  tags = {
    Name = "ubuntu-server"
  }
}
