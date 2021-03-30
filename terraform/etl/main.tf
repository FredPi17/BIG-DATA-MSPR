terraform {
  required_version = ">= 0.14"
  
  backend "local" {}

  required_providers {
    null = {
      source = "hashicorp/null"
    }
    docker = {
      source = "terraform-providers/docker"
    }
  }
}

data "terraform_remote_state" "logstash" {
  backend = "local"
  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}

provider "docker" {
  host = "ssh://root@${data.terraform_remote_state.logstash.outputs.kibana-elastic-ip}:22"
}

provider "null" {
 # version = "~> 2.1.2"
}
