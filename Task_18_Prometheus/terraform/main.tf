variable "disks" {
  default = {
	  "1" = "boot-disk-10",
	  "2" = "boot-disk-20",
	}
}

variable "instances" {
  default = {
	  "1" = "first",
	  "2" = "second"
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
  for_each = var.instances

  name = each.value
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk[each.key].id  # Reference the correct disk by key
  }

  
  network_interface {
    subnet_id = "e9bfgc27v0b7pgnac64f"
    # ip_address = "10.10.1.10"

    nat = true
    # nat_ip_address = "89.169.144.151"
    # nat_ip_address = yandex_vpc_address.addr["ubuntu"].external_ipv4_address[0].address 
  }

  scheduling_policy {
    preemptible = true
  }

  labels = {
    metric = each.key == "1" ? "vm" : "cpu"
  }

  metadata = {
    user-data = templatefile("cloud-init.yml", {
      username = "melnikov"
      ssh_key = file("/root/.ssh/YC.pub")
    })
  }
  # depends_on = [yandex_compute_disk.boot-disk]
}


# External addresses
# resource "yandex_vpc_address" "addr" {
#   for_each = {
#     ubuntu = "ru-central1-a"
#     fedora = "ru-central1-a"
#   }

#   name = "${each.key}-address"
#   external_ipv4_address {
#     zone_id = each.value
#   }
# }



