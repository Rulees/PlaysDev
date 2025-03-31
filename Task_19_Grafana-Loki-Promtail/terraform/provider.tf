terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "= 0.127.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.44.0"
    }
    random = {
      source = "hashicorp/random"
    }
    time = {
      source = "hashicorp/time"
    }
  }
  required_version = ">= 1.9.4"
}

provider "aws" {
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

provider "yandex" {
  zone      = "ru-central1-a"
  folder_id = "b1ghomnle3pg309t5gu0"
  cloud_id  = "b1gle99ifk9rj88rn6h0"
}

provider "random" {
}

provider "time" {
}