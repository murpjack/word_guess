terraform {
  required_providers {
    godaddy = {
      source  = "n3integration/godaddy"
      version = "1.9.1"
    }
  }
}

resource "godaddy_domain_record" "app_domain" {
  domain = var.domain_name

  record {
    type = "A"
    name = "@"
    data = var.ipv4
    ttl  = var.time_to_live
  }

  record {
    type     = "NS"
    name     = "@"
    data     = var.name_server_1
    ttl      = var.time_to_live
    priority = 10
  }

  record {
    type     = "NS"
    name     = "@"
    data     = var.name_server_2
    ttl      = var.time_to_live
    priority = 10
  }

  record {
    type = "CNAME"
    name = "app"
    data = var.domain_name
    ttl  = var.time_to_live
  }

  record {
    type = "CNAME"
    name = "_domainconnect"
    data = "_domainconnect.gd.domaincontrol.com"
  }

  record {
    type = "SOA"
    name = "@"
    data = "Primary nameserver: ns33.domaincontrol.com"
  }
}

