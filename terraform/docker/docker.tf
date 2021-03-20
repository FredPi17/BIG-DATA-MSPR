resource "docker_network" "etl" {
  name = "etl"
}

resource "docker_container" "elasticsearch" {
    image = docker_image.elasticsearch.latest
    name = "elasticsearch"
    restart = "unless-stopped"
    networks_advanced {
        name = docker_network.etl.name
        aliases = ["elasticsearch"]
    }
    ports {
        internal = 9200
        external = 9200
    }
    ports {
        internal = 9300
        external = 9300
    }
    env = ["discovery.type=single-node"]
}

resource "docker_container" "kibana" {
    image = docker_image.kibana.latest
    name = "kibana"
    restart = "unless-stopped"
    networks_advanced {
        name = docker_network.etl.name
        aliases = ["kibana"]
    }
    ports {
        internal = 5601
        external = 5601
    }
    links = ["elasticsearch:elasticsearch"]
}

resource "docker_container" "nginx" {
    image = docker_image.nginx.latest
    name = "nginx"
    restart = "unless-stopped"
    networks_advanced {
        name = docker_network.etl.name
        aliases = ["nginx"]
    }
    ports {
        internal = 80
        external = 80
    }
    upload {
        source = "/home/fred/School/Big-data/nginx.conf"
        file = "/etc/nginx/nginx.conf"
    }
}

resource "docker_image" "elasticsearch" {
    name = "docker.elastic.co/elasticsearch/elasticsearch:7.11.2"
}

resource "docker_image" "kibana" {
    name = "docker.elastic.co/kibana/kibana:7.11.2"
}

resource "docker_image" "nginx" {
    name = "nginx:stable"
}