# THIS FILE SET'S MANUAL VARIABLE VALUES FOR DIFFERENT RESOURCES.
# SET VARIABLES WITH THE LABEL (Optional) IS NOT RECOMMENDED, CAUSE IT'S ALREADY SET ACCORDING TO THE TEMPLATE INSIDE "locals" main.tf 



# GENERAL
variable "project_prefix" {
  description = "Name prefix for project."
  type        = string
  default     = "task-11"
}

variable "personal_prefix" {
  description = "Name prefix"
  type        = string
  default     = "bastion"
}

variable "zone" {
  description = "Zone"
  type        = string
  default     = "ru-central1-a"
}


# SETUP VM
variable "boot_disk_name" {
  description = "(Optional) - Name of the boot disk"
  type        = string
  default     = null
}

variable "image_id" {
  description = "Boot disk image id:  container-optimized-image"
  type        = string
  default     = "fd8d61mhumda10cb33vm"
}

variable "linux_vm_name" {
  description = "(Optional) - Name of the Linux VM"
  type        = string
  default     = null
}   

variable "instance_resources" {
  description = <<EOF
    (Optional) Specifies the resources allocated to an instance.
      - `platform_id`: The type of virtual machine to create.If not provided, it defaults to `standard-v3`.
      - `cores`: The number of CPU cores allocated to the instance.
      - `memory`: The amount of memory (in GiB) allocated to the instance.
      - `disk`: Configuration for the instance disk.
        - `disk_type`: The type of disk for the instance. If not provided, it defaults to `network-ssd`.
        - `disk_size`: The size of the disk (in GiB) allocated to the instance. If not provided, it defaults to 15 GiB.
  EOF

  type = object({
    platform_id = optional(string, "standard-v3")   # Необязательный параметр с дефолтным значением 
    cores       = number                            # Обязательный параметр
    memory      = number                            # Обязательный параметр
    disk = optional(object({
      disk_type = optional(string, "network-ssd")
      disk_size = optional(number, 15)
    }), {})
  })

  default = {
    platform_id = "standard-v3"
    cores       = 2
    memory      = 4
    disk = {
      disk_type = "network-ssd"
      disk_size = 15
    }
  }
}