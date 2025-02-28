locals {
  network_name = var.network_name
  subnet_name  = var.subnet_name 
} 



# Получаем существующий VPC по имени
data "yandex_vpc_network" "vpc" {
  name = local.network_name
}

# Получаем подсеть на основе зоны
data "yandex_vpc_subnet" "subnet" {
  name       = local.subnet_name
}



# ###
# # CREATE, IF NECESSARY
# ###
# resource "yandex_vpc_network" "net" {
#   name           = "task-11"
# }

# resource "yandex_vpc_subnet" "public" {
#   name           = "public"
#   v4_cidr_blocks = ["10.10.1.0/24"]
#   zone           = "ru-central1-a"
#   network_id     = yandex_vpc_network.net.id
# }

# resource "yandex_vpc_subnet" "private" {
#   name           = "private"
#   v4_cidr_blocks = ["10.10.2.0/24"]
#   zone           = "ru-central1-a"
#   network_id     = yandex_vpc_network.net.id
# }