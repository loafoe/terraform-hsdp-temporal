terraform {
  required_providers {
    cloudfoundry = {
      source  = "philips-labs/cloudfoundry"
      version = ">= 0.1300.0"
    }
    random = {
      source = "random"
    }
    hsdp = {
      source  = "philips-software/hsdp"
      version = ">= 0.9.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.2.0"
    }
  }
}
