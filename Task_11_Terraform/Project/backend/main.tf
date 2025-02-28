terraform {
  backend "s3" {
    region         = "ru-central1"
    bucket         = "task-11--yc-backend--gzf3hap7"
    key            = "backend/terraform.tfstate"

    dynamodb_table = "task-11--yc-backend--state-lock-table"

    endpoints = {
      s3       = "https://storage.yandexcloud.net",
      dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1g5b020anchqspg6qul/etnifkvceh6sn11uk7jj"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}


module "backend" {
  source          = "../../modules/backend"
  backend_prefix  = "yc-backend"
  project_prefix  = "task-11"
}
