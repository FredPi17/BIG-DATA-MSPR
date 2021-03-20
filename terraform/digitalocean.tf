# All digital ocean resources

###########
# Project #
###########

resource "digitalocean_project" "big-data" {
  name        = "Big Data MSPR"
  description = "This project is about the Big Data MSPR for school"
  purpose     = "Big data"
  # DO project environment can only be staging, production or development
  environment = "production"

  resources = [
    # k8s cluster and firewall can't be added to the resources
    digitalocean_droplet.big-data.urn,
  ]
}

resource "digitalocean_ssh_key" "public_key" {
  name = "My public ssh key"
  public_key = file(var.ssh_public_key_file)
}

##############
# Web server #
##############

resource "digitalocean_droplet" "big-data" {
  image = "ubuntu-20-04-x64"
  name = "big-data"
  region = "fra1"
  size = "m-2vcpu-16gb"
  private_networking = true

  ssh_keys = [digitalocean_ssh_key.public_key.fingerprint]

  connection {
    type = "ssh"
    user = "root"
    private_key = file(var.ssh_priv_key_file)
    host = self.ipv4_address
  }

  # Update and upgrade dependencies
  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt -y install apt-transport-https ca-certificates curl gnupg lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt update",
      "apt install -y docker-ce docker-ce-cli containerd.io",
      "docker --version",
      "curl -L \"https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "chmod +x /usr/local/bin/docker-compose",
      "docker-compose --version"
    ]
  }
}

resource "null_resource" "connection" {
  connection {
    type = "ssh"
    user = "root"
    private_key = file(var.ssh_priv_key_file)
    host = digitalocean_droplet.big-data.ipv4_address
  }

  provisioner "remote-exec" {
    inline = ["echo coucou"]
  }
  depends_on = [digitalocean_droplet.big-data]
}

resource "null_resource" "ssh_remember" {
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "ssh-keyscan -H ${digitalocean_droplet.big-data.ipv4_address} >> ~/.ssh/known_hosts"
    }
    depends_on = [null_resource.connection]
}

################
# Domain name #
################

resource "digitalocean_record" "big-data" {
  depends_on = [digitalocean_droplet.big-data]
  domain = "fredericpinaud.ovh"
  type = "A"
  name = "etl"
  value = digitalocean_droplet.big-data.ipv4_address
  ttl = 60
}

output "big-data-endpoint" {
    value = "http://${digitalocean_record.big-data.name}.${digitalocean_record.big-data.domain}"
}

output "big-data-ip" {
    value = digitalocean_droplet.big-data.ipv4_address
}