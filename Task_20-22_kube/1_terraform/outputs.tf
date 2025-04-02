output "instance_public_ip_addresses" {
  description = "The external IP addresses of the instances."
  value = {
    for instance in yandex_compute_instance.ubuntu : 
    instance.name => instance.network_interface[0].nat_ip_address
  }
}