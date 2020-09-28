
data "cloudfoundry_org" "org" {
  name = var.org_name
}

data "cloudfoundry_user" "user" {
  name   = var.user
  org_id = data.cloudfoundry_org.org.id
}

data "cloudfoundry_domain" "domain" {
  name = var.app_domain
}

data "cloudfoundry_service" "db" {
  name = "hsdp-rds"
}