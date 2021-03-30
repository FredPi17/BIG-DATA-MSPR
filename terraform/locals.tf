locals {
    docker-compose-path = "${path.module}/../docker-compose.yml"
    nginx-conf-path = "${path.module}/../nginx.conf"

    priv_key_file = "~/.ssh/id_rsa"

    mysql_database = "${path.module}/etl/schemas/database.sql"

    etl_config = "${path.module}/etl/etl.config"
}