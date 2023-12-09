variable "time_to_live" {
  description = "ttl"
  default     = 3600
}

variable "domain_name" {
  description = "a domain name for your troubles"
}

variable "ipv4" {
  description = "For configuring 'A record'"
  default     = "Parked"
}

variable "overwrite_existing" {
  description = "If one already exists then overwrite"
  default     = true
}

variable "name_server_1" {
  description = "Where your domain is stored"
}

variable "name_server_2" {
  description = "Where your domain is stored"
}

