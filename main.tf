terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

# Create a VPC
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}
resource "aws_instance" "myec2" {  
      ami           = "ami-024f768332f080c5e"  
      instance_type = "t2.micro"  
      subnet_id      = aws_subnet.public_subnet.id
            user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker -y
              service docker start
              docker run -d -p 80:9898 stefanprodan/podinfo
              EOF
    }

resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.vpc1.id

  # Allow HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}