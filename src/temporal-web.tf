resource "cloudfoundry_app" "temporal_web" {
  name       = "temporal-web"
  space      = cloudfoundry_space.space.id
  memory     = 1024
  disk_quota = 2048
  docker_image = var.temporal_web_image
  environment = {
    TEMPORAL_GRPC_ENDPOINT = "${hsdp_container_host.temporal.private_ip}:9200"
    TEMPORAL_PERMIT_WRITE_API = "true"
  }

  routes {
    route = cloudfoundry_route.temporal_web.id
  }
}

resource "cloudfoundry_route" "temporal_web" {
  domain   = data.cloudfoundry_domain.domain.id
  space    = cloudfoundry_space.space.id
  hostname = "temporal-web-${random_id.id.hex}"

  depends_on = [cloudfoundry_space_users.users]
}
