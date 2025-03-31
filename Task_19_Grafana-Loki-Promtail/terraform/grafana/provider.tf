terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = ">= 3.10.0"
    }
  }
  required_version = ">= 1.9.4"
}

provider "grafana" {
  url  = "http://62.84.127.199:3000"
  auth = "admin:admin"
  # auth = "admin:257752"
  # auth = "glsa_bDPxVqvA9x8BcVU0bAHG4TRJpjoFdtNh_dbb7671e"
}