terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.32.0"
    }
  }
}

resource "digitalocean_domain" "default" {
  name = var.domain_name
}

# Add an A record to the domain for www.example.com.
resource "digitalocean_record" "ipv4" {
  domain = digitalocean_domain.default.id
  type   = "A"
  name   = "@"
  value  = var.ipv4
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.default.id
  type   = "CNAME"
  name   = "www"
  value  = "${var.domain_name}."
}

# Add a MX record for the example.com domain itself.
resource "digitalocean_record" "ns1" {
  domain   = digitalocean_domain.default.id
  type     = "NS"
  name     = "@"
  priority = 10
  value    = "ns1.digitalocean.com."
}

# Add a MX record for the example.com domain itself.
resource "digitalocean_record" "ns2" {
  domain   = digitalocean_domain.default.id
  type     = "NS"
  name     = "@"
  priority = 10
  value    = "ns2.digitalocean.com."
}

# Add a MX record for the example.com domain itself.
resource "digitalocean_record" "ns3" {
  domain   = digitalocean_domain.default.id
  type     = "NS"
  name     = "@"
  priority = 10
  value    = "ns3.digitalocean.com."
}

