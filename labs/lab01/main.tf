terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "lab" {
  type    = string
  default = "lab01"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "az_suffix" {
  type    = string
  default = "a"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = null
}

provider "aws" {
  region = var.region
}

locals {
  name_prefix = "iac-${var.lab}"
  tags = {
    Project = "IAC-Labs"
    Lab     = var.lab
  }
}

resource "aws_vpc" "vpc_lab01" {
  cidr_block = var.vpc_cidr
  tags       = merge(local.tags, { Name = "${local.name_prefix}-vpc" })
}

resource "aws_internet_gateway" "igw_lab01" {
  vpc_id = aws_vpc.vpc_lab01.id
  tags   = merge(local.tags, { Name = "${local.name_prefix}-igw" })
}

resource "aws_subnet" "public_subnet_lab01" {
  vpc_id                  = aws_vpc.vpc_lab01.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 2, 0)
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}${var.az_suffix}"
  tags                    = merge(local.tags, { Name = "${local.name_prefix}-public-${var.az_suffix}" })
}

resource "aws_route_table" "public_route_lab01" {
  vpc_id = aws_vpc.vpc_lab01.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_lab01.id
  }
  tags = merge(local.tags, { Name = "${local.name_prefix}-rtb-public" })
}

resource "aws_route_table_association" "public_assoc_lab01" {
  subnet_id      = aws_subnet.public_subnet_lab01.id
  route_table_id = aws_route_table.public_route_lab01.id
}

resource "aws_security_group" "ssh" {
  name   = "${local.name_prefix}-ssh"
  vpc_id = aws_vpc.vpc_lab01.id
  ingress {
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
  tags = local.tags
}

data "aws_ssm_parameter" "al2023_x86" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_instance" "vm" {
  ami                    = data.aws_ssm_parameter.al2023_x86.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet_lab01.id
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name               = var.key_name
  tags                   = merge(local.tags, { Name = "${local.name_prefix}-vm" })
}
