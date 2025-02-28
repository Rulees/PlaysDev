# NETWORK OUTPUTS
output "vpc_info" {
  description = "Standard VPC ID + Name from the network module"
  value = {
    name = module.network.vpc_name
    id   = module.network.vpc_id
  }
}

output "subnet_info" {
  description = "Selected Subnet ID + Name from the network module"
  value = {
    name = module.network.subnet_name
    id   = module.network.subnet_id
    cidr = module.network.subnet_cidr
  }
}

output "instance_ip" {
  description = "The private + public IP address of the runner instance."
  value = {
    private_ip = yandex_compute_instance.bastion.network_interface[0].ip_address
    public_ip  = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
  }
}

output "security_group_info" {
  description = "Security group ID + Name"
  value       = {
    name = data.terraform_remote_state.sg.outputs.sg_id
    id   = data.terraform_remote_state.sg.outputs.sg_name
  }
}

# VM OUTPUTS
output "boot_disk_id" {
  description = "The ID of the boot disk created for the instance."
  value       = yandex_compute_disk.bastion.id
}

