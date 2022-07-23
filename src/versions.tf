terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.15.3"
    }
    random = {
      source = "random"
    }
    hsdp = {
      source  = "philips-software/hsdp"
      version = ">= 0.9.1"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = ">= 2.1.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.2.0"
    }
  }
}
