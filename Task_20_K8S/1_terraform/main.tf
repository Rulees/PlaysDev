variable "disks" {
  default = {
	  "1" = "boot-disk-master",
	  "2" = "boot-disk-worker1",
    "3" = "boot-disk-worker2"

	}
}

variable "instances" {
  default = {
	  "1" = "master",
	  "2" = "worker1",
    "3" = "worker2"
	}
}

# DISKS
resource "yandex_compute_disk" "boot-disk" {
  for_each = var.disks

  name     = each.value
  type     = "network-ssd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd8kc2n656prni2cimp5" # ubuntu 24.04
}

# VM's
resource "yandex_compute_instance" "ubuntu" {
  for_each    = var.instances

  name        = each.value
  platform_id = "standard-v3"

  resources {
    cores  = each.value == "master" ? 4 : 2
    memory = each.value == "master" ? 8 : 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk[each.key].id  # Reference the correct disk by key
  }

  
  network_interface {
    subnet_id = "e9bfgc27v0b7pgnac64f"
    ip_address = "10.10.0.${each.key + 9}" # from 10,11,12,13..

    nat = true 
    # nat_ip_address = "62.84.127.199"
    # nat_ip_address = yandex_vpc_address.addr[each.key].external_ipv4_address[0].address 
  }

  scheduling_policy {
    preemptible = true
  }
  allow_stopping_for_update = true 

  labels = {
    k8s = each.value == "master" ? "master" : "worker"
  }

  metadata = {
    user-data = templatefile("cloud-init.yml", {
      username = "melnikov"
      ssh_key = file("/root/.ssh/YC.pub")
    })
  }
}


# External addresses
# resource "yandex_vpc_address" "addr" {
#   for_each = var.instances

#   name = "${each.value}-address"

#   external_ipv4_address {
#     zone_id = "ru-central1-a"
#   }
  # deletion_protection = true
# }