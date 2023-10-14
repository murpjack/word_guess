variable "ami" {
  type = string
  description = "Amazon Machine Instance - Amazon Linux 2023 AMI (64-bit (x86))"
  default = "ami-0b25f6ba2f4419235"
}

variable "region" {
  type = string
  description = "AWS region - London"
  default = "eu-west-2"
}

variable "vpc" {
  type = string
  default = "vpc-093201a806ce67d38"
}

variable "instance_type" {
  type = string
  description = "Instance Type - t2 | 1vCPU | 1GiB Mem"
  default = "t2.micro"
}

variable "should_use_public_ip" {
  type = bool
  default = true
}

variable "security_group_name" {
  type = string
  default = "default_security_group"
}
