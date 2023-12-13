variable "ami" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "should_use_public_ip" {
  type    = bool
  default = true
}

variable "vpc" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "registration_email" {
  description = "Email used to verify domain ownership"
}
