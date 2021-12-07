variable "vm_count" {
  default = 8
  type    = number
}

variable "vm_prefix" {
  default = "centos8-k8s"
  type    = string
}

variable "vm_disk_size_gb" {
  default = 30
  type    = number
}

variable "vm_memory_size_gb" {
  default = 8
  type    = number
}

variable "vm_cpu_count" {
  default = 2
  type    = number
}

variable "master_count" {
  default = 3
  type    = number
}

variable "master_prefix" {
  default = "centos8-k8s"
  type    = string
}

variable "master_disk_size_gb" {
  default = 30
  type    = number
}

variable "master_memory_size_gb" {
  default = 4
  type    = number
}

variable "master_cpu_count" {
  default = 2
  type    = number
}

variable "dns_username" {
  type = string
}

variable "dns_password" {
  sensitive = true
  type      = string
}

variable "dns_server" {
  type = string
}

variable "dns_realm" {
  type = string
}