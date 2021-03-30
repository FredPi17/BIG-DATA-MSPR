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
    digitalocean_droplet.kibana-elastic.urn,
    digitalocean_droplet.logstash.urn,
  ]
}

resource "digitalocean_ssh_key" "public_key" {
  name = "My public ssh key"
  public_key = file(var.ssh_public_key_file)
}

#########################
# kibana-elastic server #
#########################

resource "digitalocean_droplet" "kibana-elastic" {
  image = "ubuntu-20-04-x64"
  name = "kibana-elastic"
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

###################
# logstash server #
###################

resource "digitalocean_droplet" "logstash" {
  image = "ubuntu-20-04-x64"
  name = "logstash"
  region = "fra1"
  size = "s-2vcpu-2gb"
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
      "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
      "apt-get install apt-transport-https",
      "echo \"deb https://artifacts.elastic.co/packages/7.x/apt stable main\" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list",
      "apt-get update && sudo apt-get install logstash",
    ]
  }
}

resource "digitalocean_volume" "logstash" {
  region                  = "fra1"
  name                    = "logstash"
  size                    = 100
  initial_filesystem_type = "ext4"
  description             = "logstash persistent volume"
}

resource "digitalocean_volume_attachment" "mysql" {
  droplet_id = digitalocean_droplet.logstash.id
  volume_id  = digitalocean_volume.logstash.id
}

resource "null_resource" "connection-kibana-elastic" {
  connection {
    type = "ssh"
    user = "root"
    private_key = file(var.ssh_priv_key_file)
    host = digitalocean_droplet.kibana-elastic.ipv4_address
  }
  depends_on = [digitalocean_droplet.kibana-elastic]
}

resource "null_resource" "connection-logstash" {
  connection {
    type = "ssh"
    user = "root"
    private_key = file(var.ssh_priv_key_file)
    host = digitalocean_droplet.logstash.ipv4_address
  }
  depends_on = [digitalocean_droplet.logstash]
}

resource "null_resource" "ssh_remember-kibana-elastic" {
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "ssh-keyscan -H ${digitalocean_droplet.kibana-elastic.ipv4_address} >> ~/.ssh/known_hosts"
    }
    depends_on = [null_resource.connection-kibana-elastic]
}

resource "null_resource" "ssh_remember-logstash" {
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "ssh-keyscan -H ${digitalocean_droplet.logstash.ipv4_address} >> ~/.ssh/known_hosts"
    }
    depends_on = [null_resource.connection-logstash]
}

################
# Domain name #
################

resource "digitalocean_record" "kibana-elastic" {
  depends_on = [digitalocean_droplet.kibana-elastic]
  domain = "fredericpinaud.ovh"
  type = "A"
  name = "etl"
  value = digitalocean_droplet.kibana-elastic.ipv4_address
  ttl = 60
}

output "kibana-elastic-endpoint" {
    value = "http://${digitalocean_record.kibana-elastic.name}.${digitalocean_record.kibana-elastic.domain}"
}

output "kibana-elastic-ip" {
    value = digitalocean_droplet.kibana-elastic.ipv4_address
}

output "elastic-ip" {
    value = digitalocean_droplet.elastic.ipv4_address
}