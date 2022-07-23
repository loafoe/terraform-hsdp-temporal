resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}


resource "tls_self_signed_cert" "server" {
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name  = "temporal.server"
    organization = "terraform-hsdp-temporal"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "server_auth",
    "client_auth"
  ]
}

resource "tls_self_signed_cert" "client" {
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name  = "temporal.client"
    organization = "terraform-hsdp-temporal"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "client_auth",
    "server_auth"
  ]
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name  = "temporal.server"
    organization = "terraform-hsdp-temporal"
  }
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.key.private_key_pem

  subject {
    common_name  = "temporal.client"
    organization = "terraform-hsdp-temporal"
  }
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.server.cert_pem

  is_ca_certificate = true

  validity_period_hours = 8760

  allowed_uses = [
    "client_auth",
    "server_auth"
  ]
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_private_key_pem = tls_private_key.key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.client.cert_pem

  is_ca_certificate = true

  validity_period_hours = 8760

  allowed_uses = [
    "client_auth",
    "server_auth"
  ]
}
