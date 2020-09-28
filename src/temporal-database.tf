resource "cloudfoundry_service_instance" "temporal_db" {
  space        = data.cloudfoundry_space.space.id
  name         = "temporal-db-${random_id.id.hex}"
  service_plan = data.cloudfoundry_service.db.service_plans[var.postgres_plan]
}

resource "cloudfoundry_service_key" "temporal_db_key" {
  name             = "key"
  service_instance = cloudfoundry_service_instance.temporal_db.id
}