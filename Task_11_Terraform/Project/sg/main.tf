terraform {
  backend "s3" {
    region         = "ru-central1"
    bucket         = "task-11--yc-backend--gzf3hap7"
    key            = "sg/terraform.tfstate"

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



module "sg" {
  source         = "../../modules/sg"
  network_id     = module.network.vpc_id
  project_prefix = "task-11"

  security_group_runners = [
      # Входящие правила
      {
        direction      = "ingress"
        description    = "Allow HTTP and HTTPS"
        protocol       = "TCP"
        ports          = [80, 443]
        v4_cidr_blocks = ["10.10.10.0/24"]
      },
      {
        direction      = "ingress"
        description    = "Allow SSH"
        protocol       = "TCP"
        ports          = [22]
        v4_cidr_blocks = ["176.15.163.112/32","10.10.0.0/16"]
      },
      # BD-POSTGRES
      {
        direction      = "ingress"
        description    = "Allow SSH"
        protocol       = "TCP"
        ports          = [6432]
        v4_cidr_blocks = ["176.15.163.112/32","10.10.0.0/16"]
      },

      # Исходящие правила
      {
        direction      = "egress"
        description    = "Allow all outbound HTTP/HTTPS traffic"
        protocol       = "TCP"
        ports          = [80, 443]
        v4_cidr_blocks = ["0.0.0.0/0"]
      },
      {
        direction      = "egress"
        description    = "Allow all outbound SSH"
        protocol       = "TCP"
        ports          = [22]
        v4_cidr_blocks = ["0.0.0.0/0"]
      }
    ]
}
