###########
# Secrets #
###########

# DO API on Digital Ocean

variable "digitalocean_token" {
  description = "Digital Ocean access token"
}

variable "ssh_public_key_file" {
  description = "ssh public key file"
}

variable "ssh_priv_key_file" {
  description = "ssh key file"
}

