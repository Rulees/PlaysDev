terraform {
  backend "s3" {
    region         = "ru-central1"
    bucket         = "task-11--yc-backend--gzf3hap7"
    key            = "vm-bastion/terraform.tfstate"

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


# 1) Получить названия ресурсов автоматически здесь согласно шаблону или Задать значения вручную внутри variables.tf
locals {
  boot_disk_name             = var.boot_disk_name != null ? var.boot_disk_name : "${var.project_prefix}--boot-disk--${var.personal_prefix}"
  linux_vm_name              = var.linux_vm_name  != null ? var.linux_vm_name  : "${var.project_prefix}--linux-vm--${var.personal_prefix}"
  username                   = "melnikov"
  ssh_key                    = file("/root/.ssh/YC.pub")
  private_ip                 = "10.10.1.10"
  public_ip                  = "89.169.153.231"
}


# Создание загрузочного диска для VM
resource "yandex_compute_disk" "bastion" {
  name     = local.boot_disk_name
  zone     = var.zone
  image_id = var.image_id      # container-optimized-image

  type = var.instance_resources.disk.disk_type
  size = var.instance_resources.disk.disk_size

  lifecycle {
    ignore_changes = [image_id]
  }
}


# Создание VM Bastion
resource "yandex_compute_instance" "bastion" {
  name                      = local.linux_vm_name
  allow_stopping_for_update = true
  zone                      = var.zone
  platform_id               = var.instance_resources.platform_id

  resources {
    cores  = var.instance_resources.cores
    memory = var.instance_resources.memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.bastion.id
  }

  network_interface {
    subnet_id = module.network.subnet_id  # Используем subnet_id из модуля network
    ip_address = local.private_ip

    nat       = true 
    nat_ip_address = local.public_ip # static public ip (already exists)

    security_group_ids = [data.terraform_remote_state.sg.outputs.sg_id]
  }

  scheduling_policy {
    preemptible = true
  }


  metadata = {
    user-data = templatefile("../cloud-init.yml", {
      username = local.username
      ssh_key = local.ssh_key
    })
  }
}