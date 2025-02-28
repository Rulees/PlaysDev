resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-ssd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd8bpal18cm4kprpjc2m"
}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-ssd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd8bpal18cm4kprpjc2m"
}

resource "yandex_compute_instance" "bastion" {
  name = "bastion"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  
  network_interface {
    subnet_id = "e9b3j93mg626m8410fps"
    ip_address = "10.10.1.10"

    nat = true
    nat_ip_address = yandex_vpc_address.addr.external_ipv4_address[0].address 
  }

  metadata = {
    user-data = templatefile("cloud-init.yml", {
      hostname = "bastion"
      username = "melnikov"
      ssh_key = file("/root/.ssh/YC.pub")
    })
  }
}

resource "yandex_compute_instance" "vm-2" {
  name = "private"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id = "e9bn1fjac4fcktjn5iq7"
    ip_address = "10.10.2.10"
  }

  metadata = {
    user-data = templatefile("cloud-init.yml", {
      username = "melnikov"
      ssh_key = file("/root/.ssh/YC.pub")
    })
  }
}

resource "yandex_vpc_address" "addr" {
  name = "vm-adress"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}





