resource "docker_container" "mysql" {
    name = "mysql"
    image = docker_image.mysql.latest
    command = ["--default-authentication-plugin=mysql_native_password"]
    restart = "always"
    ports {
        internal = 3306
        external = 3306
    }
    entrypoint = ["${local.mysql_database}"]
    env = ["MYSQL_ROOT_PASSWORD=password"]
}

resource "docker_image" "mysql" {
    name = "mysql:8.0"
}

resource "null_resource" "etl_deploy" {
    connection {
        type = "ssh"
        user = "root"
        private_key = file(var.ssh_priv_key_file)
        host = data.terraform_remote_state.logstash.outputs.elastic-ip
    }

    provisioner "remote_exec" {
        inline = [
            "cd logstash-7.12.0",
            "bin/logstash -e ${local.etl_config}"
        ]
        
    }
}