terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

########################
# VARIABLES
########################

variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "front_image" {
  type    = string
  default = "trashpanda31/lab04-src-client:latest"
}

variable "back_image" {
  type    = string
  default = "trashpanda31/lab04-src-server:latest"
}

variable "frontend_host_port" {
  type    = number
  default = 80
}

variable "backend_port" {
  type    = number
  default = 4000
}

variable "userdata_rev" {
  type    = number
  default = 1
}

#########################
# NETWORKING
#########################

resource "aws_vpc" "lab" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "lab-04-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab.id
  tags   = { Name = "lab04-igw" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.42.1.0/24"
  map_public_ip_on_launch = true
  tags                    = { Name = "lab04-public-a" }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.42.2.0/24"
  map_public_ip_on_launch = false
  tags                    = { Name = "lab04-private-a" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "lab04-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  tags          = { Name = "lab04-nat" }
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "lab04-rt-public" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "lab04-rt-private" }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

########################
# SECURITY GROUPS
########################

resource "aws_security_group" "frontend" {
  name   = "lab04-frontend-sg"
  vpc_id = aws_vpc.lab.id

  ingress {
    from_port   = var.frontend_host_port
    to_port     = var.frontend_host_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "lab04-frontend-sg" }
}

resource "aws_security_group" "backend" {
  name   = "lab04-backend-sg"
  vpc_id = aws_vpc.lab.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "lab04-backend-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "backend_api_from_frontend" {
  security_group_id            = aws_security_group.backend.id
  referenced_security_group_id = aws_security_group.frontend.id
  ip_protocol                  = "tcp"
  from_port                    = var.backend_port
  to_port                      = var.backend_port
}

########################
# AMI
########################

data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

########################
# EC2 INSTANCES
########################

locals {
  backend_ud = templatefile("${path.module}/usedata-backend.sh", {
    back_image   = var.back_image
    backend_port = var.backend_port
  })

  frontend_ud = templatefile("${path.module}/usedata-frontend.sh", {
    front_image        = var.front_image
    frontend_host_port = var.frontend_host_port
    api_url            = "http://${aws_instance.backend.private_ip}:${var.backend_port}"
  })
}

resource "aws_instance" "backend" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids      = [aws_security_group.backend.id]
  associate_public_ip_address = false
  depends_on = [
    aws_nat_gateway.nat,
    aws_route_table_association.private_a
  ]
  user_data_replace_on_change = true
  user_data                   = "${local.backend_ud}\n# rev=${var.userdata_rev}\n"
  tags                        = { Name = "lab04-backend" }

}

resource "aws_eip" "frontend" {
  domain = "vpc"
  tags   = { Name = "lab04-frontend-eip" }
}

resource "aws_eip_association" "frontend" {
  instance_id   = aws_instance.frontend.id
  allocation_id = aws_eip.frontend.id
}

resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.frontend.id]
  associate_public_ip_address = false
  depends_on = [
    aws_internet_gateway.igw,
    aws_route_table_association.public_a
  ]
  user_data_replace_on_change = true
  user_data                   = "${local.frontend_ud}\n# rev=${var.userdata_rev}\n"

  tags = { Name = "lab04-frontend" }
}
