terraform {
  backend "s3" {
    region         = "ru-central1"
    bucket         = "task-11--yc-backend--gzf3hap7"
    key            = "db-posgres/terraform.tfstate"

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

data "terraform_remote_state" "sg" {
  backend = "s3"

  config = {
    region = "ru-central1"
    bucket = "task-11--yc-backend--gzf3hap7"
    key    = "sg/terraform.tfstate"

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


module "db" {
  source = "github.com/terraform-yc-modules/terraform-yc-postgresql.git?ref=1.0.3"
  
  name        = "alone-in-the-dark"
  description = "Single-node PostgreSQL cluster for test purposes"

  network_id  = module.network.vpc_id
  security_groups_ids_list = [data.terraform_remote_state.sg.outputs.sg_id]


  maintenance_window = {
    type = "WEEKLY"
    day  = "SUN"
    hour = "02"
  }

  access_policy = {
    web_sql = true
  }

  performance_diagnostics = {
    enabled = true
  }

  hosts_definition = [
    {
      zone             = "ru-central1-a"
      assign_public_ip = true
      subnet_id        = module.network.subnet_id
    }
  ]

  postgresql_config = {
    max_connections                = 395
    enable_parallel_hash           = true
    autovacuum_vacuum_scale_factor = 0.34
    default_transaction_isolation  = "TRANSACTION_ISOLATION_READ_COMMITTED"
    shared_preload_libraries       = "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"
  }

  default_user_settings = {
    default_transaction_isolation = "read committed"
    log_min_duration_statement    = 5000
  }

  databases = [
    {
      name       = "test1"
      owner      = "test1"
      lc_collate = "ru_RU.UTF-8"
      lc_type    = "ru_RU.UTF-8"
      extensions = ["uuid-ossp", "xml2"]
    }
  ]

  owners = [
    {
      name       = "test1"
      password   = "melnikov"
      conn_limit = 15
    }
  ]

  users = [
    {
      name        = "test1-guest"
      password   = "melnikov"
      conn_limit  = 30
      permissions = ["test1"]
      settings = {
        pool_mode                   = "transaction"
        prepared_statements_pooling = true
      }
    }
  ]
}