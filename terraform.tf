terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.20.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0.0"
    }
  }
}

provider "oci" {
  region = coalesce(var.region, "us-phoenix-1") # Default to phoenix-1 if not specified
}

# Additional providers (for SSH key generation and local file operations)
provider "local" {}
provider "null" {}
provider "tls" {}
