terraform {
  required_version = ">= 0.14"
  
  backend "local" {}

    /*backend "remote" {
    organization = "lancey"

    workspaces {
      prefix = "v2-"
    }
  }
  */
 
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "digitalocean" {
 # version = ">= 1.9.1"
  # main access is configured with the DIGITALOCEAN_TOKEN environment variable
  token = var.digitalocean_token
}

provider "local" {
 # version = "~> 1.4.0"
}

provider "null" {
 # version = "~> 2.1.2"
}
