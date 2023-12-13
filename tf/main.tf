terraform {
  backend "s3" {
    bucket = "infra-1"
    key    = "network/terraform.tfstate"
    region = "eu-west-2"
  }
}

module "app" {
  source               = "./app"
  ami                  = var.ami
  region               = var.region
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  vpc                  = var.vpc
}

module "domain" {
  source      = "./domain"
  domain_name = var.domain_name
  ipv4        = module.app.ec2_instance
}

module "cert" {
  source             = "./cert"
  domain_name        = var.domain_name
  registration_email = var.registration_email
}
