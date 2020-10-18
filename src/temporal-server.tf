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
      "docker volume create temporal"
    ]
  }
}

resource "null_resource" "server" {
  triggers = {
    cluster_instance_ids = hsdp_container_host.temporal.id
  }

  connection {
    bastion_host = var.bastion_host
    host         = hsdp_container_host.temporal.private_ip
    user         = var.user
    private_key  = var.private_key
    script_path  = "/home/${var.user}/bootstrap.bash"
  }

  provisioner "file" {
    content = templatefile("${path.module}/scripts/bootstrap.sh.tmpl", {
      postgres_username          = cloudfoundry_service_key.temporal_db_key.credentials.username
      postgres_password          = cloudfoundry_service_key.temporal_db_key.credentials.password
      postgres_hostname          = cloudfoundry_service_key.temporal_db_key.credentials.hostname
      require_client_auth        = "false"
      temporal_image             = var.temporal_image
      temporal_id                = random_id.id.hex
      temporal_cli_address       = "${hsdp_container_host.temporal.private_ip}:2181"
      temporal_admin_tools_image = var.temporal_admin_tools_image
    })
    destination = "/home/${var.user}/bootstrap.sh"
  }

  provisioner "file" {
    content     = tls_private_key.key.private_key_pem
    destination = "/home/${var.user}/private_key.pem"
  }

  provisioner "file" {
    content     = tls_self_signed_cert.server.cert_pem
    destination = "/home/${var.user}/server_cert.pem"
  }

  provisioner "file" {
    content     = tls_self_signed_cert.client.cert_pem
    destination = "/home/${var.user}/client_cert.pem"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /home/${var.user}/bootstrap.sh",
      "/home/${var.user}/bootstrap.sh"
    ]
  }
}
