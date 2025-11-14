variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "front_image" {
  type    = string
  default = "trashpanda31/lab05-frontend:latest"
}

variable "back_image" {
  type    = string
  default = "trashpanda31/lab05-backend:latest"
}

variable "frontend_port" {
  type    = number
  default = "80"
}

variable "backend_port" {
  type    = number
  default = "5000"
}

variable "database_url" {
  type    = string
  default = ""
}

variable "project" {
  type    = string
  default = "lab05"
}

variable "userdata_rev" {
  type    = string
  default = "0"
}


