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
    docker = {
      source = "terraform-providers/docker"
    }
  }
}

data "terraform_remote_state" "kibana-elastic" {
  backend = "local"
  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}

provider "docker" {
  host = "ssh://root@${data.terraform_remote_state.kibana-elastic.outputs.kibana-elastic-ip}:22"
}

