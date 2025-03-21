# DISKS
resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-ssd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd8kc2n656prni2cimp5" # ubuntu 24.04
}

# VM's
resource "yandex_compute_instance" "ubuntu" {
  name = "ubuntu"
  platform_id = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 16
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  
  network_interface {
    subnet_id = "e9bhuq6ojmo18krlm4fh"
    ip_address = "10.10.1.10"

    nat = true
    nat_ip_address = "158.160.59.222"
    # nat_ip_address = yandex_vpc_address.addr["ubuntu"].external_ipv4_address[0].address 
  }

  scheduling_policy {
    preemptible = true
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
#   for_each = {
#     ubuntu = "ru-central1-a"
#   }

#   name = "${each.key}-address"
#   external_ipv4_address {
#     zone_id = each.value
#   }
# }



