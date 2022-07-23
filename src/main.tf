resource "random_id" "id" {
  byte_length = 8
}

resource "hsdp_container_host" "temporal" {
  name          = "temporal-server-${random_id.id.hex}.dev"
  volumes       = 1
  volume_size   = var.volume_size
  instance_type = var.instance_type

  user_groups     = var.user_groups
  security_groups = ["analytics"]

  bastion_host = var.bastion_host
  user         = var.user
  private_key  = var.private_key
}


resource "ssh_resource" "server_volumes" {
  host         = hsdp_container_host.temporal.private_ip
  bastion_host = var.bastion_host
  user         = var.user
  private_key  = var.private_key

  commands = [
    "docker volume create temporal"
  ]
}

resource "ssh_resource" "server" {
  triggers = {
    cluster_instance_ids = hsdp_container_host.temporal.id
  }

  depends_on = [ssh_resource.server_volumes]

  host         = hsdp_container_host.temporal.private_ip
  bastion_host = var.bastion_host
  user         = var.user
  private_key  = var.private_key

  file {
    content = templatefile("${path.module}/scripts/bootstrap-server.sh.tmpl", {
      postgres_username          = cloudfoundry_service_key.temporal_db_key.credentials.username
      postgres_password          = cloudfoundry_service_key.temporal_db_key.credentials.password
      postgres_hostname          = cloudfoundry_service_key.temporal_db_key.credentials.hostname
      require_client_auth        = "false"
      enable_fluentd             = var.hsdp_product_key == "" ? "false" : "true"
      log_driver                 = var.hsdp_product_key == "" ? "local" : "fluentd"
      temporal_image             = var.temporal_image
      temporal_id                = random_id.id.hex
      temporal_cli_address       = "${hsdp_container_host.temporal.private_ip}:2181"
      temporal_admin_tools_image = var.temporal_admin_tools_image
    })
    destination = "/home/${var.user}/bootstrap-server.sh"
  }

  file {
    content = templatefile("${path.module}/scripts/bootstrap-fluent-bit.sh.tmpl", {
      ingestor_host    = var.hsdp_ingestor_host
      shared_key       = var.hsdp_shared_key
      secret_key       = var.hsdp_secret_key
      product_key      = var.hsdp_product_key
      custom_field     = var.hsdp_custom_field
      fluent_bit_image = var.fluent_bit_image
    })
    destination = "/home/${var.user}/bootstrap-fluent-bit.sh"
  }

  file {
    content     = tls_private_key.key.private_key_pem
    destination = "/home/${var.user}/private_key.pem"
  }

  file {
    content     = tls_self_signed_cert.server.cert_pem
    destination = "/home/${var.user}/server_cert.pem"
  }

  file {
    content     = tls_self_signed_cert.client.cert_pem
    destination = "/home/${var.user}/client_cert.pem"
  }

  # Bootstrap script called with private_ip of each node in the cluster
  commands = [
    "chmod +x /home/${var.user}/bootstrap-fluent-bit.sh",
    "/home/${var.user}/bootstrap-fluent-bit.sh",
    "chmod +x /home/${var.user}/bootstrap-server.sh",
    "/home/${var.user}/bootstrap-server.sh"
  ]
}
