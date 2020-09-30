output "temporal_ip" {
  description = "Private IP address of Temporal server"
  value       = hsdp_container_host.temporal.private_ip
}

output "temporal_id" {
  description = "Server ID of prometheus"
  value       = random_id.id.hex
}

output "temporal_web_url" {
  description = "The cloud foundry URL of Temporal web"
  value       = cloudfoundry_route.temporal_web.endpoint
}
