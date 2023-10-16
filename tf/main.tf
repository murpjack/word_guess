terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_security_group" "allow_tls" {
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.134.202.30/32"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
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
    Name = "allow_tls"
  }
}

resource "aws_instance" "ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = var.should_use_public_ip

  vpc_security_group_ids = [
    aws_security_group.allow_tls.id,
  ]

  user_data = file("ec2-user-data.sh")

  root_block_device {
    delete_on_termination = true
    iops                  = 150
    volume_size           = 8
    volume_type           = "gp3"
  }

  tags = {
    Name        = "server_dev"
    Environment = "dev"
    OS          = "Amazon Linux 2023"
  }

  depends_on = [aws_security_group.allow_tls]
}


output "ec2instance" {
  value = aws_instance.ec2.public_ip
}
