variable "ami" {
  type        = string
  description = "Amazon Machine Instance - Amazon Linux 2023 AMI (64-bit (x86))"
  default     = "ami-030594f92006445fd"
}

variable "region" {
  type        = string
  description = "AWS region - London"
  default     = "eu-west-2"
}

variable "vpc" {
  type    = string
  default = "vpc-093201a806ce67d38"
}

variable "instance_type" {
  type        = string
  description = "Instance Type - t2 | 1vCPU | 1GiB Mem"
  default     = "t2.micro"
}

variable "iam_instance_profile" {
  type        = string
  description = "iam to allow ec2 s3 access"
  default     = "arn:aws:iam::503337729512:role/allow_ec2_s3_full_access"
}

variable "should_use_public_ip" {
  type    = bool
  default = true
}

variable "security_group_name" {
  type    = string
  default = "default_security_group"
}
