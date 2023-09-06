terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.29"
    }
  }
}


provider "digitalocean" {
  token = var.do_token
}


resource "digitalocean_app" "my-app" {
  spec {
    name   = "static-app"
    region = "lon"

    static_site {
      name          = "wordguess"
      build_command = "yarn & yarn build:prod"

      github {
        repo = "murpjack/word_guess"
        branch         = "deploy"
        deploy_on_push = true
      }
    }
  }
}
