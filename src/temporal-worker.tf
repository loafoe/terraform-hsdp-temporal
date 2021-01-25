resource "hsdp_container_host" "temporal_worker" {
  count           = var.workers
  name            = "temporal-worker-${random_id.id.hex}-${count.index}.dev"
  volumes         = 1
  volume_size     = var.volume_size
  instance_type   = var.worker_instance_type
  security_groups = ["analytics"]

  user_groups = var.user_groups

  bastion_host = var.bastion_host
  user         = var.user
  private_key  = var.private_key

  commands = [
    "docker volume create agent"
  ]
}

resource "hsdp_container_host_exec" "worker" {
  count = var.workers

  triggers = {
    cluster_instance_ids = element(hsdp_container_host.temporal_worker.*.id, count.index)
  }

  bastion_host = var.bastion_host
  host         = element(hsdp_container_host.temporal_worker.*.private_ip, count.index)
  user         = var.user
  private_key  = var.private_key

  file {
    content = templatefile("${path.module}/scripts/bootstrap-worker.sh.tmpl", {
      temporal_hostport   = "${hsdp_container_host.temporal.private_ip}:2181"
      docker_host         = "tcp://${element(hsdp_container_host.temporal_worker.*.private_ip, count.index)}:2375"
      require_client_auth = "false"
      enable_fluentd      = var.hsdp_product_key == "" ? "false" : "true"
      log_driver          = var.hsdp_product_key == "" ? "local" : "fluentd"
      agent_image         = var.agent_image
      autoscaler_image    = var.autoscaler_image
      cartel_token        = var.cartel_token
      cartel_secret       = var.cartel_secret
      region              = var.hsdp_region
      name                = "temporal-worker-${random_id.id.hex}-${count.index}.dev"
    })
    destination = "/home/${var.user}/bootstrap-worker.sh"
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
    "chmod +x /home/${var.user}/bootstrap-worker.sh",
    "/home/${var.user}/bootstrap-worker.sh"
  ]
}
