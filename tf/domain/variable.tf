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
