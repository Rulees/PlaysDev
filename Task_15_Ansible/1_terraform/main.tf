# DISKS
resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-ssd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd8kc2n656prni2cimp5" # ubuntu 24.04
}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-ssd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd81v21o90r8e978g95e" # fedora
}

# VM's
resource "yandex_compute_instance" "ubuntu" {
  name = "ubuntu"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  
  network_interface {
    subnet_id = "e9bhuq6ojmo18krlm4fh"
    ip_address = "10.10.1.10"

    nat = true
    # nat_ip_address = "89.169.144.151"
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

resource "yandex_compute_instance" "fedora" {
  name = "fedora"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id = "e9bhuq6ojmo18krlm4fh"
    ip_address = "10.10.1.20"
    
    nat = true
    # nat_ip_address = "89.169.139.61"
    # nat_ip_address = yandex_vpc_address.addr["fedora"].external_ipv4_address[0].address 
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = templatefile("cloud-init-fedora.yml", {
      username = "melnikov"
      ssh_key = file("/root/.ssh/YC.pub")
    })
  }
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



