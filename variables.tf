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
  default = 8
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

variable "dns_zone" {
  type    = string
  default = "NTMAX.ca."
}

variable "dns_sub_zone" {
  type    = string
  default = "k8s"
}

variable "dns_ttl" {
  type    = number
  default = 900
}

variable "certificate_params" {
  type = object({
    organization        = string
    organizational_unit = string
    locality            = string
    country             = string
    province            = string
    support_email       = string
  })
  default = {
    organization        = "NTMAX"
    organizational_unit = "Labs"
    locality            = "Montreal"
    country             = "CA"
    province            = "QC"
  }
}

variable "node_labels" {
  type = map(string)
  default = {
    "ntmax.ca/cloud-platform" = "xcp-ng"
    "ntmax.ca/cloud-os"       = "centos-stream-8"
    "ntmax.ca/region"         = "mtl-south-1"
  }
}

variable "master_labels" {
  type = map(string)
  default = {
    "ntmax.ca/cloud-platform" = "xcp-ng"
    "ntmax.ca/cloud-os"       = "centos-stream-8"
    "ntmax.ca/region"         = "mtl-south-1"
  }
}

variable "master_vm_tags" {
  type = list(string)
  default = [
    "ntmax.ca/cloud-os:centos-stream-8",
    "ntmax.ca/middleware:kubernetes",
    "ntmax.ca/provisionning:ansible",
    "ntmax.ca/provisionning:terraform",
    "kubernetes.io/role:master"
  ]
}

variable "node_vm_tags" {
  type = list(string)
  default = [
    "ntmax.ca/cloud-os:centos-stream-8",
    "ntmax.ca/middleware:kubernetes",
    "ntmax.ca/provisionning:ansible",
    "ntmax.ca/provisionning:terraform",
    "kubernetes.io/role:worker"
  ]
}

variable "xen_sr_name" {
  type    = string
  default = "[NFS] TrueNAS SSD"
}
variable "xen_network_name" {
  type    = string
  default = "k8s.ntmax.ca"
}
variable "xen_template_name" {
  type    = string
  default = "Cloud-init - CentOS 8 Stream"
}
variable "xen_pool_name" {
  type    = string
  default = "Cluster-XCP"
}

variable "xen_xoa_url" {
  type    = string
  default = "wss://xen-orchestra.ntmax.ca"
}

variable "vm_rsa_ssh_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvUQ/2WaIYub7Ns8psnOPoYaaArZcoRrfTtDDHXruSZfOnbPrvfFInuIdI11AxwodzKILv8oeUOqmFSpmGOBZn4Hy1An2eM39WG8025JKNE9UainAfKlpX8HgMeSyqdT7X50HI7LsgUYvrbW4tPnLt9Dh+Wsgn9+ErQsE0Hj8IExZv9O/YDLJ6Lin3nD775ncXvHbI1nFfcTmJ/kW9NXvyP+AJYVrbP1hxC72BNQfbJWvhYymyDAhEhzFudCjz420ajqrWwsNzJIAV4P3gVWHUNVntllqJtf60EoQhKTAPZxl3Pm+OgneG8zLMC4PkSeXG4nw26kmusH7CLxd/BX3DrlXLpdvL7RMbDuwl/b183HoKsCfx9kAID6KVB1qCLRw/E5g/F6EeIhK4n2Tr/82PIi3Iw3N93PyfLAjn9HmAgQnXW/uQCqwR2+s5uPflysOTRExxIEIaZsWSaTrgte1+33dIQMpYK7YgpYNncuQGYGZH1cxYYbs0Y8UheQ5i0mgSzsTQWY+VPnZRgAGZ2Wmz+1Ndr8AaHvzL81DLGl8355wfXiuK06eTqRzAaepIUZGAanVwllCm4XFVVzeIPIFcnfcVTnsCJ0xcDFQxdUlsrRGdD04fQu1ioX1lhT0P03VA1thUtKRkmo+thT2bOwZV+eZeGzaHxQe21WQmKU/WDQ=="
}