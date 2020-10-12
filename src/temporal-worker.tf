resource "hsdp_container_host" "temporal_worker" {
  name          = "temporal-worker-${random_id.id.hex}.dev"
  volumes       = 1
  volume_size   = var.volume_size
  instance_type = var.worker_instance_type

  user_groups = var.user_groups

  connection {
    bastion_host = var.bastion_host
    host         = self.private_ip
    user         = var.user
    private_key  = var.private_key
    script_path  = "/home/${var.user}/bootstrap.bash"
  }

  provisioner "remote-exec" {
    inline = [
      "docker volume create agent"
    ]
  }
}

resource "null_resource" "worker" {
  triggers = {
    cluster_instance_ids = hsdp_container_host.temporal_worker.id
  }

  connection {
    bastion_host = var.bastion_host
    host         = hsdp_container_host.temporal_worker.private_ip
    user         = var.user
    private_key  = var.private_key
    script_path  = "/home/${var.user}/bootstrap.bash"
  }

  provisioner "file" {
    content = templatefile("${path.module}/scripts/bootstrap-worker.sh.tmpl", {
      temporal_hostport   = "${hsdp_container_host.temporal.private_ip}:2181"
      docker_host         = "tcp://${hsdp_container_host.temporal_worker.private_ip}:2375"
      require_client_auth = "false"
      enable_fluentd      = "false"
      agent_image         = var.agent_image
    })
    destination = "/home/${var.user}/bootstrap-worker.sh"
  }

  provisioner "file" {
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
      "chmod +x /home/${var.user}/bootstrap-fluent-bit.sh",
      "/home/${var.user}/bootstrap-fluent-bit.sh",
      "chmod +x /home/${var.user}/bootstrap-worker.sh",
      "/home/${var.user}/bootstrap-worker.sh"
    ]
  }
}
