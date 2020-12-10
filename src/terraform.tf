terraform {
  required_providers {
    cloudfoundry = {
      source  = "philips-labs/cloudfoundry"
      version = ">= 0.1206.0"
    }
    random = {
      source = "random"
    }
    hsdp = {
      source  = "philips-software/hsdp"
      version = ">= 0.6.7"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.2.0"
    }
  }
}
