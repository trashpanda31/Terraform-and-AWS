variable "name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "sg_ids" {
  type = list(string)
}

variable "user_data" {
  type = string
}

variable "allocate_eip" {
  type    = bool
  default = false
}

variable "instance_profile_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
