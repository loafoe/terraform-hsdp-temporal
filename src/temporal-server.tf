locals {
  docker_cmd = <<EOF
    docker run -d --restart always -v temporal:/temporal \
      -e DB=postgres \
      -e DBNAME=hsdp_pg \
      -e DB_PORT=5432 \
      -e AUTO_SETUP=true \
      -e POSTGRES_USER=${cloudfoundry_service_key.temporal_db_key.credentials.username} \
      -e POSTGRES_PWD=${cloudfoundry_service_key.temporal_db_key.credentials.password} \
      -e POSTGRES_SEEDS=${cloudfoundry_service_key.temporal_db_key.credentials.hostname}
      -p9200:7233 \
      ${var.temporal_image}
EOF
}

resource "hsdp_container_host" "temporal" {
  name          = "temporal-${random_id.id.hex}.dev"
  volumes       = 1
  volume_size   = var.volume_size
  instance_type = var.instance_type

  user_groups     = var.user_groups
  security_groups = ["analytics"]

  connection {
    bastion_host = var.bastion_host
    host         = self.private_ip
    user         = var.user
    private_key  = var.private_key
    script_path  = "/home/${var.user}/bootstrap.bash"
  }

  provisioner "remote-exec" {
    inline = [
      "docker volume create temporal",
      "docker run -d --restart always -v temporal:/temporal -e DB=postgres -e DBNAME=hsdp_pg -e DB_PORT=5432 -e AUTO_SETUP=true -e POSTGRES_USER=${cloudfoundry_service_key.temporal_db_key.credentials.username} -e POSTGRES_PWD=${cloudfoundry_service_key.temporal_db_key.credentials.password} -e POSTGRES_SEEDS=${cloudfoundry_service_key.temporal_db_key.credentials.hostname} -p9200:7233 ${var.temporal_image}"
    ]
  }
}
